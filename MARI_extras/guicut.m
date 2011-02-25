function guicut(holding,interate,filesave,binfac)
binfac
data=fromwindow; %get the data 
% if no windows then create them
if isempty(findobj('name','Energy cut')) == true;
figure('name','Energy cut','numbertitle','off')
end
if isempty(findobj('name','|Q| cut')) == true;
figure('name','|Q| cut','numbertitle','off')
end

%find the mslice display and bring to the front
a=findobj('name','MSlice : Display');
figure(a);
[x,y]=cutbox; %get the limits for the cut interactivly
qmin=min(x);
qmax=max(x);
emin=min(y);
emax=max(y);


%find the q cut window and do the cut
hh=findobj('name','|Q| cut');

[xscale,int,interr]=simcut(data,qmin,qmax,emin,emax,2,binfac); %do the qcut
figure(hh);
if holding == 1
hold all
end
if holding == 0 & ishold == true
    hold 
end
errorbar(xscale,int,interr,'o-')
%quick to get the data out

dataout(:,1)=xscale;dataout(:,2)=int;dataout(:,3)=interr;
dataout
title1=['Qcut from ' num2str(qmin) ' A^-1 to ' num2str(qmax) 'A^-1', ': integrating from ' num2str(emin) ...
    'meV to ' num2str(emax) 'meV from ' data.filename ];
title( title1 )
xlabel('|Q| [A^-1]')
ylabel('Intensity')


%find the e cut window and do the cut
hhh=findobj('name','Energy cut');
[xscale,int,interr]=simcut(data,qmin,qmax,emin,emax,1,binfac);% do the e cut
figure(hhh)
if holding ==1
hold all
end
if holding == 0 & ishold == true
    hold 
end
errorbar(xscale,int,interr,'o-')

title2=['Ecut from ' num2str(emin) 'mev to ' num2str(emax) 'mev : integrating from ' num2str(qmin) ...
    ' A^-1 to ' num2str(qmax) ' A^-1 from ' data.filename  ];
title(title2)
xlabel('Energy Transfer [meV]')
ylabel('Intensity')