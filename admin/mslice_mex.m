function mslice_mex(option)
% Create mex files for all the mslice fortran routines
%
%   >> mslice_mex         -- this should automatically produce the 
%
%
%   If the default options do not work, then the original_32 option may compile
%  correctly and be a quick-fix solution to the problem. 
%
%   $Rev$ ($Date$)
%
start_dir=pwd;
% root directory is assumed to be that in which mslice_init resides
rootpath = fileparts(which('mslice_init'));
cd(rootpath)

user_choice = disp_compiler_dialog();
if user_choice=='e'
    disp('!  canceled                                                        !')        
    disp('!==================================================================!')    
    return;
end

if user_choice=='y'
    % Prompt for fortran compiler
    disp('!==================================================================!')
    disp('! please, select your FORTRAN compiler  ===========================!')
    mex -setup
end
% Source code directories, and output directories:
%  - mslice target directrory:
mslice_mex_target_dir=fullfile(rootpath,'core','DLL');
%  - mslice extras directory:
mslice_code_dir_base  =fullfile(rootpath,'_LowLevelCode');

% choose the code version

code_kind = '32and64after7.4';
mslice_fortcode_rel_dir= fullfile(mslice_code_dir_base,code_kind);
mslice_Ccode_dir       = fullfile(mslice_code_dir_base ,code_kind);

try   
    
     if user_choice ~= 'c'
			cd(mslice_fortcode_rel_dir);
            mex_single ('./', './', 'avpix_df.F90')
            mex_single ('./', './', 'cut2d_df.F90')
            mex_single ('./', './', 'cut3d_df.F90')
            mex_single ('./', './', 'cut3dxye_df.F90')
            mex_single ('./', './', 'load_spe_df.F90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'ms_iris.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'put_spe_fortran.f90')
            mex_single ('./', './', 'slice_df.F90')
            mex_single ('./','./', 'spe2proj_df.F90')
            mex_single ('./', './', 'slice_df_full.F')            

			copy_files_list(pwd,mslice_mex_target_dir,mexext);
            delete(['./*.',mexext]);
                        
            cd(start_dir);
    end            

    if user_choice=='y'
        % Prompt for C compiler, and compile all C code    
        disp('!==================================================================!')
        disp('! please, select your C compiler ==================================!')
        mex -setup
    end
    if user_choice ~= 'f'
        cd(mslice_Ccode_dir);
        mex_single ('./', './', 'ffind.c')
        mex_single ('./', './', 'get_ascii_file.cpp','IIget_ascii_file.cpp')
        
        copyfile([mslice_Ccode_dir,filesep,'*.',mexext],mslice_mex_target_dir);        
        delete(['./*.',mexext]);
    end
    
    cd(start_dir);
    display (' ')
    disp('!==================================================================!')
    disp('!  Succesfully created all required mex files =====================!')
    disp('!==================================================================!')    
    display(' ')
    
catch
   cd(start_dir);
   rethrow(lasterror)
end

%----------------------------------------------------------------
function mex_single (in_dir, out_dir, flname)
% mex a single file, with the input and output directories
% relative to the current directory
flname = fullfile(in_dir,flname);
outdir = fullfile(out_dir,'');
[f_path,f_name]=fileparts(flname);
targ_file=fullfile(f_path,[f_name,'.',mexext]);
if(exist(targ_file,'file'))
    try
        delete(targ_file)
    catch
        error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
    end
end

disp(['Mex file creation from ',flname,' ...'])
mex(flname,'-outdir',outdir);
%mex flname -v COMPFLAGS="\$COMPFLAGS -free" '-outdir' ./

function choice=disp_compiler_dialog()
% -----------------------------------------------------
disp('!==================================================================!')
disp('! Would you like to select your compilers (win) or have configured !')
disp('! your compiler yourself?:  y/n/c/f/e                              !')
disp('! y-select and configure;  n - already configured                  !')
disp('! c or f allow you to build C or FORTRAN part of the program       !')
disp('!        having configured proper compiler yourself                !')
disp('!------------------------------------------------------------------!')
disp('! If you are going to build standalone version, the compiler has to!')
disp('! be configured for static linkage (e.g. /MT for VS C compiler or  !')
disp('! /libs:static for ifort compiler)                                 !')
disp('!------------------------------------------------------------------!')
disp('! e -- cancel (end)                                                !')
user_entry=input('! y/n/c/f/e :','s');
user_entry=strtrim(lower(user_entry));
choice  = user_entry(1);
disp(['!===> ' choice,' choosen                                                    !']);
disp('!==================================================================!')
if ~(choice=='y'||choice=='n'||choice=='c'||choice=='f')
    choice='e';
end
