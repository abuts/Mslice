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

mkdir(target_dir);
mslice_src_dir = [target_dir,filesep,'src'];   % code directory
mslice_tmp_dir = [target_dir,filesep,'tmp'];   % working directory
mslice_dist_dir= [target_dir,filesep,'distr']; % target directory


disp('!===================================================================!')
disp('!==> Preparing MSLICE standalone distributon kit ===================!')
disp('!    Start collecting the mslice  program files ====================!')
% these are mslice program files in all their subfolders
mslice_dll =  [mslice_src_dir,filesep,'DLL'];
mslice_m1   = [mslice_src_dir,filesep,'mslice'];
mslice_add1 = [mslice_src_dir,filesep,'mslice_extras'];
mslice_add2 = [mslice_src_dir,filesep,'mslice_more_extras'];
%
if exist(mslice_src_dir,'dir')  % source directory;
     rmdir(mslice_src_dir,'s');
end
mex_files_extention =  mexext;
copy_files_list([source_dir,filesep,'DLL'], mslice_dll,mex_files_extention); 
copy_files_list([source_dir,filesep,'mslice'],mslice_m1,'.m'); 
copy_files_list([source_dir,filesep,'mslice_extras'],mslice_add1,'.m'); 
copy_files_list([source_dir,filesep,'mslice_more_extras'],mslice_add2,'.m'); 
% the files which will not be necessary for stand-alone but will be used
% during installation:
copyfile([source_dir,filesep,'mslice_setup_examples.m '],[mslice_src_dir,filesep,'mslice_setup_examples.m ']);
%copyfile([source_dir,filesep,'mslice_off.m'],[mslice_src_dir,filesep,'mslice_off.m']);
%
disp('!    Start collecting the mslice Data and Setup files ==============!')
% we gather this files directrly into the targed directory
if exist(mslice_dist_dir,'dir')  % target directory
     rmdir(mslice_dist_dir,'s');
end

% copy everything except m-files into distributive
copy_files_list(source_dir,mslice_dist_dir,'-.m');

% remove leftovers
if exist([mslice_dist_dir,filesep,'DLL'],'dir')  % remove DLL directory (to many bothering to avoid copying it)
    rmdir([mslice_dist_dir,filesep,'DLL'],'s');
end
if exist([mslice_dist_dir,filesep,'ISIS_utilities'],'dir')  % remove ISIS_utilities directory (to many bothering to avoid copying it)
    rmdir([mslice_dist_dir,filesep,'ISIS_utilities'],'s');
end

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
msliceFileString=['-o  mslice -W main -d  ''',mslice_tmp_dir,...
                ''' -a ''',mslice_m1,''' -a ''',mslice_add1,''' -a ''',mslice_add2,''' -a ''',mslice_dll,...
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
disp('!    Start compiling auxiliary utilites ============================!')
% build the utility to modify the set-up files. Unnecessary, but let it
% be if it is already here. 
%------------------------------>
mcc -o 'mslice_setup_examples' -W 'main' -d './tmp' -T 'link:exe' -v -N 'mslice_setup_examples.m'
%<-----------------------------
disp('!    Compilation completed: Copying results to target directory ====!')
% THE MOST IMPORTANT PART - copy over the mslice exe and ctf files.
copyfile([mslice_tmp_dir,filesep,'*.exe'],[mslice_dist_dir,filesep,'mslice'],'f');
try
    copyfile([mslice_tmp_dir,filesep,'*.cft'],mslice_m1,'f');
catch
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
copyfile(fullfile(MCRstring,MCRInstaller),fullfile(mslice_dist_dir,MCRInstaller),'f')

disp('====> compressing mslice distribution together with installer ======!')
zip(['mslice_standalone_kit_',MCR_folder,'.zip'],[mslice_dist_dir,'/*'])
% remove unecessary  files.
disp('====> deleting intermediate and temporary files ====================!')
rmdir(mslice_tmp_dir,'s')
rmdir(mslice_src_dir,'s')
rmdir(mslice_dist_dir,'s')
%delete([homer_root_dir,'/homer_standalone.zip']);


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