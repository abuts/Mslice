function plotma(MA_d, i_min, i_max, edgecolor);
%function plotma(MA_d, i_min, i_max, edgecolor);
%
% to plot a MA_d slice, 
%
% Syntax
%           plotma(MA_d, i_min, i_max, edgecolor)
%           plotma(MA_d, i_min, i_max)
%           plotma(MA_d, i_min)
%           plotma(MA_d)
%
% Description 
%           ms_MA(NLEVEL, NS) display a multiresolution slice, where NLEVEL= number of levels 
%           the algorithm will cover. Starting from Dx, Dy (loaded from MSlice Control Window)
%           to dx= Dx/(2.^(NLEVEL-1)), dy= Dy/(2.^(NLEVEL-1)). where NS is the noise-to-signal 
%           ratio; ERR/S. That will act as a threshold. Resulting in a image, which ERR/S is
%           below the imposed value NS.
%___________________________________________________________________________________________
% More Info: 'A multiresolution data visualization tool for applications in neutron 
%             time-of-flight spectroscopy' Nuclear Instruments and Methods
%             2005.
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/2.0/ 
% or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
%___________________________________________________________________________________________
%colordef none

if (~exist('MA_d','var')|isempty(MA_d))
   disp('## plot cannot be performed if MA_d is not specified.');
   return;
end

if ~exist('i_min','var')|isempty(i_min)|~isnumeric(i_min)|(length(i_min)~=1)
   i_min=min(min(MA_d.SS));   
end

if ~exist('i_max','var')|isempty(i_max)|~isnumeric(i_max)|(length(i_max)~=1)
   i_max=max(max(MA_d.SS));   
end


p2=patch(MA_d.X2,MA_d.Y2,MA_d.S2);
set(p2,'EdgeColor','none');
p1=patch(MA_d.XX,MA_d.YY,MA_d.SS);
if (~exist('edgecolor','var')|(isempty(edgecolor))),
    set(p1,'EdgeColor','none');
else
    set(p1,'EdgeColor',edgecolor);
end
%p3=patch(MA_d.XR,MA_d.YR,[1,1,1]);
%set(p3,'FaceColor','none');
dfcolor=get(0,'defaults');
dfcolor=dfcolor.defaultSurfaceEdgeColor;
p3=patch(MA_d.XR,MA_d.YR,dfcolor);
set(p3,'EdgeColor','none');


caxis([i_min,i_max]);

axis on
box on
grid on