function data=load_par(par_filename)
% function to read detector parameters file from any data format supported by 
% loaders factory
%
%
%
% $Revision$ ($Date$)
%

data = get_par(par_filename,'-nohor');
