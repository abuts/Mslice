function mslice_mex(ver, ext)
% Create mex files for all the mslice fortran routines. 
%
% >> mslice_mex('ver', 'ext')
%
% Inputs:
%------------
%
%   'ver'               The subfolder in mslice/fortran to use for the mex
%                       files. e.g. 'win32' or 'win64'. by default 'win32
%                       is used. Any versions may be put into the
%                       subdirectory though
%
%   'ext'               Extension of the fortran files, usually .f90, could
%                       be .f. do not input the dot, i.e. 'f' or 'f90'
%                       Defaults to f90
%
%
% Does NOT mex ffind.c So far Radu's distribution of the dll
% this seems to work with R2007a

if nargin < 1
    ver = 'win32';
    ext = 'f90';
elseif nargin <2
    ext = 'f90';
end

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('mslice_mex'));
    cd(rootpath)
    
    % Now get to the main mslice directory
    cd mslice
    cd Fortran
    cd(ver)
    
    mex(['avpix_df.' ext])
    mex(['cut2d_df.' ext])
    mex (['cut3d_df.' ext])
    mex (['cut3dxye_df.' ext])
    mex (['load_spe_df.' ext])
    mex (['ms_iris.' ext])
    mex (['slice_df.' ext])
    mex (['spe2proj_df.' ext])
    copyfile('*.mex*','../')
    cd ..
    cd ..
    cd ..
    cd mslice_extras
    mex slice_df_full.f
    
    cd(start_dir);
    disp('Succesfully created all required mex files from fortran.')
    
catch
    disp('Problems creating mex files. Please try again.')
    cd(start_dir);
end
