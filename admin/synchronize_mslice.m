function fc=synchronize_mslice(varargin)
% function to synchronize mslice functions, which come from herbert with
% its source
%
%
%   $Rev$ ($Date$)
%
%


% HERBERT HAS TO BE INITIATED AFTER Mslice for this function to work
% properly!

%fc_origin=funcCopier();
%fc_list = funcCopier();


fc_origin = build_dependencies_list(funcCopier);
fc_list =funcCopier().load_list('herbert_dependent.lst');

fc_list = fc_list.check_new_dependencies(fc_origin);


fc_list =fc_list.copy_dependencies();
fc_list.save_list('herbert_dependent1.lst');

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
    'find_root_nexus_dir','get_hor_format','get_par','memfile_fs','loaders_factory'};
for i=1:numel(files_copied)
    fc=fc.add_dependency(files_copied{i});
end

fc=fc.add_dependency('classes/data_loaders/@a_loader');
control.modifiers={'herbert_config','mslice_config','use_mex_C','use_mex'};
fc=fc.add_dependency('classes/data_loaders/@asciipar_loader',control);
fc=fc.add_dependency('classes/data_loaders/@loader_ascii',control);
fc=fc.add_dependency('classes/data_loaders/@loader_nxspe',control);
fc=fc.add_dependency('classes/data_loaders/@loader_speh5',control);
fc=fc.add_dependency('classes/data_loaders/@memfile',control);

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

