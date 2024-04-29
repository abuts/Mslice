function mslice_mex(option)
% Create mex files for all the mslice fortran routines
%
%   >> mslice_mex         -- this should automatically produce the 
%
%
%   If the default options do not work, then the original_32 option may compile
%  correctly and be a quick-fix solution to the problem. 
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
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

% %----------------------------------------------------------------
% function mex_single (in_dir, out_dir, flname)
% % mex a single file, with the input and output directories
% % relative to the current directory
% flname = fullfile(in_dir,flname);
% outdir = fullfile(out_dir,'');
% [f_path,f_name]=fileparts(flname);
% targ_file=fullfile(f_path,[f_name,'.',mexext]);
% if(exist(targ_file,'file'))
%     try
%         delete(targ_file)
%     catch
%         error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
%     end
% end
% 
% disp(['Mex file creation from ',flname,' ...'])
% mex(flname,'-outdir',outdir);
% %mex flname -v COMPFLAGS="\$COMPFLAGS -free" '-outdir' ./


%%----------------------------------------------------------------
function mex_single (in_rel_dir, out_rel_dir, varargin)
% Usage:
% mex_single (in_rel_dir, out_rel_dir, varargin)
%
% mex a set of files to produce a single mex file, the file with the mex
% function has to be first in the  list of the files to compile
%

curr_dir = pwd;
if(nargin<1)
    error('MEX_SINGLE:invalid_arg',' request at leas one file name to process');
end
nFiles   = (nargin-2);  % files go in varargin
nCells   = 2*nFiles-1;
add_files=cell(nCells,1);
add_fNames=cell(nCells,1);
outdir = fullfile(curr_dir,out_rel_dir);
for i=1:nCells
    if((i/2-floor(i/2))>0) % fractional part
        add_files{i} = fullfile(curr_dir,in_rel_dir,varargin{floor(i/2)+1});
        add_fNames{i}=varargin{floor(i/2)+1};
    else
        add_files{i}  = ' ';
        add_fNames{i} = ' ';
    end
end
short_fname = cell2str(add_fNames);
disp(['Mex file creation from ',short_fname,' ...'])

if ~check_access(outdir,add_files{1})
    error('MEX_SINGLE:invalid_arg',' can not get write access to new mex file: %s',fullfile(outdir,add_files{1}));
end
if(nFiles==1)
    fname      = add_files{1};
    mex(fname, '-outdir', outdir);
else
    flname1 = add_files{1};
    flname2 =  cell2str(add_files{3:nCells});

    mex(flname1,flname2, '-outdir', outdir);
end

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


function str = cell2str(c)
%CELL2STR Convert cell array into evaluable string.
%
%   See also MAT2STR


if ~iscell(c)

   if ischar(c)
      str = c;
   elseif isnumeric(c)
      str = mat2str(c);
   else
      error('Illegal array in input.')
   end

else

   N = length(c);
   if N > 0
      if ischar(c{1})
         str = c{1};
         for ii=2:N
            if ~ischar(c{ii})
               error('Inconsistent cell array');
            end
            str = [str,c{ii}];
         end
      else
         error(' char cells requested');
      end
   else
      str = '';
   end

end

function access =check_access(outdir,filename)

[spath,sfname] = fileparts(filename);
fname = fullfile(outdir,[sfname,'.',mexext()]);

if exist(fname,'file')
    try
        delete(fname);
        access = true;               
    catch
        access = false;       
    end    
else
    h=fopen(fname,'w+');
    if h<3
        access = false;
    else
        if fclose(h)~=0
            error('MEX_SINGLE:invalid_arg',' can not close opened test file: %s',fname);
        end
        delete(fname);
        access = true;
    end
end

