# README

## Introduction

This *Scan Client* represents one part of a multipart *Document Archive* 
solution.

The *Document Archive* solution exists of

*	a *Scan Client* which is responsible for scanning documents, optimizing the
	scan quality, minimizing the scan files in file size, gathering meta data 
	(e.g. list of keywords to characterize the content of document, 
	document title, document date), creating an unique document id and 
	transforms from single and multipage scanned documents PDF files, enriched 
	with that meta data.

*	a *Web Page Generator* which generates out of the scanned documents and the 
	gathered meta data a static HTML web page. All documents are organized
	in an index organized by two search criterias:

	*	grouped by **year of document date** and then sorted by 
		*descending document date*
	
	*	grouped by **one keyword of the document's keyword list** and then 
		sorted by *descending document date*
	
	Each list entry is linked to one document, represented by it's PDF file.

	That static HTML web page can either browsed locally, filebased with a 
	web browser app (e.g. Google Chrome or Firefox) or hosted on a simple
	web server, which runs with Apache or NGINX or any other simalar web server.

	For detailed information about the *Web Page Generator*, please refer to
	[GitHup: Web Page Generator](https://github.com/marctrommen/docarchive_web_generator)

**Hint**: The content of a document can be characterized not only by one
keyword, but by many keywords, too.


# Installation of Scan Client

## Preconditions / Required Programs

The *Scan Client* uses heavily additional applications. Therefore these 
applications need to get installed as follows:


### Installation of Python3

refer to [FOSS Linux - Your complete guide to installing Python on Debian](https://www.fosslinux.com/122774/your-complete-guide-to-installing-python-on-debian.htm)

```
root@debianvm:~# apt install python3 python3-pip
root@debianvm:~# python3 --version
Python 3.11.2

root@debianvm:~# pip3 --version
pip 23.0.1 from /usr/lib/python3/dist-packages/pip (python 3.11)
```

### GIT client installed?

```
root@debianvm:~# git --version
git version 2.39.2
```

### Installation of `rsync`

```
root@debianvm:~# apt update
root@debianvm:~# apt install rsync
root@debianvm:~# rsync --version
rsync  version 3.2.7  protocol version 31
```

### Installation of `wget`

```
root@debianvm:~# wget --version
GNU Wget 1.21.3 übersetzt unter linux-gnu.
```

### Installation of `curl`

```
root@debianvm:~# curl --version
curl 7.88.1 (x86_64-pc-linux-gnu) ...
```

### Installation of *Linux Scan-Tools*

```
root@debianvm:~# apt install sane
root@debianvm:~# apt install libsane
```

Test of successful installation:

```
root@debianvm:~# scanimage --version
scanimage (sane-backends) 1.1.1-debian; backend version 1.1.1
```

### Installation of `imagemagik`

refer to [How to Install ImageMagick on Debian 12, 11 or 10](https://www.linuxcapable.com/how-to-install-imagemagick-on-debian-linux/)

```
root@debianvm:~# apt install libpng-dev libjpeg-dev libtiff-dev
root@debianvm:~# apt install imagemagick
```

Test of successful installation:

```
root@debianvm:~# convert --version
Version: ImageMagick 6.9.11-60 Q16 x86_64 2021-01-25 https://imagemagick.org
...
```

### Installation of `dialog`

```
root@debianvm:~# apt install dialog
```

Test of successful installation:

```
root@debianvm:~# dialog --version
Version: 1.3-20230209
```


## Installing the Scan Support for locally used Scanners

For details on *Installing the scan support for your scanner* please refer to
[Scanner Installation and Configuration](./doc/scanner_installation_configuration.md).


## Minimal Requirements

The minimal requirements for the Scan_Client application are:

*	Python is installed in Version 3.7 or higher.

	In the following installation example I assume Python 3.8.
	
	For Python download and installation instructions, please refer to
	https://wiki.python.org/moin/BeginnersGuide/Download.

*	*PIP* is available. If not, install it with the following command:

		$> $ python -m ensurepip --upgrade

	For further details, please refer to 
	https://pip.pypa.io/en/stable/installation/

*	*Virtual Environment* is available. If not, install it with:

		$> pip install --user virtualenv

*	`dialog` is available. If not install it with the following command 
	(example for Debian Linux):
	
		$> sudo apt update
		$> sudo apt install dialog
		$> dialog --version
	
	You should get an output similar to this
	
		Version: 1.3-20160828

	Please refer to 
	[article on O'Reilly](https://www.oreilly.com/library/view/learning-linux-shell/9781785286216/ch10s06.html)


## Creating a Virtual Environment for the Scan_Client Application

For working in an isolated environment for the Scan_Client application, please 
create a virtual environment somewhere in your `$HOME` directory.

		$> virtualenv --python=python3.8 scan_client

Activate the environment:

		$> cd scan_client
		$> source bin/activate

Then check the availability of the right Python version:

		$> python --version
		Python 3.8.0

Then check if `pip` is available:

	$> python -m ensurepip --upgrade

You should get an output similar to this:

	Looking in links: /tmp/tmpok5o5sn_
	Requirement already up-to-date: setuptools in ./lib/python3.8/site-packages (60.3.1)
	Requirement already up-to-date: pip in ./lib/python3.8/site-packages (21.3.1)


## Installing the required Python Libraries for the Scan_Client Application

Download the `requirements.txt` file from the GitHub project and place it in
the root directory of the freshly created virtual environment. Then install the
required Python libraries:

	$> pip install -r requirements.txt

You should get an output similar to this

	Collecting fpdf==1.7.2
	  Using cached fpdf-1.7.2-py2.py3-none-any.whl
	Collecting numpy==1.19.0
	  Using cached numpy-1.19.0-cp38-cp38-manylinux2010_x86_64.whl (14.6 MB)
	Collecting Pillow==7.2.0
	  Using cached Pillow-7.2.0-cp38-cp38-manylinux1_x86_64.whl (2.2 MB)
	Collecting scipy==1.5.1
	  Using cached scipy-1.5.1-cp38-cp38-manylinux1_x86_64.whl (25.8 MB)
	Installing collected packages: numpy, scipy, Pillow, fpdf
	Successfully installed Pillow-7.2.0 fpdf-1.7.2 numpy-1.19.0 scipy-1.5.1


## Download and Configuration of the Scan_Client Application

Now you can download the remaining files of the GitHub project into the 
virtual environment.

Following files need to be changed with an text editor of your choice 
(e.g. vim):

*	`scanapp.desktop`

	Edit the following lines:
	
		Exec=/path/to/scan_client/run.sh
		Icon=/path/to/scan_client/scan_app.png
		Path=/path/to/scan_client

*	`run.sh`

	Edit the following line:
	
		PROJECT_DIR=/path/to/scan_client

*	`config_handler.sh`

	Edit the following line:

		SCAN_ARCHIVE_BASE_DIRECTORY="/path/to/document_archive"
