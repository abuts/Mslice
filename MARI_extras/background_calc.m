function background_calc
yy=ginput(2)
fac=sqrt(yy(4)./yy(3))
time=input('Enter accumulated uamps in sample run  ')
disp('Count background for')
time_back=fac.*time