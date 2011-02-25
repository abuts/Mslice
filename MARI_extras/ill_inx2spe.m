function data=ill_inx2spe(fname,inst)
% converts an inx file to a .spe file for lamp to mslice convertion
% uses read_inx.. an ill supplied routine.
% read_inx produces
%        header: [4x40x396 char]
%        Par: [396x9 double]....the angles
%        Mat: [511x3x396 double]...the data
s=read_inx(fname,inst);
aa=size(s.Mat);
%get the energy vector
en=s.Mat(:,1,:);
en=reshape(en,aa(1),aa(3));
en=en(:,1);

%get the intensities
S=s.Mat(:,2,:);
S=(reshape(S,aa(1),aa(3)))';

%get the errors
err=s.Mat(:,3,:);
err=(reshape(err,aa(1),aa(3)))';

theta=s.Par(:,1);
% create a mslice type structure;
data.S=S;
data.ERR=err;
data.en=en';
data.det_theta=theta.*pi/180;
data.det_psi=theta.*0.*pi/180;
data.det_dtheta=(ones(aa(3),1)+.3).*pi/180;
data.det_dpsi=(ones(aa(3),1)+4).*pi/180;
data.total_ndet=aa(3);
data.det_group=[1:1:aa(3)];
data.filename=fname;
% now look for a mslice control window and send data to it if exists
hh=findobj('Tag','ms_ControlWindow');
if isempty(hh)
    disp('Mslice not running saving data as .spe')
    save_spe(data,strcat(fname,'.spe'))
else
    disp('Data sent to mslice control window');
    towindow(data);
end





