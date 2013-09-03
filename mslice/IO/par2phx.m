function par2phx(parfile,phxfile)
% Convert a parameter file from a .par format into a .phx format 
%
%   >> par2phx (parfile, phxfile)
%
% *** ISIS changes
% T.G.Perring   6 Aug 2007:
%   Original code by Radu Coldea, but TGP has modified it to read 5 or 6 column format par files
%
% T.G.Perring   29 Aug 2013:
%   Corrected to reverse sign in the convention for azimuthal angle

% Read data from file
%--------------------
f1=fopen(parfile,'rt');
n=fscanf(f1,'%f \n',1);
% Determine if 5 or 6 columns:
istart=ftell(f1);
ncol = length(str2num(fgets(f1)));
fstatus=fseek(f1,istart,'bof'); % step back one line
if ncol==5
    data=fscanf(f1,'%f %f %f %f %f');
    data=reshape(data,5,n)';
    gp=(1:n);       % detector group number 1:n
else
    data=fscanf(f1,'%f %f %f %f %f %f');
    data=reshape(data,6,n)';
    gp=data(:,6);
end
fclose(f1);

% Perform conversions
% -------------------
d=data(:,1);		% distance to detectors (m)
th=data(:,2);		% scattering angle (deg)
az=-data(:,3);		% azimuthal angle (deg)     % *** NOTE sign reversal of psi (added TGPerring 29 Aug 2013)
w=data(:,4);		% detector width (m)
h=data(:,5);		% detector height (m)
angw=2*atan((w/2)./d)*(180/pi);
%angw=0.63*ones(size(angw));	% put extra width in detectors to cover space between them too
angh=2*atan((h/2)./d)*(180/pi);
 
% Write out phx file
% ------------------
phoenix=[10*ones(size(d))';zeros(size(d))';th';az';angw';angh';gp']';
f2=fopen(phxfile,'wt');
fprintf(f2,'%d \n',n);
fprintf(f2,'%5.3g %5.3g %10.4f %10.4f %10.4f %10.4f %8d \n',phoenix');
fclose(f2);
disp(['Saved information for ' num2str(n) ' detectors to .phx file : ' phxfile]);
