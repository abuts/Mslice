%
% $Revision$ ($Date$)
%
% To change locations etc. edit this file - ..\homer_standalone\src should
% be replaced with wherever source files should go,
% ..\homer_standalone\dist for distribution files, homer is the name of the
% .exe file (and thus ctf file)

% use relative folders so that it's more robust against folder changes.
% ignored. 
if(~strncmpi(computer('arch'),'win',3))
	warning([' this installation kit has not been tested on *nix machines',...
            ' though it can ocasionally work under it after minor modifications']);
end


source_dir  = fileparts(which('mslice_init.m'));
this_dir    = pwd;
if(strcmpi(source_dir,this_dir))
    disp('WARNING!!!: This script can not run from mslice directory; changing directory to one level up');
    cd('../');
    target_dir  = [pwd,filesep,'mslice_standalone'];    
else
    target_dir  = [this_dir,filesep,'mslice_standalone'];    
end

if exist(target_dir,'dir')  % remove target directory and create it again
    rmdir(target_dir,'s');
end
mkdir(target_dir);
%
mslice_src_dir = [target_dir,filesep,'src'];   % code directory (not used but distribuited as reference to look through the code)
mslice_tmp_dir = [target_dir,filesep,'tmp'];   % working directory 
mslice_targ_dir= [target_dir,filesep,'distr'];  % target directory (the directory with for final mslice program to be located)


disp('!===================================================================!')
disp('!==> Preparing MSLICE standalone distributon kit ===================!')
disp('!    Start collecting the mslice  program files ====================!')

% get configuration and clear it to avoid referring to wrong configuration
% in a future
config_folder_nm=get(mslice_root_config,'config_folder_name');
config_folder_ph=get(mslice_root_config,'config_folder_path');
config_folder=fullfile(config_folder_ph,config_folder_nm);
all_config   = fullfile(config_folder,'config.mat');
msl_config   = fullfile(config_folder,'mslice_config.mat');
if exist(all_config,'file')
    delete(all_config);
end
if exist(msl_config,'file')
    delete(msl_config);
end

%
% these are mslice program files in all their subfolders
mslice_dll  = [mslice_src_dir,filesep,'DLL'];
mslice_m1   = [mslice_src_dir,filesep,'mslice'];
mslice_m2   = [mslice_src_dir,filesep,'ISIS_utilities'];
mslice_add1 = [mslice_src_dir,filesep,'mslice_extras'];
mslice_add2 = [mslice_src_dir,filesep,'mslice_more_extras'];
mslice_add3 = [mslice_src_dir,filesep,'admin'];
%
if exist(mslice_src_dir,'dir')  % source directory;
     rmdir(mslice_src_dir,'s');
end
% create src folder;
mex_files_extention =  mexext;
copy_files_list([source_dir,filesep,'DLL'], mslice_dll,mex_files_extention); 
copy_files_list([source_dir,filesep,'mslice'],mslice_m1,'.m'); 
copy_files_list([source_dir,filesep,'ISIS_utilities'],mslice_m2,'.m'); 
copy_files_list([source_dir,filesep,'mslice_extras'],mslice_add1,'.m'); 
copy_files_list([source_dir,filesep,'mslice_more_extras'],mslice_add2,'.m'); 
copy_files_list([source_dir,filesep,'admin'],mslice_add3,'.m'); 
% the files which will not be necessary for stand-alone but will be used
% during installation:
%copyfile([source_dir,filesep,'mslice_setup_examples.m '],[mslice_src_dir,filesep,'mslice_setup_examples.m ']);
%copyfile([source_dir,filesep,'mslice_off.m'],[mslice_src_dir,filesep,'mslice_off.m']);
%
disp('!    Start collecting the mslice Data and Setup files ==============!')

% copy auxiliary files into the destination  except m-files into distributive
copy_files_list([source_dir,filesep,'Data'],[mslice_targ_dir,filesep,'Data']); 
copyfile(fullfile(source_dir,'mslice','help.txt'),mslice_targ_dir,'f');
copyfile(fullfile(source_dir,'mslice','coltab.dat'),mslice_targ_dir,'f');

copyfile(fullfile(source_dir,'mslice_manual.pdf'),mslice_targ_dir,'f');
%copy_files_list(source_dir,mslice_dist_dir,'-.m');


% create working directory
if exist(mslice_tmp_dir,'dir')  
     rmdir(mslice_tmp_dir,'s');    
end
mkdir(mslice_tmp_dir);


disp('!    The mslice program and data files collected successfully ======!')
disp('!    Start compiling mslice ========================================!')

cd(target_dir);

% compile into source folder

% mcc -o <name of .exe file> -W 'main' -d <folder location to put .exe and
% .ctf files> -T 'link:exe' -v -N <name of mfile to compile (can omit '.m')>
%mcc -o 'mslice' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice.m'
%msliceFileString=['-o  mslice -W main -d  ''',mslice_tmp_dir,''''];
%BundleFileString=['-o  homer -W main -d  ''',homer_tmp_dir,''' -a ''',homer_src_DLL,''' -T link:exe -v -N ',Homer_GUI];
mslice_main= 'mslice.m';
msliceFileString=['-v -o  mslice -W main -d  ''',mslice_tmp_dir,...
                ''' -a ''',mslice_m1,''' -a ''',mslice_m2,''' -a ''',mslice_add1,''' -a ''',mslice_add2,''' -a ''',mslice_add3,''' -a ''',mslice_dll,...
                ''' -T link:exe -v -N ',mslice_main];
%
%
fid = fopen('MCC_msliceString.txt', 'w');
fwrite(fid, msliceFileString);
fclose(fid);



%------------------------------>
mcc -B 'MCC_msliceString.txt'   %
%<-----------------------------
delete('MCC_msliceString.txt');
%disp('!    Start compiling auxiliary utilites ============================!')
% build the utility to modify the set-up files. Unnecessary, but let it
% be if it is already here. 
%------------------------------>
%mcc -o 'mslice_setup_examples' -W 'main' -d './tmp' -T 'link:exe' -v -N 'mslice_setup_examples.m'
%<-----------------------------
%disp('!    Compilation completed: Copying results to target directory ====!')
% THE MOST IMPORTANT PART - copy over the mslice exe files.
if ispc
    copyfile([mslice_tmp_dir,filesep,'*.exe'],mslice_targ_dir,'f');
else
    copyfile([mslice_tmp_dir,filesep,'mslice'],mslice_targ_dir,'f');    
end

% remove leftovers 
if exist(mslice_dll,'dir')  % remove DLL directory (it is no use to standalone source
    rmdir(mslice_dll,'s');
end
if exist(mslice_tmp_dir,'dir')
    rmdir(mslice_tmp_dir,'s')
end
if exist(mslice_src_dir,'dir')
    movefile([mslice_src_dir,filesep,'*'],[mslice_targ_dir,filesep,'src']);
    rmdir(mslice_src_dir,'s');
end

    


cd(target_dir);

% get and copy the mcr installer.
MCR_folder = computer('arch');
if(strncmpi(MCR_folder,'win',3))
    MCRInstaller= 'MCRInstaller.exe';
else
    MCRInstaller= 'MCRInstaller.bin';    
end
MCRstring = fullfile(matlabroot, 'toolbox','compiler','deploy',MCR_folder);
copyfile(fullfile(MCRstring,MCRInstaller),fullfile(mslice_targ_dir,MCRInstaller),'f')

disp('====> compressing mslice distribution together with installer ======!')
zip(['mslice_standalone_kit_',MCR_folder,'.zip'],[mslice_targ_dir,'/*'])
% remove unecessary  files.
disp('====> deleting intermediate and temporary files ====================!')
rmdir(mslice_targ_dir,'s')


% Give a confirmation text file for this
disp('====> ALL DONE =====================================================!')
tstamp = clock;
datestr = [' mslice Compiled Successfully On   ' num2str(tstamp(3)) '/' num2str(tstamp(2)) '/' num2str(tstamp(1)) '   at time  ' num2str(tstamp(4)) ':' num2str(tstamp(5)) ':' num2str(tstamp(6))];
disp(datestr);
disp('====================================================================!')
fid = fopen('mslice_completed.txt', 'w');

fwrite(fid, datestr);

fclose(fid);
cd(this_dir);