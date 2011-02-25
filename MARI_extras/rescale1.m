function rescale(factor)

data=fromwindow;
data.S=data.S.*factor;
data.ERR=data.ERR.*factor;
towindow(data);