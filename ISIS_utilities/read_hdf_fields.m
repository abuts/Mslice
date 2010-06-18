function varargout=read_hdf_fields(hdf_file,fieldnames)
% function reads the data from the hdf5 file, with name 'hdf_file'
%
% The data are described by the list of the fields, specified by the
% parameter 'fieldnames'
% 
% $Revision$ ($Date$)
%
if ~exist(hdf_file,'file')
    error('MATLAB:read_hdf_fields',' can not find file %s',hdf_file);
end
if ~H5F.is_hdf5(hdf_file)
    error('MATLAB:read_hdf_fields',' file %s is not an hdf5 file',hdf_file);    
end

n_fields=min(numel(fieldnames),nargout);
for i=1:n_fields
    varargout(i)={hdf5read(hdf_file,fieldnames{i})'};
end