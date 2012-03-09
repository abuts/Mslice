function par2phx(parfile,phxfile)

% programme to convert a parameter file from a .par format into a .phx format 
% to be used in phoenix 

% *** ISIS changes
% T.G.Perring   6 Aug 2007:
%   Original code by Radu Coldea, but TGP has modified it to read 5 or 6 column format par files


f1=fopen(parfile,'rt');
n=fscanf(f1,'%5d \n',1);
% Determine if 5 or 6 columns:
istart=ftell(f1);
ncol = length(str2num(fgets(f1)));
fstatus=fseek(f1,istart,'bof'); % step back one line
if ncol==5
    data=fscanf(f1,'%f %f %f %f %f');
    data=reshape(data,5,n)';
else
    data=fscanf(f1,'%f %f %f %f %f %f');
    data=reshape(data,6,n)';
end
fclose(f1);

%eval(['load ' parfile ' -ascii']);
d=data(:,1);		% distance to detectors (m)
th=data(:,2);		% scattering angle (deg)
az=data(:,3);		% azimuthal angle (deg)
w=data(:,4);		% detector width (m)
%w=ones(size(az))*0.03;
h=data(:,5);		% detector height (m)

angw=2*atan((w/2)./d)*180/pi;
angw=0.63*ones(size(angw));	% put extra width in detectors to cover space between them too
%angw(33:(90-32))=0.39;
angh=2*atan((h/2)./d)*180/pi;
 
phoenix=[10*ones(size(d))';zeros(size(d))';th';az';angw';angh';zeros(size(d))']';
f2=fopen(phxfile,'wt');
fprintf(f2,'%3d \n',size(phoenix,1));
fprintf(f2,'%5.3g %5.3g %7.4g %7.4g %7.4g %7.4g %7.4g \n',phoenix');
fclose(f2);
