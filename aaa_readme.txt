===============================================================================
 Mslice installation                      (T.G.Perring 8 July 2007, 3 Sep 2009)
 Modified to reflect recent changes        March 2012.
===============================================================================

This folder and sub-folders contain the mslice program of Radu Coldea (in
sub-folder \mprogs), together with some  extra functions that extend the use of mslice
(\mslice_extras and \mslice_more_extras).


To install:
(1) Copy this folder and all its contents to a folder of your choice, typically
   c:\mprogs\mslice, but it could be any other; for example, you could use
   d:\matlab_stuff\mslice.


(2) Edit your startup.m to include the following lines:
    In the case of the conventional destination folder:

        addpath('c:\mprogs\mslice);
        mslice_init

    or, in the case of the example above of another home folder:

        addpath('d:\matlab_stuff\mslice');
        mslice_init




NOTE:
	To verify if mslice mex files work properly, type mslice in matlab command prompt 
	and select "About Mslice-> Quick check mex files correctness." If in Matlab window you 
	see set of messages, which report current versions on different mex files, mex files 
	are at least compartible with your OS. After that select "About Mslice->Self-test Mslice". 
	This would produce number of messages and couple of pictures. If any of these steps fail, 
	you need to recompile mslice. To do that you have to had fortran and C compilers 
	installed in your system and configured accrodingly to Matlab requests. Check Matlab 
	mex -setup command to verify that. 
	Consult Matlab user manual for the details on the compilers compartibility and 
	how to configure your compilers	properly.
   
	If your compilers are configured to work with Matlab properly, compiling mslice is easy. 
    After editing your startup.m, start matlab, (or just execute startup command) and then type:
	 >> mslice_mex

	Verify the results of mexing as described above. 

===============================================================================
 Contents of the three subfolders
===============================================================================

/core
========================
Core code, providing main mslice functionality as in classical mslice 
distributed by Radu Coldea, but with a number of modifications
to enhance functions or minor corrections. 

Majority of its functions allow command line operations, though some 
(and all in /core/mslice_io subfolder) work with mslice graphical window



/applications
==============
contains mslice_gui -- the classical Radu Coldea mslice graphical interface
and number of smaller applications&add-ons 

/utilities 
small functions/methods which provide some complete piece of work useful separately
or used by applications and core functions

/classes 
similar to utilities but oop-oriented

/Data
==================
Examples of data and mslice files, which demonstrate Mslice usage for different
instruments. Keeps also msp templates for different data analysis modes. 

/admin
==================
files mainly used for Mslice package initialization, mexing, testing and support. 






