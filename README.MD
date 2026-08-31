This is a Linux based software for using the Quanli Gorilla 6558 themrmal camera with Linux. This is based on the PyThermalCamera code base. https://github.com/leswright1977/PyThermalCamera This has an install script that will make a desktop config file and icon that will allow you to launch from the GUI, I plan to roll this into an appimage at some point but for now it has only been tested on Ubuntu 26.04

Dependencies

Python3 OpenCV Must be installed:

Run: sudo apt-get install python3-opencv


The original repo is broken where the Python Code will not work with the Python Numpy 2.0, so the code has been changed to make it work, it will also autodetect the stream of the camera when launched based on the resolution. This is a work in progress so stay tuned



