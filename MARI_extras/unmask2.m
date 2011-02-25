function unmask2(fname)
% unmasks and save the spefile with name fname
data=fromwindow
index1=data.det_group %det groups with unmasked data in 
index2=[1:1:data.total_ndet]'; %total number of groups i.e. the size of the total spe masked and unmasked
size(data.S)
nulldata=-1e30
ne=length(data.en)
realndet=length(index2)
data2=ones(realndet,ne).*nulldata; %creates a array of the total datafile size of null points
data2err=ones(realndet,ne).*nulldata;% the same for the error vectors
whos
data2=zeros(length(index2),ne);
for i=1:length(index2)

     if isempty((find(index1==i)))% is element masked: then leave as null
     else
      %replace element with data
     data2(i,:)=data.S(((find(index1==i))),:);
     data2err(i,:)=data.ERR(((find(index1==i))),:); % and errors
     end

end
%fill the null array with data
% 

de=data.en(1,2)-data.en(1,1);
en_grid=[ data.en-de/2 data.en(1,ne)+de/2];
en_grid=round(en_grid*1e5)/1e5;	%truncate at the 5th decimal point

data.S=data2';
data.ERR=data2err';
data.det_theta=ones(length(data.S),1);
data.en=en_grid;
put_spe(data,fname)