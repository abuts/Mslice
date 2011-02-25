function sub=rescale_spe(samp,back,xfac,zfac)
% rescales the x(energy) and the intensity of an spe dataset
% scales sample datset to the background

aaa=length(samp.en);
n1=samp.en(1);
n2=samp.en(aaa);
del1=(n2-n1)/aaa;
del2=round(xfac/del1)
%samp.en=samp.en-xfac;
 SS=zeros(285,1200);
 SSS=samp.S;
 for i=1:length(SS)-del2;
     SS(:,i)=SSS(:,(i+del2));
 end;
samp.S=SS;
samp=calcprojpowder(samp);

sub=samp;
sub.S=samp.S-(back.S.*zfac);
sub.ERR=sqrt(samp.ERR.^2+back.ERR.^2);
towindow(sub)