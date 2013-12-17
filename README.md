documents-versioner
===================

A simple web UI for versioning documents, exploiting SVN and TinyMCE.

A document is saved in the repository as an HTML document, but the format is transparent to the user as he/she interacts with TinyMCE, a WYSIWYG editor which happens to save the edited text as HTML.


Components
----------

- TinyMCE as WYSIWYG editor
- SVN as VCS
- (opt.) WebSVN as repo browser
- html2pdf as PDF converter


Features
--------

- create/edit versioned HTML documents (only @HEAD at the moment)
- save documents as PDF



Directory Structure
-------------------

- documents/: the working copy with the versioned documents
- libs/: 3rd party libraries
  + html2pdf/
- public/: the DocumentRoot to be served by your web server
- src/
  
