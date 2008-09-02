% Copy required files for a distribution of mslice. Does not copy over any
% unrequired files.

parent_path = which('mslice_distribute');
parent_dir = fileparts(parent_path);
cd(parent_dir)


mkdir('mslice_distribution')
mkdir('mslice_distribution\mslice')

copyfile('mslice\*','mslice_distribution\mslice','f')
copyfile('License\*','mslice_distribution\License','f')
copyfile('mslice_extras\*','mslice_distribution\mslice_extras','f')
copyfile('*.txt','mslice_distribution','f')
copyfile('*.m','mslice_distribution','f')
delete mslice_distribution\mslice_distribute.m

cd mslice_distribution

try
    rmdir('.svn','s')
end

try
cd License
    rmdir('.svn','s')
cd ..
end

cd mslice

try
    rmdir('.svn','s')
end

try
cd HET
    rmdir('.svn','s')
cd ..
end

try
cd IRIS
    rmdir('.svn','s')
cd ..
end

try
cd MARI
    rmdir('.svn','s')
cd ..
end

try
cd MAPS
    rmdir('.svn','s')
cd ..
end

try
cd MERLIN
    rmdir('.svn','s')
cd ..
end

cd ..

try
cd mslice_extras
    rmdir('.svn','s')
cd ..
end

cd ..

if exist('mslice.zip')
 delete mslice.zip
end

cd mslice_distribution

zip('..\mslice.zip','*')

cd ..

rmdir('mslice_distribution','s')