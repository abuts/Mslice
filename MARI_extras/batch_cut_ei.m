data_path='C:\mprogs\maridata\'
phxfile='C:\mprogs\Mslice\mslice\MARI\mari_resa.phx'
par(1)=-200;   %min energy for cut
par(2)=200;  %max energy for cut
par(3)=1;  % binwidth for cut
par(4)=0;   %min Q for cut
par(5)=10;   %max Q for cut
par(6)=-200        ;   %energy for integration
par(7)=200;  %max energy for intergration

figure(99);
clf;
title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
hold all
EI=534;
Tcooling=[534, 544, 553.4183, 563.85, 573.508, 582.622, 591.911, 602.100, 611.015,...
    620.370, 629.608,639.556, 649.557,659.757,669.214,677.431,687.048, 697.746, 706.263...
    716.551, 726.991, 735.053, 745.649, 754.909, 763.799, 775.540, 784.731, 794.276, 802.493...
    812.455, 821.763, 831.633, 840.621, 849.947, 861.432, 869.750, 878.955 ];

data1=[];
%cooling run
numorstart=16029;
numorend=16065;
numbers=[numorstart:1:numorend]
for i=1:length(numbers)
    runnum=num2str(numbers(i))
    EI=Tcooling(i)
    [data,cut,int_dat]=batch_integrate(phxfile,strcat(data_path,'MAR',runnum,'.SPE'),EI,Tcooling(i),par);
    errorbar(cut.x,cut.y,cut.e,'.')
    data1=cat(1,data1,int_dat);
    
end
 cooling =data1;
% data1=[];
% %heating run
% numorstart=15841;
% numorend=15879;
% numbers=[numorstart:1:numorend]
% for i=1:length(numbers)
%     runnum=num2str(numbers(i))
%     [data,cut,int_dat]=batch_integrate(phxfile,strcat(data_path,'MAR',runnum,'.SPE'),EI,Theating(i),par);
%     errorbar(cut.x,cut.y,cut.e,'.')
%     data1=cat(1,data1,int_dat);
%     
% end
%  heating=data1;
% 
%plots 
figure(100);
clf;
title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
hold on
errorbar(Tcooling,(cooling(:,1)),(cooling(:,2)),'bo-')
%errorbar(Theating,(heating(:,1)),(heating(:,2)),'ro-')
%  figure
% title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
% hold on
% plot(1./Tcooling,log(cooling(:,1)),'bo-')
% plot(1./Theating,log(heating(:,1)),'ro-')


