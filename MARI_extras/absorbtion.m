function r=absorbtion(phx);
%calculates an absorbtion correction factor for the annualr geometry from
%bashirs published transmission factors
% reqs phx: vector containing 2 theta values 
% from bashirs paper
%data40=[16.05 22.09 27.43 33.06 39.23 46.14 53.99 63.01 73.58 86.41 104.61];
data20=[101.91 108.15 110.97 113.98 118.00 123.50 130.90 140.82 154.30 173.47 204.77];
%data10=[284.23 290.67 289.58 288.52 288.78 290.63 294.33 300.45 310.22 326.82 363.68];
ttheta=[0    40    54    66    80    90   102   114   126   144   180];

r=interp1(ttheta,data20./1000,phx);