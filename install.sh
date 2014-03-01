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


assert_port_is_available() {
  PORT=$1
  [[ $( netstat --listening --numeric --tcp | fgrep ":${PORT}" | wc -l ) = "0" ]] ||
    err_exit $LINENO "port $PORT is already in use"
  return 0
}



## check preconditions
assert_cmd "svn"
assert_cmd "svnserve"
assert_cmd "svnadmin"
assert_port_is_available 3690



PROJECT_ROOT=$1
# if no arg is given (or the path given is not a dir) then
# we assume this script is launched from within the PROJECT_ROOT
[[ -d "$PROJECT_ROOT" ]] || PROJECT_ROOT=$( pwd )

DOCUMENT_ROOT=$PROJECT_ROOT/public

[[ -d "$DOCUMENT_ROOT" ]] || err_exit $LINENO "Assumed we are in the project root; turns out we are not"



# init vars

WWW_USER=www-data
# check the existance of the expected webserver user
id $WWW_USER >/dev/null || ask_var WWW_USER "Please enter the name of the user your web server runs as"

SVN_ROOT=~/svn
REPO_PATH=$SVN_ROOT/documents
REPO_URL=svn://localhost/documents
SVN_DEFAULT_USERNAME=$WWW_USER
SVN_DEFAULT_PASSWORD="tinymce"



## setup 3rd party components
mkdir -p $PROJECT_ROOT/libs $PROJECT_ROOT/public/js
cd $PROJECT_ROOT/3rdparty &&
  unzip -qq '*.zip' &&
  mv dist/* $PROJECT_ROOT/public &&
  rm -rf dist &&
  mv tinymce/js/* $PROJECT_ROOT/public/js &&
  rm -rf tinymce
  mv jquery.min.js $PROJECT_ROOT/public/js &&
  mv html2pdf_v4.03 $PROJECT_ROOT/libs/html2pdf &&
  echo -e "\n - successfully setup the 3rd party components\n" ||
    err_exit $LINENO "Failed while trying to setup the 3rd party components"

[[ -f /etc/debian_version ]] && sudo apt-get install php5-svn



## setup the SVN repo for versioning the documents
mkdir -p $SVN_ROOT &&
svnadmin create $REPO_PATH &&
echo "$SVN_DEFAULT_USERNAME = $SVN_DEFAULT_PASSWORD" >> $REPO_PATH/conf/passwd &&
cat > $REPO_PATH/conf/svnserve.conf <<EOF
[general]
anon-access = none
auth-access = write
password-db = passwd
realm = My Documents Repository

EOF
  echo -e "\n - SVN repository created in $REPO_PATH" ||
    err_exit $LINENO "Failed while trying to setup the SVN repository in $REPO_PATH"

svnserve -d -r $SVN_ROOT --listen-host=127.0.0.1 ||
  print_err $LINENO "ERR: spawning svnserve daemon failed"


## checkout a wc for the application
svn co -q $REPO_URL $PROJECT_ROOT/documents --username $SVN_DEFAULT_USERNAME --password $SVN_DEFAULT_PASSWORD &&
sudo chown -R ${WWW_USER} $PROJECT_ROOT/documents &&
echo &&
echo " - SVN working copy succesfully checked out in $PROJECT_ROOT/documents" ||
  err_exit $LINENO "Failed while trying to check out a WC in $PROJECT_ROOT/documents"


echo
echo "You now have:"
echo " - a SVN repo in $REPO_PATH"
echo " - a SVN working copy in $PROJECT_ROOT/documents"
echo
echo "Now you should:"
echo " - setup your web server to serve contents from the DocumentRoot: $DOCUMENT_ROOT"
echo

exit 0
