function d=xye(w)
% Create xye tructure from IXTdataset_1d object
%
%   d = xye(w)
%
%   d.x     x coords (bin centres if input object is histogram) (row vector)
%   d.y     signal values (row vector)
%   d.e     standard deviation (row vector)

d.x=w.x; d.y=w.y; d.e=w.e;
