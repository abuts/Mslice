function fc_list=synchronize_mslice(varargin)
% function to synchronize mslice functions, which come from herbert with
% its source
%
%
%   $Rev$ ($Date$)
%
%


% HERBERT HAS TO BE INITIATED AFTER Mslice for this function to work
% properly!
her_availible=false;
if ~isempty(which('herbert_init.m'))
    her_availible=true;
end
try
    herbert_on();    
catch   
end

%thorough checks are necessary when some controlling fields in the files already copied were changed
check_thoroughly=false;
if nargin>0
    check_thoroughly=true;
end

fc_origin = build_dependencies_list(funcCopier);
fc_list =funcCopier().load_list('herbert_dependent.lst');

fc_list = fc_list.check_new_dependencies(fc_origin,check_thoroughly);


fc_list =fc_list.copy_dependencies(check_thoroughly);
fc_list.save_list('herbert_dependent1.lst');

if ~her_availible
    herbert_off();
end

function fc=build_dependencies_list(fc)


files_copied = {'Singleton'};
for i=1:numel(files_copied)
    fc=fc.add_dependency(files_copied{i});
end


fd = file_descriptor('equal_to_tol.m');
fd.short_dest_path = 'utilities/general';
fc=fc.add_dependency(fd);

%
files_copied = {'check_file_exist.m','find_dataset_info',...
    'find_root_nexus_dir','get_hor_format'};
for i=1:numel(files_copied)
    fc=fc.add_dependency(files_copied{i});
end


control.modifiers={'asciipar_loader','asciipar_msl_ldr','loaders_factory','loaders_msl_factory'};
fc=fc.add_dependency('get_par',control);




control.modifiers={'herbert_config','mslice_config','use_mex_C','use_mex','a_loader','a_msl_loader'};
control.rename_class ={'asciipar_loader','asciipar_msl_ldr'};
control.dest_folder='classes/data_loaders/@asciipar_msl_ldr';
fc=fc.add_dependency('classes/data_loaders/@asciipar_loader',control);


control.modifiers={'herbert_config','mslice_config','use_mex_C','use_mex',...
    'asciipar_loader','asciipar_msl_ldr','mem_file_fs','mem_msl_fs'};
control.rename_class ={'a_loader','a_msl_loader'};
control.dest_folder='classes/data_loaders/@a_msl_loader';
fc=fc.add_dependency('classes/data_loaders/@a_loader',control);


control.modifiers={control.modifiers{:},'a_loader','a_msl_loader'};
control.rename_class ={'loader_ascii','ldr_msl_ascii'};
control.dest_folder='classes/data_loaders/@ldr_msl_ascii';
fc=fc.add_dependency('classes/data_loaders/@loader_ascii',control);

control.rename_class ={'loader_nxspe','ldr_msl_nxspe'};
control.dest_folder='classes/data_loaders/@ldr_msl_nxspe';
fc=fc.add_dependency('classes/data_loaders/@loader_nxspe',control);

control.rename_class ={'loader_speh5','ldr_msl_speh5'};
control.dest_folder='classes/data_loaders/@ldr_msl_speh5';
fc=fc.add_dependency('classes/data_loaders/@loader_speh5',control);

control.rename_class ={'memfile','ldr_msl_membased'};
control.dest_folder='classes/data_loaders/@ldr_msl_membased';
fc=fc.add_dependency('classes/data_loaders/@memfile',control);

% memfile_fs  -- eventually it should become a folder-based class
control.rename_class ={'mem_file_fs','mem_msl_fs'};
control=rmfield(control,'dest_folder');
fc=fc.add_dependency('mem_file_fs',control);


% loaders_factory
control.modifiers={'herbert_config','mslice_config','use_mex_C','use_mex','memfile_fs','memfile_msl_fs',...
    'a_loader','a_msl_loader','asciipar_loader','asciipar_msl_ldr','loader_ascii','ldr_msl_ascii',...
    'loader_nxspe','ldr_msl_nxspe','loader_speh5','ldr_msl_speh5','memfile','ldr_msl_membased'};

control.rename_class ={'loaders_factory','loaders_msl_factory'};
fc=fc.add_dependency('loaders_factory',control);


% Add get_ascii_loader
control1.dest_folder='_LowLevelCode\32and64after7.4';
source_folder = '_LowLevelCode\CPP\get_ascii_file';
files_copied={'get_ascii_file.vcproj','get_ascii_file.sln','IIget_ascii_file.cpp','get_ascii_file.cpp'};
for i=1:numel(files_copied)
    fc=fc.add_dependency(fullfile(source_folder,files_copied{i}),control1);
end

% replace basis configuration classes
ctrl2.dest_folder = 'classes/configuration/@config_bas_msl';
ctrl2.rename_class ={'config_base','config_bas_msl'};
ctrl2.modifiers={'config_store','config_stor_msl'};
fc=fc.add_dependency('configuration/@config_base',ctrl2);

ctrl2.dest_folder = 'classes/configuration/@config_stor_msl';
ctrl2.rename_class ={'config_store','config_stor_msl'};
ctrl2.modifiers={'config_base','config_bas_msl'};
fc=fc.add_dependency('configuration/@config_store',ctrl2);
