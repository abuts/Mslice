function make_mslice_distribution_kit
% function creates libisis distribution kit packing all files necessary for
% Libisis to work into single zip file
%
% To use libsis one has to unpack the resulting zip file and add the folder
% where the function libisis_init resides to the matlab search path. 
% alternatively, you can edit the file libisis_on.mt, 
% replace the variable $libisis_path$ by the actual folder where the file 
% libisis_init.m resides and add to the search path the file libisis_on.m, 
% after renaming the file libisis_on.mt.
% 
% $Revision$ ($Date$)
%
rootpath = fileparts(which('mslice_init')); % MUST have rootpath so that libisis_init, libisis_off included
% code path and snv path are identified relatively to rootpath and have to
% be in the place specified;
% 
% run the external utility which would identify the svn version release
% perl('process_libisis_SubWCRev.pl','do_not_update_libisis.h');
% svn_path=parse_path([rootpath,'/..']);
% svn_template_filie=[svn_path,'/Libisis_Core/bindings/matlab/matlab_c/SVNVersion.template '];
% svn_version_file =[rootpath,'/DLL/SVNVersion.h ']; 
% if(strncmpi(computer('arch'),'win',3))   
%     status=dos(['SubWCRev.exe ',svn_path,' ',svn_template_filie,svn_version_file]);
%     if(status~=0)
%         warning(' subversion evaluation function completed with status: %d',status);
%     end
% else
% end
%
disp('!===================================================================!')
disp('!==> Preparing MSLICE  distributon kit =============================!')
disp('!    Start collecting the mslice program files =====================!')
%
target_Dir=[pwd,'/ISIS'];
% copy files including special folders starting with _ ('+_' parameter)
copy_files_list(rootpath,[target_Dir,'/Mslice'],'+_'); 
%
disp('!    The mslice  program files collected successfully===============!')

% copy the file which should initiate mslice (after minor modifications)
install_file=which('mslice_on');
copyfile(install_file,  [target_Dir '/mslice_on.m'],  'f');
%copyfile('mslice_on.mt', [target_Dir '/mslice_on.mt'], 'f');
%copyfile('start_app.m',  [target_Dir '/start_app.m'],  'f');
%
%
disp('!    Start compressing all necessary files together ================!')
% 
mslice_file_name= 'mslice_distribution_kit.zip';
if(exist(mslice_file_name,'file'))
    delete(mslice_file_name);
end
zip(mslice_file_name,target_Dir);
%
disp('!    Files compressed. Deleting the auxiliary files and directories=!')
rmdir(target_Dir,'s');
disp('!    All done folks ================================================!')
sound(-1:0.001:1);
disp('!===================================================================!')


%--------------------------------------------------------------------------
