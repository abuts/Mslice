function batch_subtract(phx,f1,f2,save,scale);
%batch_subtract(c:\mprogs\mslice\MARI\mari_res.phx,D:\DATA\Neutron-data\mari_data\Toluene in Vycor\data\MAR11571.spe,D:\DATA\Neutron-data\mari_data\Toluene in Vycor\data\MAR11752.spe,D:\DATA\Neutron-data\mari_data\Toluene in Vycor\data\test.spe,'e')
phx_filename=phx;
datafile=f1;
backfile=f2;
savefile=save;

data=buildspe(datafile,phx_filename);
back=buildspe(backfile,phx_filename);
% sort out scaling
if scale == 'e'
    %scale to some place (i.e. the end) of the time frame 
    j=find(data.en>2 & data.en<8)
    int_data=sum(sum(data.S(:,j),2));
    int_back=sum(sum(back.S(:,j),2));
    scale=int_data./int_back;
end
if scale == 'int'
    %scale to integral of the data set
    int_data=sum(sum(data.S,2));
    int_back=sum(sum(back.S,2));
    scale=int_data./int_back;
end
if isnumeric(scale)
    %for a fixed factor
    scale=scale
end

 r=scale
 corrected_data=data;
 corrected_data.S=data.S-(back.S.*r);
 corrected_data.ERR=sqrt(data.ERR.^2+(back.ERR.*r).^2);
 save_spe(corrected_data,savefile)

