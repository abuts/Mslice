function phx2par(phxfile,parfile,l2)
% Convert a .phx file into a .par format 
%
%   >> phx2par (phxfile, parfile, l2)
%
% Change history:
%   T.G.Perring   29 Aug 2013:
%   Corrected to reverse sign in the convention for azimuthal angle
%   Write out more significant figures

% phx=load_phx(phxfile);
% if isempty(phx),
% 	return
% end

% Read data from file
%--------------------
f1=fopen(phxfile,'rt');
n=fscanf(f1,'%f \n',1);
data=fscanf(f1,'%f');
fclose(f1);
data=reshape(data,7,n)';

% Convert input
% -------------
group=data(:,7);            % Detector group number
theta=data(:,3);            % scattering angle (deg)
psi=data(:,4);              % azimuthal angle (deg)
dtheta=data(:,5)*pi/180;    % detector width (deg -> radians)
dpsi=data(:,6)*pi/180;		% detector height (deg -> radians)
x2=l2.*ones(size(theta));

w=2*x2.*tan(dtheta/2);      % detector width (m)
h=2*x2.*tan(dpsi/2);        % detector height (m)

par=[x2';theta';-psi';w';h';group'];    % *** NOTE sign reversal of psi (added TGPerring 29 Aug 2013)

fid=fopen(parfile,'wt');
fprintf(fid,'%d \n',n);
fprintf(fid,'%10.4f %10.4f %10.4f %10.4f %10.4f %8d \n',par);
fclose(fid);
disp(['Saved information for ' num2str(n) ' detectors to .par file : ' parfile]);
