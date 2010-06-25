function [data,cut,int_dat]=batch_integrate(phx,f1,energy,temp,par,dir);
%function loads calculates projections and plots a cut and integrates in an energy window
%will correct for bose factor if temp >0
%[data,cut,int_dat]=batch_integrate('c:\mprogs\mslice\MARI\mari_res.phx','D:\DATA\Neutron-data\mari_data\Toluene in Vycor\data\MAR11571.spe',18,0);

%%par is a set of paramters of length 7
% par(1)=min energy for cut
% par(2) max energy for cut
% par(3) binwidth for cut
% par(4) min Q for cut
% par(5) max Q for cut
% par(6) min energy for integration
% par(7) max energy for intergration
% dir is direction for the cut 1=Q 2=energy

%sort out par array given direction
temparray=par;
if dir == 1
    %Qcut
    par(1)=temparray(4);
    par(2)=temparray(5);
    par(3)=temparray(3);
    par(4)=temparray(1);
    par(5)=temparray(2);
else
end
phx_filename=phx;
datafile=f1;

data=buildspe(datafile,phx_filename);

data.emode=1;
data.efixed=energy;

data.axis_label=str2mat(2,1);
data.axis_unitlabel=str2mat('','','');
data.title_label='';
data.u=[2;1];
data=calcprojpowder(data);

if temp>0
    %correct for bose factor
    e=ones(size(data.det_group))*data.en;
    bose=1-exp(-e*11.604/temp);
    S=data.S.*bose;
    data.S=S;
    data.ERR=data.ERR.*bose;
end
% cut parameters for toluene data
% vx_min=0
% vx_max=17
% bin_vx=.1
% vy_min=0
% vy_max=5
% i_min=''
% i_max=''
% out_type=''
% out_file=''
% tomfit=''
% cut params for proline data in4
vx_min=par(1)
vx_max=par(2)
bin_vx=par(3)
vy_min=par(4)
vy_max=par(5)
i_min=''
i_max=''
out_type=''
out_file=''
tomfit=''
cut=cut_spe2(data,dir,vx_min,vx_max,bin_vx,vy_min,vy_max,i_min,i_max,out_type,out_file,tomfit)
%cut is structure array cut.x cut.y cut.e
% int_dat is the integral and error between the limits set 
  j=find(cut.x>par(6) & cut.x<par(7))  %2.8-3.5
  int_dat(:,1)=sum(cut.y(j),2)./length(j)
  int_dat(:,2)=(sqrt(sum(cut.e(j),2).^2))./length(j)