function vol_d=vol_spe(data,ux,uy,uz)
% Creates 3D grid of data from mslice window.
% The perpendicular to the slice must be energy.
%
%   >> data=ms_slice3d
%
%   en          [optional] energy bin boundaries for rebinning
%
%   data.S
%   data.ERR
%   data.vx     bin boundaries along x axis
%   data.vy     bin boundaries along y axis
%   data.en     energy bin centres
%

% Get grid of values for rebinning
% ---------------------------------
% (In mslice, the min, max values are the bin *centres*)
vx=getbins(ux);
vy=getbins(uy);
vz=getbins(uz);
vx_bin=abs(ux(2)); ux_min=min(ux(1),ux(3)); ux_max=max(ux(1),ux(3));
vy_bin=abs(uy(2)); uy_min=min(uy(1),uy(3)); uy_max=max(uy(1),uy(3));
vz_bin=abs(uz(2)); uz_min=min(uz(1),uz(3)); uz_max=max(uz(1),uz(3));
nx=numel(vx)-1;
ny=numel(vy)-1;
nz=numel(vz)-1;


% Perform rebinning using matlab algorithm
% ----------------------------------------
ix=floor((data.v(:,:,1)-vx(1))/vx_bin)+1;
iy=floor((data.v(:,:,2)-vy(1))/vy_bin)+1;
iz=floor((data.v(:,:,3)-vz(1))/vz_bin)+1;

ibin=[ix(:),iy(:),iz(:)];   % array of indicies into output arrays
ind=find((ix>=1 & ix<=nx) & (iy>=1 & iy<=ny) & (iz>=1 & iz<=nz));  % those pixels that accumulate into the output arrays

vol_d.intensity=accumarray(ibin(ind(:),:),data.S(ind(:)),[nx,ny,nz]);
vol_d.error_int=accumarray(ibin(ind(:),:),data.ERR(ind(:)).^2,[nx,ny,nz]);
npix=accumarray(ibin(ind(:),:),ones(numel(ind),1),[nx,ny,nz]);

nopix=(npix==0);
vol_d.intensity(~nopix)=vol_d.intensity(~nopix)./npix(~nopix);
vol_d.error_int(~nopix)=sqrt(vol_d.error_int(~nopix))./npix(~nopix);
vol_d.intensity(nopix)=NaN;
vol_d.error_int(nopix)=NaN;
vol_d.vx=vx;
vol_d.vy=vy;
vol_d.vz=vz;

% Construct slice title
% ---------------------
% Follow slice_spe
form='%7.5g';       % number format
titlestr1=[avoidtex(data.filename) ', ' data.title_label];
if data.emode==1,	% direct geometry Ei fixed
    titlestr1=[titlestr1 ', Ei=' num2str(data.efixed,form) ' meV'];
elseif data.emode==2,	% indirect geometry Ef fixed
    titlestr1=[titlestr1 ', Ef=' num2str(data.efixed,form) ' meV'];
else
    error('Could not identify spectrometer type (only direct/indirect geometry allowed)');
end

% if sample is single crystal and uv orientation and psi_samp are defined, include in title
if isfield(data,'uv')&&~isempty(data.uv)&&isnumeric(data.uv)&&isequal(size(data.uv),[2 3])&&...
        isfield(data,'psi_samp')&&~isempty(data.psi_samp)&&isnumeric(data.psi_samp)&&...
        (numel(data.psi_samp)==1),
    titlestr2=sprintf('{\\bfu}=[%g %g %g], {\\bfv}=[%g %g %g], Psi=({\\bfu},{\\bfki})=%g',...
        data.uv(1,:),data.uv(2,:),data.psi_samp*180/pi);
else
    titlestr2=[];
end
titlestr3=[' Volume ' deblank(data.axis_label(1,:)) '=' num2str(ux_min,form) ':' num2str(vx_bin,form) ':'  num2str(ux_max,form)];
titlestr3=[titlestr3 ' , ' deblank(data.axis_label(2,:)) '=' num2str(uy_min,form) ':' num2str(vy_bin,form) ':'  num2str(uy_max,form)];
titlestr3=[titlestr3 ' , ' deblank(data.axis_label(3,:)) '=' num2str(uz_min,form) ':' num2str(vz_bin,form) ':'  num2str(uz_max,form)];
if ~isempty(titlestr2),
    vol_d.title={titlestr1, titlestr2, titlestr3};
else
    vol_d.title={titlestr1, titlestr3};
end

% Construct axis labels
% ---------------------
% Follow slice_spe
labelx=[combil(deblank(data.axis_label(1,:)),data.u(1,:),[0,0,0,0]), ' ', deblank(data.axis_unitlabel(1,:))];
labely=[combil(deblank(data.axis_label(2,:)),data.u(2,:),[0,0,0,0]), ' ', deblank(data.axis_unitlabel(2,:))];
labelz=[combil(deblank(data.axis_label(3,:)),data.u(3,:),[0,0,0,0]), ' ', deblank(data.axis_unitlabel(3,:))];
vol_d.axis_shortlabel=data.axis_label;
vol_d.axis_label=str2mat(labelx,labely,labelz,deblank(data.axis_unitlabel(4,:)));
vol_d.axis_unitlength=data.axis_unitlength;

%-----------------------------------------------
function v=getbins(u)
ulo=min(u(1),u(3)); du=abs(u(2)); uhi=max(u(1),u(3));
v=ulo:du:uhi;
v=[v-du/2,v(end)+du/2];
if v(end)<uhi
    v=[v,v(end)+du];
end
