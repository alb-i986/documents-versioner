<?php

  svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_USERNAME, $SVN_USERNAME);
  svn_auth_set_parameter(SVN_AUTH_PARAM_DEFAULT_PASSWORD, $SVN_PASSWORD);

  # ensure working copy is up to date
  svn_update($DOCUMENTS_DIR);


  $result_html = ''; // for displaying the result of the processing (if any) to the user

  $save_mode = !empty($_POST) && !empty($_POST['docname']);


  if ( $save_mode ) { // write mode

    $doc_name = $_POST['docname'];
    $user_commit_msg = $_POST['commit-msg'];
    $filename = $doc_name . '.html';
    $filepath = $DOCUMENTS_DIR . '/' . $filename;
    
    $doc_content = $_POST['content'];
    $doc_content_original = file_get_contents($filepath);

    if ($doc_content == $doc_content_original) {
      $result_html .= '<div class="alert alert-info">content unchanged. not saving.</div>';
    } else {
      if ( file_put_contents($filepath, $doc_content) ) {
        $result_html .= '<div class="alert alert-success">The document \''.$doc_name.'\' has been saved.</div>';

        $previously_unversioned = svn_add($filepath);
        $commit_msg = ($previously_unversioned ? 'adding' : 'updating') . " $doc_name" . ( empty($user_commit_msg) ? "" : " - $user_commit_msg" );
        if ( svn_commit( $commit_msg, array($DOCUMENTS_DIR) ) )
        $result_html .= '<div class="alert alert-success">Changes to \''.$doc_name.'\' have been committed.</div>';
        else
          $result_html .= '<div class="alert alert-danger">Changes to \''.$doc_name.'\' could not be committed.</div>';
      } else {
        $result_html .= '<div class="alert alert-danger">The file \''.$filename.'\' could not be saved.</div>';
      }
    }

  } else { // read mode

    $no_doc_loaded = empty($_GET['doc']);

    if ( ! empty($_GET['doc']) ) {
      $doc_name = $_GET['doc'];
      $filename = $doc_name . '.html';
      $filepath = $DOCUMENTS_DIR . '/' . $filename;
      $doc_content = file_get_contents($filepath);
      if ($doc_content === FALSE) {
        $result_html .= '<div class="alert alert-danger">Loading document \''.$doc_name.'\' failed ('.$filepath.')</div>';
      } else {
        $result_html .= '<div class="alert alert-success">Document '.$doc_name.' loaded successfully</div>';
      }
    }

  }

?>

    <div id="result">
      <?php echo $result_html ?>
    </div>



    <div id="document-selector">

      <form method="get" action="index.php?page=documentor" role="form">

        <label>Select document</label>
        <select name="doc" class="form-control">
          <option></option>
<?php
  $documents = svn_ls($DOCUMENTS_DIR);
  foreach ($documents as $document) {
    $doc2load = preg_replace('/\.html$/', '', $document['name']);

    if ( !empty($doc_name) && $doc_name == $doc2load ) {
      echo '<option selected="selected">';
    } else {
      echo '<option>';
    }
    echo $doc2load;
?>
        </option>
<?php
  }
?>
        </select>
        <button type="submit" class="btn btn-default">Load document</button>

      </form>
      
    </div>



    <div id="document-editor">
      <form method="post" action="index.php?page=documentor" role="form">

        <textarea name="content" id="document-content" class="form-control">
          <?php echo $doc_content ?>
        </textarea>

        <label for="document-commit-msg">Commit message:</label>
        <textarea name="commit-msg" id="document-commit-msg" class="form-control" placeholder="Describe your changes"></textarea>

<?php
    if ( !$save_mode && $no_doc_loaded ) {
?>
        <button type="submit" class="btn btn-default">Save as</button>
        <input type="textbox" name="docname" placeholder="filename with no extension" class="form-control"></input>

<?php
  } else {
?>

        <button type="submit" class="btn btn-default">Save document</button>

        <input type="hidden" name="docname" value="<?php echo $doc_name ?>"></input>
<?php
  }
?>

      </form>
    </div>



    <div id="document-to-pdf">

      <form method="get" action="download.php">
        <input type="hidden" name="docname" value="<?php echo $doc_name ?>"></input>
        <input type="hidden" name="format" value="pdf"></input>
        <button type="submit" class="btn btn-default">Download as PDF</button>
      </form>
      
    </div>



  
    <script src="js/tinymce/tinymce.min.js"></script>

    <script type="text/javascript">
      tinymce.init({
        selector: "textarea#document-content",
        theme: "modern",
        width: 800,
        height: 500,
        plugins: [
             "advlist autolink autoresize link image lists charmap print preview hr anchor pagebreak spellchecker",
             "searchreplace wordcount visualblocks visualchars code fullscreen insertdatetime media nonbreaking",
             "save table contextmenu directionality template paste textcolor"
       ],
       toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image | print preview media fullpage | forecolor backcolor", 
      });
    </script>
