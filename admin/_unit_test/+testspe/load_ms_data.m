function data=load_ms_data(filename,ndet,ne)
% function data=load_spe(spe_filename,ndet,ne)
%
%   >> data = load_spe(file)
%
if ~exist('ndet','var')
    ndet =25;
    n_theta=5;
    n_psi =5;    
else
    nd_root=sqrt(ndet);
    n_theta=floor(nd_root);
    n_psi  =floor(ndet/n_theta);
    ndet   = n_theta*n_psi;
end
if ~exist('ne','var')
    ne=100;
end
th_min=5;
th_max=30;
dth   = (th_max-th_min)/(n_theta-1);
theta = (th_min+((1:n_theta)-1)*dth)';
ps_min=-10;
ps_max= 10;
dps   = (ps_max-ps_min)/(n_psi-1);
psi   = ps_min+((1:n_psi)-1)*dps;


[fp,fn]=fileparts(filename);

data.filedir =fp;
data.filename=[fn,'.spe'];
data.total_ndet=ndet;
% in mslice this is the centres of the bins
data.en =((1:ne)-2);

%
data.Ei = ne+1;
% phx
data.detfiledir =fp;
data.detfilename=[fn,'.phx'];

data.det_group =(1:ndet)';
[data.det_theta,data.det_psi] =meshgrid(theta*pi/180,psi*pi/180);
data.det_theta=reshape(data.det_theta,ndet,1);
data.det_psi=reshape(data.det_psi,ndet,1);

data.det_dtheta=ones(n_theta*n_psi,1)*dth*0.8*pi/180;
data.det_dpsi  =ones(n_theta*n_psi,1)*dps*0.8*pi/180;

[data.S,data.ERR]  =signal(data);

    function [s,e]=signal(data)
    x=data.det_theta;
    y=data.det_psi;
    z=data.en;
    [XI,ZI]=meshgrid(x,z);
    [YI,ZI]=meshgrid(y,z);

    SigmaZ=0.5*ne;
    LX = dth*n_theta;
    LY = dps*n_psi;
    s=(100*(cos(pi*(XI-0.5*LX)/(2*LX)).*cos(pi*(YI-0.5*LY)/(2*LY))).^2.*exp(-((ZI-0.5*ne)/SigmaZ).^2))';
    e=0.5./s;
end
end





