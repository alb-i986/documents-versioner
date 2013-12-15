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
        $html2pdf = new HTML2PDF('P','A4','it');
        $html2pdf->WriteHTML($doc_content);
        $html2pdf->Output($doc_name.'.pdf');

      /*

        try {
          $pdf = new FPDF();
          $pdf->AddPage();
          $pdf->SetFont('Arial','B',16);
          $pdf->Cell(0, 0, $doc_content_plaintxt);
          $pdf->Output($doc_name, 'D');
        }
        catch (Exception $e) {
          die($e);
        }
        */
        break;
      
      default:
        break;
    }
  }
