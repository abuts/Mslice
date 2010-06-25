function data=unmask(data)

index1=data.det_group; %det groups with unmasked data in 
index2=[1:1:data.total_ndet]'; %total number of groups i.e. the size of the total spe masked and unmasked
size(data.S);
nulldata=-1e30;
ne=length(data.en);
realndet=length(index2);
data2=ones(realndet,ne).*nulldata; %creates a array of the total datafile size of null points
data2err=ones(realndet,ne).*nulldata;% the same for the error vectors
data2=zeros(length(index2),ne);
for i=1:length(index2);

     if isempty((find(index1==i)));% is element masked: then leave as null
     else
      %replace element with data
     data2(i,:)=data.S(((find(index1==i))),:);
     data2err(i,:)=data.ERR(((find(index1==i))),:); % and errors
     end

end


%fill the null array with data
   % 
data.S=data2;
data.ERR=data2err;
