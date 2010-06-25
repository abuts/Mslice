function beE
data1=fromwindow;
e=ones(size(data1.det_group))*data1.en;



S=data1.S.*(e);
data1.ERR=data1.ERR.*(e);
data1.S=S;
towindow(data1)
