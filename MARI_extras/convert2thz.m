function convert2thz
%converts the energy scale to teraherz
data=fromwindow;
data1=data;
data1.vb(:,:,2)=data1.vb(:,:,2).*.2418;
data1.vb(:,:,4)=data1.vb(:,:,4).*.2418;
data1.v(:,:,2)=data1.v(:,:,2).*.2418;
towindow(data1);