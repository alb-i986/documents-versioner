#!/bin/bash
#
# setup script designed for Ubuntu
# to be used by Vagrant
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

check_cmd() {
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



PROJECT_ROOT=$1
# if no arg is given (or the path given is not a dir) then
# we assume this script is launched from within the PROJECT_ROOT
[[ -d "$PROJECT_ROOT" ]] || PROJECT_ROOT=$( pwd )

DOCUMENT_ROOT=$PROJECT_ROOT/public

[[ -d "$DOCUMENT_ROOT" ]] || err_exit $LINENO "Assumed we are in the project root; turns out we are not"



# init vars
WWW_USER=www-data
SVN_ROOT=/var/local/svn
REPO_PATH=$SVN_ROOT/documents
REPO_URL=svn://localhost/documents
SVN_DEFAULT_USERNAME=$WWW_USER
SVN_DEFAULT_PASSWORD="tinymce"


# install required packages
apt-get update
apt-get -y install unzip
apt-get -y install subversion apache2 php5 php5-svn

service apache2 restart


# configure SVN
echo "store-plaintext-passwords = no" >> /etc/subversion/servers


## setup 3rd party components
mkdir -p $PROJECT_ROOT/libs $PROJECT_ROOT/public/js

rm -rf $PROJECT_ROOT/libs/*
cd $PROJECT_ROOT/public &&
  rm -rf js fonts css

cd $PROJECT_ROOT/3rdparty &&
  TMP_DIR=$(mktemp -d /tmp/documents-versioner.XXXXXXXXXX)
  unzip -qq '*.zip' -d $TMP_DIR &&
  cd $TMP_DIR &&
    mv dist/* $PROJECT_ROOT/public &&
    mv tinymce/js/* $PROJECT_ROOT/public/js &&
    mv jquery.min.js $PROJECT_ROOT/public/js &&
    mv html2pdf_v4.03 $PROJECT_ROOT/libs/html2pdf &&
echo -e "\n - successfully setup the 3rd party components\n" ||
  err_exit $LINENO "Failed while trying to setup the 3rd party components"



## setup the SVN repo for versioning the documents
mkdir -p $SVN_ROOT &&
svnadmin create $REPO_PATH &&
echo "$SVN_DEFAULT_USERNAME = $SVN_DEFAULT_PASSWORD" >> $REPO_PATH/conf/passwd &&
cat > $REPO_PATH/conf/svnserve.conf <<EOF
[general]
anon-access = none
auth-access = write
password-db = passwd
realm = My Documents Repo

EOF
echo -e "\n - SVN repository created in $REPO_PATH\n" || err_exit $LINENO "Failed while trying to setup the SVN repository in $REPO_PATH"

svnserve -d -r $SVN_ROOT --listen-host=127.0.0.1 || print_err $LINENO "WARN: spawning svnserve daemon failed"



## checkout a wc to be used by documents-versioner
rm -rf $PROJECT_ROOT/documents
mkdir -p $PROJECT_ROOT/documents

svn co -q $REPO_URL $PROJECT_ROOT/documents --username $SVN_DEFAULT_USERNAME --password $SVN_DEFAULT_PASSWORD &&
echo -e "\n - SVN working copy succesfully checked out in $PROJECT_ROOT/documents\n" ||
  err_exit $LINENO "Failed while trying to check out a WC in $PROJECT_ROOT/documents"

echo
echo "Now you have:"
echo " - a SVN repo in $REPO_PATH"
echo " - a working copy in $PROJECT_ROOT/documents"
echo " - the app documents-versioner in $PROJECT_ROOT"
echo
echo "You are now ready to play with the app by browsing to"
echo "(on your local machine, not this VM)"
echo "http://127.0.0.1:8080/documents-versioner/public/"
echo

exit 0
