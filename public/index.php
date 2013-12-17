<?php
/**
  index.php builds the HTML with everything but the content
  i.e. deals mainly with 'html' and 'head' tags
*/

  require('../src/conf.php');


  if ( empty($_GET['page']) ) {
    $page = 'start';
  } else {
    $page = $_GET['page'];
  }

?>
<!DOCTYPE html>
<html>

  <head>
    <title>Documents Versioner</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->


  </head>

  <body>


<?php
  $path_to_page_script = realpath($SRC_ROOT . '/' . $page . '.php');
  if ( ! include($path_to_page_script) ){
    echo '<h1>404</h1>';
    echo 'Page not found';
    #echo $path_to_page_script;
  }
?>

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="js/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="js/bootstrap.min.js"></script>

  </body>
</html>