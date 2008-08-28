% To change locations etc. edit this file - ..\homer_standalone_src should
% be replaced with wherever source files should go,
% ..\homer_standalone\dist for distribution files, homer is the name of the
% .exe file (and thus ctf file)

% use relative folders so that it's more robust against folder changes.
% Also note using things like *.txt, *.msp means that any svn folder is
% ignored. 

parent_path = which('mslice_compile');
parent_dir = fileparts(parent_path);
cd(parent_dir)

% make directories for source and distribution files
mkdir('mslice_standalone')
mkdir('mslice_standalone\src')
mkdir('mslice_standalone\dist')

% compile into source folder
mcc -o 'mslice' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice.m' 
mcc -o 'setup_examples' -W 'main' -d 'mslice_standalone\src' -T 'link:exe' -v -N 'mslice_setup_examples.m' 
%copy over any msp files
mkdir('mslice_standalone\dist\msp_files')
copyfile('msp_files\*.msp','mslice_standalone\dist\msp_files')

%copy over fortran files and such
% mkdir('mslice_standalone\dist\MEX')
% copyfile('mslice\Fortran\*.mex*','mslice_standalone\dist\MEX')
% copyfile('mslice\Fortran\*.dll','mslice_standalone\dist\MEX')
copyfile('mslice\*.dat','mslice_standalone\dist')



% copy help file over to parent dir. 
copyfile('mslice\help.txt','mslice_standalone\dist','f')

% Copy license and libraries that may be needed
mkdir('mslice_standalone\dist\DLL')
mkdir('mslice_standalone\dist\License')

try
copyfile('win32_distref\*.dll','mslice_standalone\dist\DLL','f')
end

try
copyfile('win32_distref\*.lib','mslice_standalone\dist\DLL','f')
end

try
copyfile('License\*.txt','mslice_standalone\dist\License','f')
end

try
copyfile('License\*.rtf','mslice_standalone\dist\License','f')
end

% copy over instrument files if they exist
try
    mkdir('mslice_standalone\msp_files\HET')
copyfile('msp_files\HET\*','mslice_standalone\msp_files\HET')
end
try
    mkdir('mslice_standalone\MARI')
copyfile('msp_files\MARI\*','mslice_standalone\msp_files\MARI')
end
try
    mkdir('mslice_standalone\MAPS')
copyfile('msp_files\MAPS\*','mslice_standalone\msp_files\MAPS')
end
try
    mkdir('mslice_standalone\MERLIN')
copyfile('msp_files\MERLIN\*','mslice_standalone\msp_files\MERLIN')
end
try
    mkdir('mslice_standalone\IRIS')
copyfile('msp_files\IRIS\*','mslice_standalone\msp_files\IRIS')
end

% copy over the mslice exe and ctf files.
 copyfile('mslice_standalone\src\mslice.exe','mslice_standalone\dist','f')
 copyfile('mslice_standalone\src\mslice.ctf','mslice_standalone\dist','f')

% get and copy the mcr installer.
mystring = fullfile(matlabroot, 'toolbox','compiler','deploy','win32');
copyfile([mystring filesep 'MCRInstaller.exe'],'mslice_standalone\MCRInstaller.exe','f')
 
% zip files into homer_standalone directory, remove if it's already there.
if exist('mslice_standalone\mslice.zip')
 delete mslice_standalone\mslice.zip
end

cd mslice_standalone
cd dist

zip('..\mslice.zip','*')

 cd ..

 % remove unecessary files.

rmdir('dist','s')
rmdir('src','s')

try
rmdir('MAPS','s')
end

try
rmdir('MERLIN','s')
end
try
rmdir('MARI','s')
end
try
rmdir('HET','s')
end
try
rmdir('IRIS','s')
end


% % Give a confirmation text file for this

tstamp = clock;

datestr = [' mslice Compiled Successfully On   ' num2str(tstamp(3)) '/' num2str(tstamp(2)) '/' num2str(tstamp(1)) '   at time  ' num2str(tstamp(4)) ':' num2str(tstamp(5)) ':' num2str(tstamp(6))];

fid = fopen('completed.txt', 'w');
 
fwrite(fid, datestr);

fclose(fid);
