function [q,F]=formfactor;

%calcs teh formfactor as defined in http://www.ill.fr/index_sc.html
A=.4198
B=0.6054
C=0.9241
D=-0.9498
a=14.2829
b=5.4689
c=-0.0088
s=[0:.01:1];
f=A.*exp(-a.*(s.^2))+B.*exp(-b.*(s.^2))+A.*exp(-a.*(s.^2))+C.*exp(-c.*(s.^2))+D;
q=s.*(4*pi);
F=f.^2;
%plot(q,F)

