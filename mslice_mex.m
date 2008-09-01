function mslice_mex
% Create mex files for all the mslice fortran routines
% Does NOT mex ffind.c So far Radu's distribution of the dll
% this seems to work with R2007a

start_dir=pwd;
try
    % root directory is assumed to be that in which this function resides
    rootpath = fileparts(which('mslice_mex'));
    cd(rootpath)
    % Now get to the main mslice directory
    cd mslice
    cd Fortran
    mex avpix_df.f
    mex cut2d_df.f
    mex cut3d_df.f
    mex cut3dxye_df.f
    mex load_spe_df.f
    %mex ms_iris.f
    mex slice_df.f
    mex spe2proj_df.f
    
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
