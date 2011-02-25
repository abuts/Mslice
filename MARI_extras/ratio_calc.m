function ratio=ratio_calc(num)


for i=1:num
    i
    dat=ginput(2);
    ratiox(i)=dat(1);
    ratioy(i)=dat(3)/dat(4);
end

ratio(:,1)=ratiox;
ratio(:,2)=ratioy;
