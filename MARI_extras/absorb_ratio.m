function data=absorb_ratio(data,r)
%multiplies a spe file by a 2theta dependent absorbtion factor
% r must be the same length as the phx file det_group 
%data=fromwindow
 m=size(data.S,1)
for i=1:m
     data.S(i,:)=data.S(i,:).*r(i);
     data.ERR(i,:)=data.ERR(i,:).*r(i);
end
