function mslice_mex(option)
% Create mex files for all the mslice fortran routines
%
% >> mslice_mex(option)
%
% option is either '32' or '64'. This uses files from the '32bit' or
% '64bit' directory respectively to mex. All .mex* files are put into the
% mslice directory.

% this seems to work with R2007a

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('mslice_mex'));
    cd(rootpath)
    % Now get to the main mslice directory
    cd mslice
    cd([option 'bit'])
    
    
   display('please select your FORTRAN compiler')
   
    mex -setup
    
    mex avpix_df.f90
    mex cut2d_df.f90
    mex cut3d_df.f90
    mex cut3dxye_df.f90
    mex load_spe_df.f90
    %mex ms_iris.f
    mex slice_df.f90
    mex spe2proj_df.f90
    
    copyfile(['*.mex*','..' filesep '..','f'])
    
    cd .. 
    cd .. 
    cd mslice_extras
    mex slice_df_full.f
    
    cd ..
    
    cd mslice
    
    display('please select your C compiler')
    
    mex -setup
    mex ffind.c
    cd(start_dir);
    
    disp('Succesfully created all required mex files from fortran.')
    
catch
    disp('Problems creating mex files. Please try again.')
    cd(start_dir);
end
