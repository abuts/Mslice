function data=load_par(par_filename)
% function to read detector parameters file from any data format supported by 
% loaders factory
%
%
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)
%

data = get_par(par_filename,'-nohor');
