function mslice_mex(option)
% Create mex files for all the mslice fortran routines
%
%   >> mslice_mex(option)
%
%   option      Architecture:
%                   '32', 'mac_32', '64' or 'original_32' . 
%               This uses files from the '32bit', '64bit' or original 32 bit
%               fortran code directory respectively.
%
%   If the 32 or 64 options do not work, then the original_32 option may compile
%  correctly and be a quick-fix solution to the problem. 
%
%   Checked to work with R2007a, windows original 32bit

if ~exist('option','var')
    error('Must give installation option (''32'',''mac_32'',''64'',''original_32'')')
end

start_dir=pwd;
try
    % root directory is assumed to be that in which mslice_init resides
    rootpath = fileparts(which('mslice_init'));
    cd(rootpath)

    % Source code directories, and output directories:
    %  - mslice main directory:
    mslice_mex_rel_dir='mslice';
    mslice_fortcode_rel_dir=fullfile('mslice','fortran',[option,'bit']);
    mslice_Ccode_rel_dir='mslice';
    %  - mslice extras directory:
    mslice_extras_mex_rel_dir='mslice_extras';
    mslice_extras_code_rel_dir=fullfile('mslice_extras','fortran');

    % Prompt for fortran compiler, and compile all fortran
    % -----------------------------------------------------
    display('--------------------------------------------------------------')
    display('Please select your FORTRAN compiler')
    mex -setup
    
    switch option
        case 'original_32'
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'avpix_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut2d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3dxye_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'load_spe_df.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'ms_iris.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'put_spe_fortran.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'slice_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'spe2proj_df.F')
            
            mex_single (mslice_extras_code_rel_dir, mslice_extras_mex_rel_dir, 'slice_df_full.F')

        case 'mac_32'
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'avpix_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut2d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3dxye_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'load_spe_df.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'ms_iris.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'put_spe_fortran.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'slice_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'spe2proj_df.F')
        
            % mex_single (mslice_extras_code_rel_dir, mslice_extras_mex_rel_dir, 'slice_df_full.F')

        otherwise
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'avpix_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut2d_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3d_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'cut3dxye_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'load_spe_df.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'ms_iris.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'put_spe_fortran.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'slice_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_rel_dir, 'spe2proj_df.f90')
    
            % mex_single (mslice_extras_code_rel_dir, mslice_extras_mex_rel_dir, 'slice_df_full.f90')

    end

    % Prompt for C compiler, and compile all C code
    % -----------------------------------------------------
    display('--------------------------------------------------------------')
    display('Please select your C compiler')
    mex -setup
    
    mex_single (mslice_Ccode_rel_dir, mslice_mex_rel_dir, 'ffind.c')
    
    cd(start_dir);
    display (' ')
    display('--------------------------------------------------------------')
    display('--------------------------------------------------------------')
    display('Succesfully created all required mex files from fortran and C.')
    display(' ')
    display(' To return to your original mex options, type >> mex -setup')
    display('--------------------------------------------------------------')
    
catch
    cd(start_dir);
    rethrow(lasterror)
end

%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, flname)
% mex a single file, with the input and output directories
% relative to the current directory
curr_dir = pwd;
flname = fullfile(curr_dir,in_rel_dir,flname);
outdir = fullfile(curr_dir,out_rel_dir);

disp(['Mex file creation from ',flname,' ...'])
mex(flname, '-outdir', outdir);
