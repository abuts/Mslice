function [root_nxspe_path,data_version,data_structure] = find_root_nexus_dir(hdf_fileName,nexus_application_name)
% function identifies the path to the root folder with data for a NeXus
% application, defined by the parameter: nexus_application_name
% 
%
%usage:
%>>root_folder=find_root_nexus_dir(nexus_file_name,'NXSPE')
%               -- obtains the position of an nxspe data if they are present in current nexus file
%               -- if the data are absent, function returns empty string       
%>>[root_folder,version,data_srtucture]=find_root_nexus_dir(nexus_file_name,'NXSPE')
%                 in addition to the location of the data returns the
%                 version of the nexus application (NXSPE here), its
%                 version and the structure of hdf5 data within the file. 
% The root folder is a folder where all nxspe data are related to. Further
% access to data can be obtained using hdf5read/write functins, e.g. 
%
% data=hdf5read(hdf_fileName,[root_foledr,'/data/data]) -- returns the
%                                        array of processed signals 
% $Author: Alex Buts; 20/10/2011
%
% $Revision$ ($Date$)
%
data_structure =  hdf5info(hdf_fileName,'ReadAttributes',true);
groups = data_structure.GroupHierarchy.Groups(:);

n_nxspe_entries=0;
nxspe_folders=cell(1,1);
nxspe_version=cell(1,1);
for i=1:numel(groups)
    if strcmp(groups(i).Attributes.Shortname,'NX_class')&&strcmp(groups(i).Attributes.Value.Data,'NXentry')
        nexus_folder = data_structure.GroupHierarchy.Groups(i);
        for j=1:numel(nexus_folder.Datasets)
            if strcmp([nexus_folder.Name,'/definition'],nexus_folder.Datasets(j).Name)
                definition = hdf5read(hdf_fileName,nexus_folder.Datasets(j).Name);
                if strcmp(definition.Data,nexus_application_name)
                    n_nxspe_entries=n_nxspe_entries+1;
                    nxspe_folders{n_nxspe_entries}=nexus_folder.Name;
                    ver = hdf5read(hdf_fileName,nexus_folder.Datasets(j).Name, nexus_folder.Datasets(j).Attributes.Shortname);
                    nxspe_version{n_nxspe_entries}= ver.Data;
                end
            end
        end
    end
end

if(n_nxspe_entries==0)
    root_nxspe_path='';
    return;
end
if(n_nxspe_entries>1)
    error('ISIS_UTILITES:invalid_argument',' found multiple nxspe folders in file %s but this function does not currently support multiple nxspe folders',hdf_fileName)
end
root_nxspe_path = nxspe_folders{1};
data_version    = nxspe_version{1};




