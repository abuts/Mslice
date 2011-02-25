function [qdat2,intdat,interr]=simcut(data,qmin,qmax,emin,emax,dir,binfac)

%dir direction of integration 1=along e 2=along q


q=data.v(:,:,1);
e=data.v(:,:,2);
%[i,j]=ind2sub(size(q),find(q>1 & q<10 & e>-1 &e <1));
%binfac=2;

[i,j]=find(q>qmin & q<qmax & e>emin & e <emax);
%there are then one q scale for each energy step in the range
de=abs(data.en(1)-data.en(2)); %is the energy step
numq=floor(emax-emin./de);

epix=max(j)-min(j);
qpix=max(i)-min(i);
pix=qpix;
xscale =e;
if dir>1
    pix=epix;
    xscale =q;
end


qdat2=sum(xscale([min(i):max(i)],[min(j):max(j)]),dir)./pix;

intdat=sum(data.S([min(i):max(i)],[min(j):max(j)]),dir)./epix;
interr=sqrt(sum(data.ERR([min(i):max(i)],[min(j):max(j)]).^2,dir))./epix;

if dir==1
    intdat=intdat';
    interr=interr';
    qdat2=qdat2';
end

if binfac>1
    intdat=bin(intdat,binfac)./binfac;
    interr=bin(interr,binfac)./binfac;
    qdat2=bin(qdat2,binfac)./binfac;
end






