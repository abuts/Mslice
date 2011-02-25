data_path='D:\DATA\Neutron-data\in4\proline\'
par(1)=1;   %min energy for cut
par(2)=13;  %max energy for cut
par(3)=.1;  % binwidth for cut
par(4)=1;   %min Q for cut
par(5)=5;   %max Q for cut
par(6)=2;   %energy for integration
par(7)=12;  %max energy for intergration

figure
title('cuts for the 10H2o sample')
hold all
%%for the 10h2o data
datpro10h2o=[];
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-10K.spe'),17,10,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-50K.spe'),17,50,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-95K.spe'),17,95,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-145K.spe'),17,145,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-192K.spe'),17,192,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-227K.spe'),17,227,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-260K.spe'),17,260,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro10h20-273K.spe'),17,273,par);
errorbar(cut.x,cut.y,cut.e)
datpro10h2o=cat(1,datpro10h2o,int_dat);

figure
title('temperature dependence for the 10h20 sample')
hold all
temp=[10,50,95,145,192,227,260,273]'
errorbar(temp,datpro10h2o(:,1),datpro10h2o(:,2))

%for the 5h20 sample
figure
title('cuts for the 5H2O sample')
hold all

%%for the 5h2o data
datpro5h2o=[];
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-10K.spe'),17,10,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-50K.spe'),17,50,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-95K.spe'),17,95,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-145K.spe'),17,145,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-192K.spe'),17,192,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-228K.spe'),17,228,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-273K.spe'),17,273,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro5h20-282K.spe'),17,282,par);
errorbar(cut.x,cut.y,cut.e)
datpro5h2o=cat(1,datpro5h2o,int_dat);

figure
title('Temperature dependence for the 5H2O sample')
hold all
temp2=[10,50,95,145,192,228,273,282]'
errorbar(temp2,datpro5h2o(:,1),datpro5h2o(:,2))

%%for the dry sample
figure
title('cuts for the dry sample')
hold all

datprodry=[];
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-10K.spe'),17,10,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-50K.spe'),17,50,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-95K.spe'),17,95,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-145K.spe'),17,145,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-192K.spe'),17,192,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-259K.spe'),17,259,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-281K.spe'),17,281,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'prodry-298K.spe'),17,298,par);
errorbar(cut.x,cut.y,cut.e)
datprodry=cat(1,datprodry,int_dat);

figure
title('Temperature dependence for the dry sample')
hold all
temp3=[10,50,95,145,192,259,281,298]'
errorbar(temp3,datprodry(:,1),datprodry(:,2))


%d2o sample
figure
title('cuts for the D2O')
hold all

d2o=[];
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-10K.spe'),17,10,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-50K.spe'),17,50,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-95K.spe'),17,95,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-145K.spe'),17,145,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-170K.spe'),17,170,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-190K.spe'),17,190,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-227K.spe'),17,227,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-260K.spe'),17,260,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-272K.spe'),17,272,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-280K.spe'),17,280,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'d2o-295K.spe'),17,295,par);
errorbar(cut.x,cut.y,cut.e)
d2o=cat(1,d2o,int_dat);

figure
title('Temperature dependence for D2O')
hold all
temp4=[10,50,95,145,170,190,227,260,272,280,295]'
errorbar(temp4,d2o(:,1),d2o(:,2))

%proline 20:1 d20 sample
figure
title('cuts for the 20:1 proline sample')
hold all

pro20d2o=[];
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-10K.spe'),17,10,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-50K.spe'),17,50,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-95K.spe'),17,95,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-145K.spe'),17,145,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-170K.spe'),17,170,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
[data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-191K.spe'),17,191,par);
errorbar(cut.x,cut.y,cut.e)
pro20d2o=cat(1,pro20d2o,int_dat);
 [data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-227K.spe'),17,227,par);
 errorbar(cut.x,cut.y,cut.e)
 pro20d2o=cat(1,pro20d2o,int_dat);
 [data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-260K.spe'),17,260,par);
 errorbar(cut.x,cut.y,cut.e)
 pro20d2o=cat(1,pro20d2o,int_dat);
 [data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-273K.spe'),17,273,par);
 errorbar(cut.x,cut.y,cut.e)
 pro20d2o=cat(1,pro20d2o,int_dat);
 [data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-280K.spe'),17,280,par);
 errorbar(cut.x,cut.y,cut.e)
 pro20d2o=cat(1,pro20d2o,int_dat);
% [data,cut,int_dat]=batch_integrate(strcat(data_path,'in4-proline.phx'),strcat(data_path,'pro20d2o-295K.spe'),17,0,par);
% errorbar(cut.x,cut.y,cut.e)
% pro20d2o=cat(1,pro20d2o,int_dat);

figure
title('Temperature dependence for 20:1 proline')
hold all
temp5=[10,50,95,145,170,191,227,260,273,280]'
errorbar(temp5,pro20d2o(:,1),pro20d2o(:,2))