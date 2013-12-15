<?php

  svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_USERNAME, $SVN_USERNAME);
  svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_PASSWORD, $SVN_PASSWORD);

  # ensure working copy is up to date
  svn_update($DOCUMENTS_DIR);




  $save_mode = !empty($_POST) && !empty($_POST['docname']);


  if ( $save_mode ) { // write mode

    $doc_name = $_POST['docname'];
    $user_commit_msg = $_POST['commit-msg'];
    $filename = $doc_name . '.html';
    $filepath = $DOCUMENTS_DIR . '/' . $filename;
    
    $doc_content = $_POST['content'];
    $doc_content_original = file_get_contents($filepath);

    if ($doc_content == $doc_content_original) {
      echo "content unchanged. not saving.";
    } else {
      if ( file_put_contents($filepath, $doc_content) ) {
        echo "Success. The document $doc_name has been saved.";

        $previously_unversioned = svn_add($filepath);
        $commit_msg = ($previously_unversioned ? 'adding' : 'updating') . " $doc_name" . ( empty($user_commit_msg) ? "" : " - $user_commit_msg" );
        if (svn_commit( $commit_msg, array(realpath($DOCUMENTS_DIR)) ) )
          echo "Success. Changes to $doc_name have been committed.";
        else
          echo "Fail. Changes to $doc_name could not be committed.";
      } else {
        echo "Fail. The file $filename could not be saved.";
      }
    }

  } else { // read mode

    $no_doc_loaded = empty($_GET['doc']);

    if ( ! empty($_GET['doc']) ) {
      $doc_name = $_GET['doc'];
      $filename = $doc_name . '.html';
      $filepath = $DOCUMENTS_DIR . '/' . $filename;
      $doc_content = file_get_contents($filepath);
    }

  }

?>

  <div id="document-selector">
    <form>
      <label>Select document</label>
    <select name="document">
<?php
  $documents = scandir($DOCUMENTS_DIR);
  foreach ($documents as $document) {
?>
      <option><?php echo $document ?></option>
<?php
  }
?>
      </select>
    </form>
    
  </div>



  <div id="document-to-pdf">

    <form method="get" action="saveto.php">
      <input type="hidden" name="docname" value="<?php echo $doc_name ?>"></input>
      <input type="hidden" name="format" value="pdf"></input>
      <input type="submit" value="Save to PDF">
    </form>
    
  </div>


  <div id="document-editor">
    <form method="post" action="?page=documentor">
      
      <textarea name="content" id="document-content">
        <?php echo $doc_content ?>
      </textarea>

      <label>Commit message:</label>
      <textarea name="commit-msg" id="document-commit-msg"></textarea>

<?php
    if ( !$save_mode && $no_doc_loaded ) {
?>
      <input type="submit" value="Save as">
      <input type="textbox" name="docname"></input>

<?php
  } else {
?>
      <input type="submit" value="Save">

      <input type="hidden" name="docname" value="<?php echo $doc_name ?>"></input>
<?php
  }
?>

    </form>
  </div>
