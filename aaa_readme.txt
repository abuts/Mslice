===============================================================================
 Mslice installation                      (T.G.Perring 8 July 2007, 3 Sep 2009)
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


(3) After editing your startup.m, start matlab, then type
	>> mslice_setup_examples

    Alternatively, if you haven't run the modified startup.m, set the current directory
   in matlab to the mslice home directory:
	>> cd c:\mprogs\mslice

   or for the other example installation:
	>> cd d:\matlab_stuff\mslice

   and then type:
	>> mslice_setup_examples

    This step is required for the example files within mslice to work. You only need
   to do this once, at the time of installation of mslice.




   [ *** If running the standalone version, run the mslice_examples.exe file *** ]

 


NOTE:
     It should not be necessary to recompile the mex files, but if this does happen 
    (for example, you install a later version of Matlab that requires a different
    format for the compiled files), then:

    After editing your startup.m, start matlab, then type
	 >> mslice_mex

    Alternatively, if you haven't run the modified startup.m, set the current directory
   in matlab to the mslice
	 >> cd c:\mprogs\mslice

    or for the other example installation:
	 >> cd d:\matlab_stuff\mslice

    and then type:
	 >> mslice_mex



===============================================================================
 Contents of the three subfolders
===============================================================================

\mslice
========================
The code as distributed by Radu Coldea, but with a number of modifications
to enhance functions or minor corrections. Some of these enhancements are
required to use the mslice_extras functions (below)



\mslice_extras
==============

New functions that add functionality to mslice. See the word document
'mslice extra utilities.doc' in this sub-folder



\mslice_more_extras
===================

Further functions that add functionality to mslice, mostly easing the use
of mslice from the command line when operating in single crystal PSD mode.
The 3D viewing option requires that one of mgenie or Libisis is installed.



