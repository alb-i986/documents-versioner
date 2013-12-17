<?php

$SRC_ROOT = __DIR__;
$PROJECT_ROOT = realpath( $SRC_ROOT . '/..' );
$LIBS_ROOT = realpath( $PROJECT_ROOT . '/libs' );
$PUBLIC_ROOT = realpath( $PROJECT_ROOT . '/public' );


## importing 3d parties libraries

require_once($LIBS_ROOT .'/html2pdf/html2pdf.class.php');


## Domain constants

$DOCUMENTS_DIR = realpath( $PROJECT_ROOT . '/documents' );

$SVN_USERNAME = 'www-data';
$SVN_PASSWORD = 'tinymce';
