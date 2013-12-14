<?php
/**
  index.php builds the HTML with everything but the content
  i.e. deals with 'html', 'head' and 'body' tags
*/

  require('../src/conf.php');
  require( $LIBS_ROOT . '/glip/glip.php');


  if ( empty($_GET['page']) ) {
    $page = 'start';
  } else {
    $page = $_GET['page'];
  }

?>
<html>

<head>

<!-- <script src="//tinymce.cachefly.net/4.0/tinymce.min.js"></script> -->
<script src="js/tinymce/tinymce.min.js"></script>

<script type="text/javascript">
  tinymce.init({
    selector: "textarea#document-content",
    theme: "modern",
    width: 700,
    height: 300,
    plugins: [
         "advlist autolink link image lists charmap print preview hr anchor pagebreak spellchecker",
         "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
         "save table contextmenu directionality emoticons template paste textcolor"
   ],
   toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | print preview media fullpage | forecolor backcolor emoticons", 
  });
</script>

</head>

<body>


<?php
  $path_to_page_script = $SRC_ROOT . '/' . $page . '.php';
  if ( ! include($path_to_page_script) ){
    echo '<h1>404 Page not found</h1>';
    echo $path_to_page_script;
  }
?>


</body>
</html>