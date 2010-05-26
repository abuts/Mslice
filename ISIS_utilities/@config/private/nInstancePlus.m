function [conf,nInstance]=nInstancePlus(config)
% the function increases the number of instances of the class and returns
% current number of the instances
%
% >> [conf,nInstance]=nInstancePlus(config)
%
% $Revision$ ($Date$)
%
global configurations;

config.nInstances = config.nInstances+1;
configurations{1}=config;
nInstance = config.nInstances;
conf = config;