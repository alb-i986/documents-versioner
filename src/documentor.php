<?php

  $documents = scandir($DOCUMENTS_DIR);

?>

<div id="file-selection">
  <form>
    <label>Select document</label>
    <select name="document">
<?php
  foreach ($documents as $doc_name) {
    echo '<option>' . $doc_name . '</option>';
  }

?>
    </select>
  </form>
  

</div>


<?php

  $save_mode = ! empty($_POST);

  if ( $save_mode ) { // write mode

    $html = $_POST['content'];
    $html_original = $_POST['content'];
    $doc_name = $_POST['filename'];
    $filename = $doc_name . '.html';
    #var_dump($filename);
    #var_dump($html);
    #echo "ORIGINAL BEGIN";
    #var_dump($html_original);
    #echo "ORIGINAL END";
    #var_dump($DOCUMENTS_DIR . '/' . $filename);

    if ($html == $html_original) {
      echo "content unchanged. not saving.";
    } else {
      $filepath = $DOCUMENTS_DIR . '/' . $filename;
      if ( file_put_contents($filepath, $html) ) {
        echo "Success. The document $doc_name has been saved.";
        svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_USERNAME, $SVN_USERNAME);
        svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_PASSWORD, $SVN_PASSWORD);
        svn_add($filepath);
        svn_commit("updating $doc_name", array($DOCUMENTS_DIR) );
      } else {
        echo "Fail. The document $doc_name could not be saved.";
      }
    }
    

  } else { // read mode

    if ( ! empty($_GET['doc']) ) {

      svn_update($DOCUMENTS_DIR);

      $doc_name = $_GET['doc'];
      $filename = $doc_name . '.html';
      $html = file_get_contents($DOCUMENTS_DIR . '/' . $filename);
    }

  }


?>


  <div id="document-editor">
    <form method="post" action="?page=documentor">
      
      <textarea name="content" id="document-content">
        <?php echo $html ?>
      </textarea>

<?php
  if ( !$save_mode && ( empty($_GET['doc']) || !$html ) ) {
?>
      <input type="submit" value="Save as">
      <input type="textbox" name="filename">
      <input type="hidden" name="original-content" value="<?php echo $html ?>"></input>


<?php
  } else {
?>
      <input type="submit" value="Save">

      <input type="hidden" name="filename" value="<?php echo $doc_name ?>"></input>
<?php
  }
?>

    </form>
  </div>
