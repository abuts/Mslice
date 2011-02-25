function e2t(ei)
%calc the delay for the thick disk geven ei
% flight path = 8.5m
% t_delay=?
fl=7.05;            %monitor1
fl2=10.297;         %fermi mon2
fl3=10.297+1.3+4;   %detectors
fmon3=17.5
t_delay=0;
tt_delay=1198;
speed=50;
tt=((2286.26.*fl)./sqrt(ei));
tts=((2286.26.*fl)./sqrt(ei))+tt_delay;
ttt=((2286.26.*fl2)./sqrt(ei))+t_delay;
tttt=((2286.26.*fl3)./sqrt(ei))+t_delay;
tmon3=((2286.26.*fmon3)./sqrt(ei))+t_delay;
disp(sprintf('Thick disk delay (m4)is %15.5f usec',tt))
disp(sprintf('Set Thick disk delay at %15.5f usec',tts))
disp(sprintf('Fermi delay (m2) is     %15.5f usec',ttt))
disp(sprintf('Detector signal  4m     %15.5f usec',tttt))
disp(sprintf('Mon 3                   %15.5f usec',tmon3))