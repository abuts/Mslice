function root_nxspe_path = find_root_nxspeDir(hdf_fileName)
% function identifies the path to the root folder of nxspe data file
%
% The root folder is a folder where all nxspe data are related to. 
% Currently we assume that all upper level folders with nexus structure are root folders 
% This may be wrong
%
% $Revision: 1759 $ ($Date: 2010-11-29 15:15:50 +0000 (Mon, 29 Nov 2010) $)
%
data_structure =  hdf5info(hdf_fileName);
n_path = 0;
root_guess =  {data_structure.GroupHierarchy.Groups(:).Name};

for i=1:numel(root_guess)
    try
        root_attribute = hdf5read(hdf_fileName,root_guess{i},'NX_class');
        if strcmp(root_attribute.Data,'NXentry')
             n_path = n_path +1;
            root_nxspe_path{n_path} = root_guess{i};     
        end
    catch
    end
end

end

