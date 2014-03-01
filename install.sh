#!/bin/bash
#
# setup script designed for Debian
#


print_err() {
  lineno=$1
  shift
  errmsg=$@
  {
    echo
    echo "    err: $errmsg (:${lineno})"
    echo
  } >&2
  return 0
}

err_exit() {
  lineno=$1
  shift
  errmsg=$@

  print_err $lineno "$errmsg -- now exiting"
  exit 1
}

assert_cmd() {
  cmd=$1

  which "$cmd" >/dev/null || err_exit $LINENO "command $cmd is not on PATH"
  return 0
}

ask_var() {
  [[ $# -ge 1 ]] || return 1
  varname=$1
  [[ -n "$2" ]] && msg=$2 || msg="Please enter a value for var $varname"
  read -p "$msg: " $varname
  return 0
}




assert_we_know_where_we_are() {
  [[ -d "$PROJECT_ROOT/public" ]] ||
    err_exit $LINENO "Looks like we are not in the project root"
  return 0
}

assert_port_is_available() {
  PORT=$1
  [[ $( netstat --listening --numeric --tcp | fgrep ":${PORT}" | wc -l ) = "0" ]] ||
    err_exit $LINENO "port $PORT is already in use"
  return 0
}


install_os_packages() {
  echo "Going to ask you your sudo password in order to install the required packages"
  sudo apt-get update
  sudo apt-get -y install unzip &&
  sudo apt-get -y install subversion apache2 php5 php5-svn &&
  sudo service apache2 restart &&
  return 0

  return 1
}

setup_3rd_party_libs() {
  rm -rf $PROJECT_ROOT/libs/*
  rm -rf $PROJECT_ROOT/public/{js,fonts,css}

  mkdir -p $PROJECT_ROOT/libs

  TMP_DIR=$(mktemp -d /tmp/documents-versioner.XXXXXXXXXX)
  cd $PROJECT_ROOT/3rdparty &&
    unzip -qq '*.zip' -d $TMP_DIR &&
  cd $TMP_DIR &&
    mv dist/* $PROJECT_ROOT/public &&
    mv tinymce/js/* $PROJECT_ROOT/public/js &&
    mv jquery.min.js $PROJECT_ROOT/public/js &&
    mv html2pdf_v4.03 $PROJECT_ROOT/libs/html2pdf &&

  echo -e "\n - successfully setup the 3rd party libraries\n" &&
  return 0

  return 1
}

setup_svn_repo() {
  mkdir -p $SVN_ROOT
  svnadmin create $SVN_REPO_PATH || return 1
  echo "$SVN_DEFAULT_USERNAME = $SVN_DEFAULT_PASSWORD" >> $SVN_REPO_PATH/conf/passwd &&
  cat > $SVN_REPO_PATH/conf/svnserve.conf <<EOF
[general]
anon-access = none
auth-access = write
password-db = passwd
realm = My Documents Repo

EOF
  svnserve -d -r $SVN_ROOT --listen-host=127.0.0.1 || return 1

  echo -e "\n - SVN repository created in $SVN_REPO_PATH\n" &&
  return 0
}

setup_svn_wc() {
  #rm -rf $SVN_WC_PATH
  svn co -q $SVN_REPO_URL $SVN_WC_PATH --username $SVN_DEFAULT_USERNAME --password $SVN_DEFAULT_PASSWORD &&
  sudo chown -R ${WWW_USER} $SVN_WC_PATH &&
  echo -e "\n - SVN working copy succesfully checked out in $SVN_WC_PATH\n" ||
    err_exit $LINENO "Failed while trying to check out a WC in $SVN_WC_PATH"
  return 0
}





## set project root var
PROJECT_ROOT=$1
# if no arg is given (or the path given is not a dir) then
# we assume this script is launched from within the PROJECT_ROOT
[[ -d "$PROJECT_ROOT" ]] || PROJECT_ROOT=$( pwd )

## check preconditions
assert_we_know_where_we_are
assert_port_is_available 3690


## init vars
DOCUMENT_ROOT=$PROJECT_ROOT/public
WWW_USER=www-data
SVN_ROOT=~/svn
SVN_REPO_PATH=$SVN_ROOT/documents
SVN_REPO_URL=svn://localhost/documents
SVN_DEFAULT_USERNAME=$WWW_USER
SVN_DEFAULT_PASSWORD="tinymce"
SVN_WC_PATH=$PROJECT_ROOT/documents

## check the existance of the expected webserver user
id $WWW_USER >/dev/null || ask_var WWW_USER "Please enter the name of the user your web server runs as"


## install required packages
install_os_packages ||
  err_exit $LINENO "install OS packages failed"

setup_3rd_party_libs ||
  err_exit $LINENO "setting up 3rd party libs failed"

## setup the SVN repo for versioning the documents
setup_svn_repo ||
  err_exit $LINENO "setting up the SVN repository in $SVN_REPO_PATH failed"

## checkout a wc to be used by documents-versioner
setup_svn_wc ||
  err_exit $LINENO "setting up the SVN working copy in $SVN_WC_PATH failed"


echo
echo "Now you have:"
echo " - a SVN repo in $SVN_REPO_PATH"
echo " - a SVN working copy in $SVN_WC_PATH"
echo
echo "Now you should:"
echo " - setup your web server to serve contents from the DocumentRoot: $DOCUMENT_ROOT"
echo

exit 0
