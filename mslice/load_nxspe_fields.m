function spe_data = load_nxspe_fields(nxspe_filename,data_field_names,data_attrib_names)
% function loads fields and correspondent attributes from properly formed
% nxspe file and returns spe_data structure suitable for MSLICE to
% understand
%
%Usage:
%>>  spe_data =load_nxspe_fields(nxspe_filename,data_field_names,data_attrib_names);
%
%   Arguments:
%  Input:
%  nxspe_filename   -- full name of the file with nxspe data
% data_field_names -- generic names of the fields with the data of
%                               interest. 
% Output:
% 
% 
% $Revision: 1757 $ ($Date: 2010-10-15 12:13:05 +0100 (Fri, 15 Oct 2010) $)
%
if ~exist(nxspe_filename,'file')
    error('MATLAB:load_nxspe_fields',' can not find file %s',nxspe_filename);
end
if ~H5F.is_hdf5(nxspe_filename)
    error('MATLAB:load_nxspe_fields',' file %s is not an hdf5 file',nxspe_filename);    
end
% get the name of the root folder for nxspe
[filepath,filename]= fileparts(nxspe_filename);
%
data_root = find_root_nxspeDir(nxspe_filename);
root = repmat( [data_root{1},'/'],numel(data_field_names),1);
root = cellstr(root)';
data_field_names=strcat(root,data_field_names);
%
% Load principal data part;
%
spe_data.Ei         = hdf5read(nxspe_filename,data_field_names{1});
spe_data.en         = hdf5read(nxspe_filename,data_field_names{2})';

spe_data.S          = hdf5read(nxspe_filename,data_field_names{3})';
spe_data.ERR     = hdf5read(nxspe_filename,data_field_names{4})';
%
[ndet,ne]=size(spe_data.S); 
%
if size(spe_data.en,1)==1
        en=spe_data.en;  
else
       en=spe_data.en;             
end
spe_data.en=(en(2:ne+1)+en(1:ne))/2; % take median values, centres of bins
%spe_data.det_theta=ones(ndet,1);
%
% load detector information
%

try
    warning('OFF','MATLAB:hdf5readc:deprecatedAttributeSyntax');    
    spe_data.psi = hdf5read(nxspe_filename,data_field_names{6});    
    psiUnits     = hdf5read(nxspe_filename,[data_field_names{6},'/',data_attrib_names{6}]);   
    spe_data.nxspe.psiUnits = psiUnits.Data;
    %warning(state,'Warning:DeprecatedSyntax');
catch
end
try    
   warning('OFF','MATLAB:hdf5readc:deprecatedAttributeSyntax');        
    EiUnits       = hdf5read(nxspe_filename,[data_field_names{1},'/',data_attrib_names{1}]);
    enUnits      = hdf5read(nxspe_filename,[data_field_names{2},'/',data_attrib_names{2}]);

    spe_data.nxspe.EiUnits  =  EiUnits.Data;
    spe_data.nxspe.enUnits  = enUnits.Data;
    
   %  warning(state,'Warning:DeprecatedSyntax');
    % obtain the state 'phx from nxspe' switch fron GUI and if it is true,
    % load data from nxspe
    h_cw     =findobj('Tag','ms_ControlWindow');        
    h_file=findobj(h_cw,'Tag','ms_usePhxFromNXSPE');
    Value=get(h_file,'Value');
    if Value == true
  
        spe_data.phx = zeros(ndet,5);
        spe_data.phx(:,1)=1:ndet;
        for i=1:4
            spe_data.phx(:,i+1)= hdf5read(nxspe_filename,data_field_names{6+i});
        end 
    end
    
catch
    warning('ReadNXSPE:format_error',['error reading addirional fields from nxspe file:',nxspe_filename],lasterr());
end




end

