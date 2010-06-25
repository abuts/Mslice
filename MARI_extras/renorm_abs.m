function data=renorm_abs(data,ratio)

for i = 1:size(data.S(:,1));
    data.S(:,i)=data.S(:,i).*(1/ratio(i));
    data.ERR(:,i)=data.ERR(:,i).*(1/ratio(i));
end


