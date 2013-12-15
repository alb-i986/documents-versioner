<?php

  require('../src/conf.php');


  if ( empty($_GET['format']) || empty($_GET['docname']) ) {
    echo "err: input missing.";
  } else {

    $doc_name = $_GET['docname'];
    $filename = $doc_name . '.html';
    $filepath = $DOCUMENTS_DIR . '/' . $filename;
    $doc_content = file_get_contents($filepath);
    $doc_content_plaintxt = strip_tags($doc_content);

    switch ($_GET['format']) {
      
      case 'pdf':
        try {
          $html2pdf = new HTML2PDF('P','A4','it');
          $html2pdf->WriteHTML($doc_content);
          $html2pdf->Output($doc_name.'.pdf');          
        } catch(Exception $e) {
          echo "<b>Exception</b>: $e";
        }
        break;
      
      default:
        break;
    }
  }
