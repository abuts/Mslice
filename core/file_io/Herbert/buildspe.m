function data=buildspe(spe_filename,phx_filename,sum_filename,data_mode)
% Function reads spe data from any supported file format and returns spe
% data structure in the form:
% 
%  data.en  (1,ne)          -- [meV] energy grid
%  data.S   (ndet,ne)       --  S(unmasked detector group,energy_index)
%  data.ERR (ndet,ne)		--  ERR
% 
%  If the data file has psi or Ei valies, the following fields are returned
%  data.psi                 -- crystall rotation angle 
%  data.Ei                  -- incident energy for direct instrument or
%                              analyzer energy for indirect.
%
% If phx_filename exists, or file contains the detectors data, the
% following fields are also defined:
%	data.det_num 			-- number associated with each detector group
%	data.spec_num			-- spectrum number - || -
%	data.det_theta(ndet,1)[rad]	theta(deg)=average scattering angle of each detector group
%	data.det_psi(ndet,1)[rad] average azimuthal (psi(deg)) angle - || -
%
% If sum_fileneme exists the following fields are also returned:
%  data.det_whitevan_int	= white vanadium integral of each detector group
%  data.det_whitevan_err
%
% data_mode is the number, which describes data analysis mode i.e.
% crystal(1) or powder(2)
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)


% === return if no parameters passed
if ~exist('spe_filename','var'),
    help buildspe;
    return
end

% by default
if ~exist('data_mode','var')
    h_cw     =findobj('Tag','ms_ControlWindow');
    h_mode=findobj(h_cw,'Tag','ms_sample');
    data_mode =get(h_mode,'Value');
end

if ~exist('phx_filename','var')
    phx_filename = 'obtainedfromnxspefile';
end


if isempty(phx_filename) || strncmpi('obtainedfromnxspefile',phx_filename,21) ||strncmpi(' obtained from nxspe file',phx_filename,25)
    phx_filename='';
else
    phx_filename=check_file_existence(phx_filename,'.phx','PhxDir','ms_PhxFile',true);
end

loader = loaders_msl_factory.instance().get_loader(spe_filename,phx_filename);

%=== load data file and find out which detectors are to be masked
defines = loader.defined_fields();
if ~ismember('S',defines)	% if no signal/error are given we may want to load just .phx file
    disp('No data loaded.');
    data=[];
else
    [ok,mess]= loader.is_loader_valid();
    if ~ok
        error('MSLICE:build_spe',mess);
    end
    loader = loader.load();
    
    data.S = loader.S';
    data.ERR=loader.ERR';
    [path,filename,fext] = fileparts(loader.file_name);
    data.filename=[filename,fext];
    data.filedir=path;
    data.total_ndet = loader.n_detectors;
    
    en =loader.en;
    ne = numel(en)-1;
    data.en=((en(2:ne+1)+en(1:ne))/2)'; % take median values, centres of bins
    
    
    %  par(1,:)   -- sample-to-detector distance
    %  par(2,:)   -- 2-theta (polar angle)
    %  par(3,:)   -- azimutal angle
    %  par(4,:)   -- detector width -- NO transformation currently occurs
    %                so it is angular width
    %  par(5,:)   -- detector height -- NO transformation currently occurs
    %                so it is angular width
    %  par(6,:)   -- detector ID (number)
    phx=loader.load_par('-getphx'); % is not doung actual loading, the loading has been done earlier
    phx=phx';
    % remove masks!
    %
    index_masked = (isnan(data.S)|(isinf(data.S))); % masked pixels
    line_notmasked= ~any(index_masked,2);           % masked detectors (for any energy)
    data.S  = data.S(line_notmasked,:);
    data.ERR= data.ERR(line_notmasked,:);
    phx = phx(line_notmasked,:);
    
    % redefine 
    if any(phx(:,4)==0)
        dthet =abs(max(phx(:,2))-min(phx(:,2)))/size(phx,1);
        phx(:,4)=dthet;
    end
    
    if ismember('psi',defines)
        data.psi = loader.psi;
    end
    if ismember('efix',defines)
        data.Ei = loader.efix;
    end
end
%---------------------------------------------------------------------------------

%=== load sum file with white vanadium integrals, if sum_filename given
if exist('sum_filename','var') && ~isempty(sum_filename)
    sum_spec=load_sum(sum_filename);	% [spec_num,int,err] (ndet,3)
else
    sum_spec=[];
end


% BUILD UP SPE DATA STRUCTURE
if isempty(data),
    data.filename='simulation';
    data.det_group=(1:size(phx,1))';
end

% if in powder mode, set psi equal to 0; (done this way as some nxspe files
% do not keep correct values for (polar?) angle
if data_mode==2
    phx(:,1)=0;
    phx(:,3)=0;
    phx(:,5)=0;
    ndat = size(phx,1);
    dthet =abs(phx(end,2)-phx(1,2))/ndat;
    phx(:,4)=dthet;
    
end

%data.det_num=phx(:,1);
%data.spec_num=det2spec(data.det_num);
data.det_theta=phx(:,2)*pi/180;
data.det_psi=phx(:,3)*pi/180;
data.det_dtheta=phx(:,4)*pi/180;
data.det_dpsi=phx(:,5)*pi/180;
data.det_group=phx(:,6);
[name,pathname]=stripath(phx_filename);
data.detfilename=name;
data.detfiledir=pathname;

if ~isempty(sum_spec),
    sum_det=sum2det(phx(:,1),sum_spec);	% extract white vanadium integrals for the unmasked detectors
    data.det_whitevan_int=sum_det(:,2);
    data.det_whitevan_err=sum_det(:,3);
end
