function sub=subtract2(samp,back,r)
%data=fromwindow
 m=size(samp.S,1)
for i=1:m
     back.S(i,:)=back.S(i,:).*r(i);
     back.ERR(i,:)=back.ERR(i,:).*r(i);
end
sub=samp;

sub.S=samp.S-back.S;
sub.ERR=sqrt(samp.ERR.^2+back.ERR.^2);