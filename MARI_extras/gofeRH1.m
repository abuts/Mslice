function gofeRH1(t)
data1=fromwindow;
e=ones(size(data1.det_group))*data1.en;
q=spe2modQ(data1);
U2=input('Enter a value for the <u^2>/6  ');

sf=input('Enter scaling factor  ');

Q2=q.^2;
DW=(Q2.*U2); 
factor2=exp((-2.*DW));

bose=1-exp(-e*11.604/(t));
S=(data1.S./Q2).*(e).*(sf);
data1.ERR=(data1.ERR./Q2).*(e);

S=S.*bose./factor2;
data1.ERR=data1.ERR.*bose./factor2;
data1.S=S;
towindow(data1)