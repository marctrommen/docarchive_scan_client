# Installation of Scan Client

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

Now you can download the remaining files fo the GitHub project into the 
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
