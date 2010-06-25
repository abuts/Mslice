function data1=bosefactor(t);
%calc bose correction for spe files
%requires temp input
data1=fromwindow;
e=ones(size(data1.det_group))*data1.en;
bose=1-exp(-e*11.604/t);
%S=data1.S./e;
%S=S.*bose;
S=data1.S.*bose;
data1.S=S;
data1.ERR=data1.ERR.*bose;
towindow(data1)
