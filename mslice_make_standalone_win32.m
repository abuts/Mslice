% >> mslice compile_win32(option, ext)
%
% option is the path within the fortran folder to use for the fortran
% files, i.e. 'win32', 'old', 'win64' to use for compiling. by default
% 'old' is used.
%


% To change locations etc. edit this file - ..\homer_standalone\src should
% be replaced with wherever source files should go,
% ..\homer_standalone\dist for distribution files, homer is the name of the
% .exe file (and thus ctf file)

% use relative folders so that it's more robust against folder changes.
% Also note using things like *.txt, *.msp means that any svn folder is
% ignored. 


% Make stanadlon windows 32 version of mslice
%


start_dir=pwd;
try
    % Get root directory, and ensure this is the pwd
    parent_dir = fileparts(which('mslice_init'));
    cd (parent_dir)

    % Create a temporary directory
    tmpdir=tempdir;   % get temporary directory
    if isempty(tmpdir)
        error('Unable to locate temporary directory name')
    end
    tmpdir = fullfile(tmpdir,'mslice_temporary_standalone_creation');
    if exist(tmpdir,'dir')
        rmdir(tmpdir,'s')
    end
    mkdir(tmpdir);

    % Compile into the temporary folder
    % Command is:
    % mcc -o <name of .exe file> -W 'main' -d <folder location to put .exe and.ctf files> ...
    %     -T 'link:exe' -v -N <name of mfile to compile (can omit '.m')>
    mcc -o 'mslice' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice.m'
    mcc -o 'mslice_setup_examples' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice_setup_examples.m'

    % Copy over 
    
    % Copy files:
    copyfile([parent_dir,'*.*'],tmpdir,'f');

    % Remove all the .svn folders
    directoryRecurse(tmpdir,@remove_svn)

    % Create zip file
    if exist(zipfile,'file')
        delete(zipfile)     % Delete any zip file with the output name
    end
    zip(zipfile,'*',tmpdir)    % Create zip file

    % Delete the temporary folder
    rmdir(tmpdir,'s')

    % Return to starting directory
    cd(start_dir);

catch
    cd(start_dir);
    error('Problems creating mex files. Please try again.')
end

parent_path = which('mslice_compile_win32');
parent_dir = fileparts(parent_path);
cd(parent_dir)

% make directories for source and distribution files
mkdir('mslice_standalone')
mkdir('mslice_standalone\src')
mkdir('mslice_standalone\dist')

% compile into source folder

% mcc -o <name of .exe file> -W 'main' -d <folder location to put .exe and
% .ctf files> -T 'link:exe' -v -N <name of mfile to compile (can omit '.m')>
mcc -o 'mslice' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice.m'

mcc -o 'mslice_setup_examples' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice_setup_examples.m'

%copy over any msp files
copyfile('mslice\*.msp','mslice_standalone\dist')

% should be no need to copy over fortran files. 
copyfile('mslice\*.dat','mslice_standalone\dist')



% copy help file over to parent dir. 
copyfile('mslice\help.txt','mslice_standalone\dist','f')

% Copy license and libraries that may be needed
mkdir('mslice_standalone\dist\DLL')
mkdir('mslice_standalone\dist\License')

% copyfile('mslice\*.mex*','mslice_standalone\dist\DLL','f')
% 
% try
% copyfile('mslice\fortran\*.dll*','mslice_standalone\dist\DLL','f')
% end
% 
 try
 copyfile('win32_distref\*.dll','mslice_standalone\dist\DLL','f')
 end
% 
 try
 copyfile('win32_distref\*.lib','mslice_standalone\dist\DLL','f')
 end
% 
 try
 copyfile('License\*.txt','mslice_standalone\dist\License','f')
 end
% 
try
 copyfile('License\*.rtf','mslice_standalone\dist\License','f')
 end

% copy over instrument files if they exist
try
    mkdir('mslice_standalone\dist\HET')
copyfile('mslice\HET\*.*','mslice_standalone\dist\HET')
rmdir('mslice_standalone\dist\HET\.svn','s')
end
try
 mkdir('mslice_standalone\dist\MARI')
copyfile('mslice\MARI\*.*','mslice_standalone\dist\MARI')
rmdir('mslice_standalone\dist\MARI\.svn','s')
end
try
 mkdir('mslice_standalone\dist\MAPS')
copyfile('mslice\MAPS\*.*','mslice_standalone\dist\MAPS')
rmdir('mslice_standalone\dist\MAPS\.svn','s')
end
try
 mkdir('mslice_standalone\dist\MERLIN')
copyfile('mslice\MERLIN\*.*','mslice_standalone\dist\MERLIN')
rmdir('mslice_standalone\dist\MERLIN\.svn','s')
end
try
 mkdir('mslice_standalone\dist\IRIS')
copyfile('mslice\HET\*.*','mslice_standalone\dist\IRIS')
rmdir('mslice_standalone\dist\IRIS\.svn','s')
end

% THE MOST IMPORTANT PART - copy over the mslice exe and ctf files.
 copyfile('mslice_standalone\src\mslice.exe','mslice_standalone\dist','f')
 copyfile('mslice_standalone\src\mslice.ctf','mslice_standalone\dist','f')
 copyfile('mslice_standalone\src\mslice_setup_examples.exe','mslice_standalone\dist','f')
 copyfile('mslice_standalone\src\mslice_setup_examples.ctf','mslice_standalone\dist','f')
% get and copy the mcr installer.
mystring = fullfile(matlabroot, 'toolbox','compiler','deploy','win32');
copyfile([mystring filesep 'MCRInstaller.exe'],'mslice_standalone\MCRInstaller.exe','f')
 
% zip files into homer_standalone directory, remove if it's already there.
if exist('mslice_standalone\mslice_standalone.zip')
 delete mslice_standalone\mslice_standalone.zip
end

cd mslice_standalone
cd dist

zip('..\mslice_standalone.zip','*')

 cd ..

 % remove unecessary files.

rmdir('dist','s')
rmdir('src','s')


% % Give a confirmation text file for this

tstamp = clock;

datestr = [' mslice Compiled Successfully On   ' num2str(tstamp(3)) '/' num2str(tstamp(2)) '/' num2str(tstamp(1)) '   at time  ' num2str(tstamp(4)) ':' num2str(tstamp(5)) ':' num2str(tstamp(6))];

fid = fopen('completed.txt', 'w');
 
fwrite(fid, datestr);

fclose(fid);
