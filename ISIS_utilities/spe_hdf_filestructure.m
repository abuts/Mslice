function rez=spe_hdf_filestructure(field_name)
% this private function describes the structure of spe-hdf file version 2
% it may change if versions increases
% Usage:
%>>rez=spe_hdf_filestructure()  -- returns the structure, which describes
%                                  the spe_hdf5 file structure on hdd
%>>rez=spe_hdf_filestructure(field_name)
%                               -- returns the default value of the correspondent 
%                                  spe_hdf5 structure if the field name
%                                  exist and error othewise
%
% $Revision$ ($Date$)
%

file_structure=struct(...
    'spe_hdf_version',2,... 
    'spe_hdf_file_ext','.spe_h5',...   % what extension to use for spe-hdf files. 
    'data_field_names',[]...               
);
% the names of the data fields which are present in a spe hdf5 file
file_structure.data_field_names=...
            {'Ei',...    'Ei', 10, ... % input energy identified from homering;
            'En_Bin_Bndrs','S(Phi,w)','Err','spe_hdf_version'};
if exist('field_name','var')
    if isfield(file_structure,field_name)
        rez=file_structure.(field_name);
    else
        error('SPE:spe_hdf_filestructure',' requested non-existent field %s',field_name);
    end
else
    rez=file_structure;
end



