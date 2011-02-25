function resize_plot
% sets the aspect ratio to 1 to 1 to overcome the everdecreasing size of the figure produced by 
% multiple plots in mslice

hh=gca;
set(hh,'PlotBoxAspectRatio',[1 1 1])