function [rez,spe_hdf_filestructure_version]=spe_hdf_filestructure(varargin)
% this private function describes the structure of spe-hdf file version 2
% and 3
% it will be modified  when version increase
%
% Usage:
%>>rez=spe_hdf_filestructure()  -- returns the structure, which describes
%                                                 all existing structures of  the spe_hdf5 file on hdd
%>>rez=spe_hdf_filestructure(field_name)
%                               -- returns all known versions of the field supplied
%                                   in hdf5 file if the field name
%                                  exist and error othewise
%>>rez=spe_hdf_filestructure(num_version)
%                               -- returns all fields corresponding to the vesion supplied
%                                  If the version is unknown, it works like no argumetns 
%                                  (warning message will be issued)
%
%>>rez=spe_hdf_filestructure(field_name,num_version)
%                               -- returns the value of the correspondent 
%                                  hdf5 structure with proper version if the field name
%                                  exist and error othewise
%
% WARNING !!!  All modified fields which may be needed for new modified file formats
%              should be added to the end of existing file structure as users of the filestructure may refer exsisting structure fields by
%              their numbers (BAD!!!).
%
% $Revision$ ($Date$)
%
% This is the version of the subprogram itself
spe_hdf_filestructure_version=1;
if nargin==1
    if ischar(varargin{1})
        field_name = varargin{1};
    elseif isnumeric(varargin{1})
        num_version=varargin{1};
    end
elseif nargin >=2
        field_name = varargin{1};
        num_version=varargin{2};        
end

file_structure=struct(...
    'spe_hdf_version',{2,3},...
    'spe_hdf_file_ext',{'.spe_h5','.nxspe'},...   % what extension to use for spe-hdf files.
    'data_field_names',{[],[]},...
    'data_attrib_names',{[],[]}...
);
% the names of the data fields which are present in a spe hdf5 file
file_structure(1).data_field_names=...
            {'Ei',...    'Ei', 10, ... % input energy identified from homering;
            'En_Bin_Bndrs',...
            'S(Phi,w)',...
            'Err',...
            'spe_hdf_version'};
file_structure(1).data_attrib_names={};
% the names of the data fields with must be present in nxspe hdf5 file 
file_structure(2).data_field_names=...
            {'NXSPE_info/fixed_energy',...    
            'data/energy',...
            'data/data',...
            'data/error',...
            'definition',...   % these fields are fixed for compartibility; Others are expected from nxspe file;
            'NXSPE_info/psi',... 
            'data/polar','data/azimuthal','data/polar_width','data/azimuthal_width','data/distance'...
            };
file_structure(2).data_attrib_names={'units',...
    'units','','','version','units','','','','',...
    };        
if exist('field_name','var')
    if isfield(file_structure,field_name)
        rez={file_structure.(field_name)};
    else
        error('SPE:spe_hdf_filestructure',' requested non-existent field %s',field_name);
    end
else
    rez=file_structure;
end
if exist('num_version','var')
    if num_version<1||num_version>numel(file_structure)
        warning('SPE:spe_hdf_filestructure',[' non-existing version',num2str(num_verson),' of spe hdf file structure requested. Returning all structure']);
    else
        rez=rez(num_version);
    end    
end



