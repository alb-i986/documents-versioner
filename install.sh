#!/bin/bash
#
# particularly designed for Debian

print_err() {
  lineno=$1
  errmsg=$2
  {
    echo
    echo "    err at line #${lineno}: $errmsg"
    echo
  } >&2
  return 0
}

err_exit() {
  lineno=$1
  errmsg=$2

  print_err $lineno "$errmsg"
  exit 1
}

check_cmd() {
  cmd=$1

  which "$cmd" >/dev/null || err_exit $LINENO "command $cmd is not on PATH"
  return 0
}



## check preconditions
check_cmd "svn"
check_cmd "svnserve"
check_cmd "svnadmin"
check_cmd "ss" # a precondition in order to check another precondition: dumb!
[[ $( ss -ln | awk '{print $4}' | grep ':3690' | wc -l ) = "0" ]] || err_exit $LINENO "port 3690 already used"


# if no arg is given, we assume this script is launched from within the PROJECT_ROOT
[[ -n "$1" ]] && PROJECT_ROOT=$1 || PROJECT_ROOT=$( pwd )



WWW_USER=www-data
SVN_ROOT=~/svn
REPO_PATH=$SVN_ROOT/documents
REPO_URL=svn://localhost/documents
SVN_DEFAULT_USERNAME="$WWW_USER"
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
echo -e "\n - successfully setup the 3rd party components\n" || err_exit $LINENO "Failed while trying to setup the 3rd party components"

[[ -f /etc/debian_version ]] && sudo apt-get install php5-svn



## setup the SVN repo for versioning the documents
mkdir -p $SVN_ROOT &&
svnadmin create $REPO_PATH &&
cat > $REPO_PATH/conf/svnserve.conf <<EOF
[general]
anon-access = none
auth-access = write
password-db = passwd
realm = My Documents Repository

EOF

echo "$SVN_DEFAULT_USERNAME = $SVN_DEFAULT_PASSWORD" >> $REPO_PATH/conf/passwd &&
svnserve -d -r $SVN_ROOT --listen-host=127.0.0.1 &&
echo -e "\n - SVN repository created in $REPO_PATH\n" || err_exit $LINENO "Failed while trying to setup the SVN repository in $REPO_PATH"


## checkout a wc for the application
svn co -q $REPO_URL $PROJECT_ROOT/documents --username $SVN_DEFAULT_USERNAME --password $SVN_DEFAULT_PASSWORD &&
sudo chown -R ${WWW_USER} $PROJECT_ROOT/documents &&
echo -e "\n - SVN working copy succesfully checked out in $PROJECT_ROOT/documents\n" || err_exit $LINENO "Failed while trying to check out a WC in $PROJECT_ROOT/documents"
