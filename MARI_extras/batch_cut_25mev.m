data_path='C:\mprogs\maridata\'
phxfile='C:\mprogs\mslice\mari\mari_resa.phx'
par(1)=-10;   %min energy for cut
par(2)=140;  %max energy for cut
par(3)=1;  % binwidth for cut
par(4)=10;   %min Q for cut
par(5)=11;   %max Q for cut
par(6)=40        ;   %energy for integration
par(7)=70;  %max energy for intergration

figure
title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
hold all
EI=150
Tcooling=[320, 315, 310, 305, 300, 295, 290, 285, 280, 275, 273, 271, 269, 267, 265, 263, 261, 259, 257, 255, 253, 251, 240, 220, 200, 180, 160, 140, 120, 100, 80, 60, 40, 20]
Theating=[40, 60, 80, 100, 120, 140, 160, 180 200 220 240 245 247 249 251 253 255 257 259 261,263,265,267,269,271,273,275,277,279,281,280, 285, 290, 295, 300, 305, 310, 315, 320]
data1=[];
%cooling run
numorstart=15807;
numorend=15840;
numbers=[numorstart:1:numorend]
for i=1:length(numbers)
    runnum=num2str(numbers(i))
    [data,cut,int_dat]=batch_integrate(phxfile,strcat(data_path,'MAR',runnum,'.SPE'),EI,Tcooling(i),par);
    errorbar(cut.x,cut.y,cut.e,'.')
    data1=cat(1,data1,int_dat);
    
end
cooling =data1;
data1=[];
%heating run
numorstart=15841;
numorend=15879;
numbers=[numorstart:1:numorend]
for i=1:length(numbers)
    runnum=num2str(numbers(i))
    [data,cut,int_dat]=batch_integrate(phxfile,strcat(data_path,'MAR',runnum,'.SPE'),EI,Theating(i),par);
    errorbar(cut.x,cut.y,cut.e,'.')
    data1=cat(1,data1,int_dat);
    
end
 heating=data1;

%plots 
figure
title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
hold on
errorbar(Tcooling,(cooling(:,1)),(cooling(:,2)),'bo-')
errorbar(Theating,(heating(:,1)),(heating(:,2)),'ro-')
 figure
title(cat(2,'Integration between ',num2str(par(6)),'mev',' and ', num2str(par(7)),'mev'))
hold on
plot(1./Tcooling,log(cooling(:,1)),'bo-')
plot(1./Theating,log(heating(:,1)),'ro-')


