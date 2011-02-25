function byefac(fac)

data=fromwindow;
data.S=data.S.*fac;
data.ERR=data.ERR.*fac;
towindow(data);
