function [root_nxspe_path,data_structure] = find_root_nxspeDir(hdf_fileName)
% function identifies the path to the root folder of nxspe data file
%
% The root folder is a folder where all nxspe data are related to. 
% Currently we assume that all upper level folders with nexus structure are root folders 
% This may be wrong
%
% $Revision: 1759 $ ($Date: 2010-11-29 15:15:50 +0000 (Mon, 29 Nov 2010) $)
%
data_structure =  hdf5info(hdf_fileName,'ReadAttributes',true);
n_path = 0;
n_roots         = numel(data_structure.GroupHierarchy.Groups(:));
if(n_roots~=1)
    error('ISIS_UTILITES:find_root_nxspeDir',' does not currently support more then one root directory');
end
root_nxspe_path = cell(n_roots,1);

for i=1:n_roots
    try
        long_attr_name = data_structure.GroupHierarchy.Groups(i).Attributes(1).Name;
        attr_value          = data_structure.GroupHierarchy.Groups(i).Attributes(1).Value.Data;
        [dir,arttr_name]  = fileparts(long_attr_name );
        if ~(strcmp(arttr_name,'NX_class')||strcmp(attr_value,'NXentry'))
            error('ISIS_UTILITES:find_root_nxspeDir','suspected nxpse are stored not in an proper nexus data enrty');
        end
        root_guess =  data_structure.GroupHierarchy.Groups(i).Name;        
        n_path = n_path +1;
        root_nxspe_path{n_path} = root_guess;     
    catch
        error('ISIS_UTILITES:find_root_nxspeDir','error %s reading hdf5 from file %s',lasterr(),hdf_fileName);
    end
end



