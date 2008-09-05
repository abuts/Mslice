function mslice_mex(option)
% Create mex files for all the mslice fortran routines
%
% >> mslice_mex(option)
%
% option is either '32', '64' or 'original_32' . This uses files from the '32bit' or
% '64bit' directory respectively to mex. All .mex* files are put into the
% mslice directory. If the 32 or 64 options do not work, then the
% original_32 option may compile correctly and be a quick-fix solution to
% the problem. 

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
    switch option   % if original_32 then the extension is .f not .f90
        case {'original_32' 'mac_32'}
             mex avpix_df.F
            mex cut2d_df.F
            mex cut3d_df.F
            mex cut3dxye_df.F
            mex load_spe_df.F
            %mex ms_iris.f
            mex slice_df.F
            mex spe2proj_df.F
            
        otherwise
            
            mex avpix_df.f90
            mex cut2d_df.f90
            mex cut3d_df.f90
            mex cut3dxye_df.f90
            mex load_spe_df.f90
            %mex ms_iris.f
            mex slice_df.f90
            mex spe2proj_df.f90
    
    end
    
    copyfile('*.mex*','../','f')
    
    cd .. 
    cd .. 
    cd mslice_extras
    mex slice_df_full.F
    
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
