function data=buildspe(spe_filename,phx_filename,sum_filename)

% function data=buildspe(spe_filename,phx_filename,sum_filename)
% constructs data structure 	.en  (1,ne)[meV]	energy grid
%										.S   (ndet,ne)		S(unmasked detector group,energy_index)
%										.ERR (ndet,ne)		ERR
%                         (if phx_filename exists then add fields)
%										.det_num 			number associated with each detector group
%										.spec_num			spectrum number - || -
% 										.det_theta(ndet,1)[rad]	theta(deg)=average scattering angle of each detector group
% 										.det_psi(ndet,1)[rad] average azimuthal (psi(deg)) angle - || -
%								  (if sum_fileneme exists then add fields)
% 										.det_whitevan_int	= white vanadium integral of each detector group
% 										.det_whitevan_err
% R.C. 24-July-1998, 25-Oct-2000

% === return if no parameters passed
if ~exist('spe_filename','var'),
   help buildspe;
   return
end

%=== load data file and find out which detectors are to be masked
if isempty(spe_filename(~isspace(spe_filename))),	% if no filename given just load .phx file
   disp('No data loaded.');
   data=[];
else
   rd = rundata(spe_filename,phx_filename);
   if ~exist('phx_filename','var')||isemtpy(phx_filename)
        [data.S,data.ERR,data.en]=get_rundata(rd,'S','ERR','en','-nonan');
   else
        [data.S,data.ERR,data.en,]=get_rundata(rd,'S','ERR','en','-nonan');       
   data=load_spe(spe_filename); 		% data.en (1,ne), data.S (ndet,ne),  data.ERR (ndet,ne)
	% remove masked detectors
   if ~isempty(data),
      [masked,masked_pixels]=rm_mask(data);
      data.S=data.S(~masked,:);
      data.ERR=data.ERR(~masked,:);
      data.det_group=data.det_group(~masked);
      % === if still more individual pixels to be masked continue
      if ~isempty(masked_pixels) && sum(masked_pixels(:))>=1,
         data.S(masked_pixels)=NaN;
         data.ERR(masked_pixels)=0;
         fprintf('%d individual pixels masked in otherwise good detectors',sum(masked_pixels(:)));
      end
   else
      masked=[];
      masked_pixels=[];
   end   
end

%=== load detector information file: either from separate file or from the nxspe
%  file
if isfield(data,'phx')  % data have been obtained from nxspe file
    if exist('phx_filename','var')
        phx_filename = ' obtained from nxspe file';
    end
    phx_filename=check_file_existence(phx_filename,'phx','PhxDir','ms_PhxFile',true);            
    phx =  data.phx;
else
    if ~exist('phx_filename','var')||isempty(phx_filename),
        return
    end
    
    phx_filename=check_file_existence(phx_filename,'phx','PhxDir','ms_PhxFile');        
    phx=load_phx(phx_filename);		% [det_num, theta(deg), psi(deg), dtheta(deg), dpsi(deg)] (ndet,5)    
end

if isempty(phx),
   return
end

%=== load sum file with white vanadium integrals, if sum_filename given
if exist('sum_filename','var'),
	sum_spec=load_sum(sum_filename);	% [spec_num,int,err] (ndet,3)
else
   sum_spec=[];
end

%=== if both data and phx files have been read successfully, check their compatibility
if ~isempty(data)&&~isempty(phx),
% check compatibility of .spe and .phx files against same number of detector groups
   if length(masked)~=size(phx,1),
	   warning(['.spe data from file ' spe_filename ' and .phx data from ' phx_filename ' not compatible']);
       warning(['Number of detector groups is different: ' num2str(size(data.S,1)) ' and ' num2str(size(phx,1))]);
      data=[];
   	return
	end
	% REMOVE MASKED DETECTORS FROM PHX
	phx=phx(~masked,:);
end

% BUILD UP SPE DATA STRUCTURE 
if isempty(data),
   data.filename='simulation';
   data.det_group=(1:size(phx,1))';
end

% if in powder mode, set psi equal to 0; (done this way as some nxspe files
% do not keep correct values for (polar?) angle
h_cw     =findobj('Tag','ms_ControlWindow');        
h_mode=findobj(h_cw,'Tag','ms_sample');
Value=get(h_mode,'Value');
if Value==2
    phx(:,1)=0;    
    phx(:,3)=0;
    phx(:,5)=0;    
    if  isfield(data,'phx') 
        warning('Mslice:buildspe',' angular width of the detector rings have been estimated from the angles itself as current nxspe does not contain correct informtion on this');
        ndat = size(phx,1);
      %  dthet = zeros(ndat,1);
        %dthet=phx(2:end,2)-phx(1:end-1,2);
        %dthet(ndat)=dthet(ndat-1);
        dthet =abs(phx(end,2)-phx(1,2))/ndat;
        phx(:,4)=dthet;
    end
end


%data.det_num=phx(:,1);
%data.spec_num=det2spec(data.det_num);
data.det_theta=phx(:,2)*pi/180;
data.det_psi=phx(:,3)*pi/180;
data.det_dtheta=phx(:,4)*pi/180;
data.det_dpsi=phx(:,5)*pi/180;
[name,pathname]=stripath(phx_filename);  
data.detfilename=name;
data.detfiledir=pathname;
if ~isempty(sum_spec),
	sum_det=sum2det(phx(:,1),sum_spec);	% extract white vanadium integrals for the unmasked detectors
	data.det_whitevan_int=sum_det(:,2);
   data.det_whitevan_err=sum_det(:,3);
end

   