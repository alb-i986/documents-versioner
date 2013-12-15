<?php

$SRC_ROOT = __DIR__;
$PROJECT_ROOT = realpath( $SRC_ROOT . '/..' );

$SRC_ROOT = realpath( $PROJECT_ROOT . '/src' );
$LIBS_ROOT = realpath( $PROJECT_ROOT . '/libs' );
$PUBLIC_ROOT = realpath( $PROJECT_ROOT . '/public' );



## Domain constants

#$REPOS_ROOT = '/var/local/git';
#$REPO_DIR = $REPOS_ROOT . '/documents';

$DOCUMENTS_DIR = realpath( $PROJECT_ROOT . '/documents' );

$SVN_USERNAME = 'www-data';
$SVN_PASSWORD = 'tinymce';

require_once('/usr/share/php/fpdf.php');
require_once($LIBS_ROOT . '/glip/glip.php');
require_once($LIBS_ROOT .'/html2pdf/html2pdf.class.php');
