function rescale2(factor)

data=fromwindow;
data.S=data.S-factor;
data.ERR=data.ERR;
towindow(data);