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



Setup
-----

For a straightforward hassle-free setup of the app, there's a `Vagrantfile` for you, guys.

As long as you have [VirtualBox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com) on your machine, just run `vagrant up` and in a few minutes you will be ready to go.

The following operations will be performed:
- if you don't already have it, the official vagrant box with a clean install of ubuntu precise 32bit will be downloaded from files.vagrantup.com (this step may take a while)
- provision a VM from that vagrant box
- run a bash script (`vagrant_provisioner.sh`) which will set the VM up for running our app:
  - install apache, PHP, subversion
  - setup a SVN repository for versioning your documents
  - setup this app

The final result will be an ubuntu VM running in the background.
To start playing with the app you just need to open your favorite browser and go to http://127.0.0.1:8080/documents-versioner/public.

For those of you who do not know [Vagrant](http://www.vagrantup.com), I highly recommend to have a look at it and give it a try.
It's a simple but powerful command-line tool that acts as an interface to VirtualBox (amongst other hypervisors), making the process of provisioning local VMs straightforward.
