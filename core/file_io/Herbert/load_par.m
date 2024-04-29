function data=load_par(par_filename)
% function to read detector parameters file from any data format supported by 
% loaders factory
%
%
%
% $Revision: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%

data = get_par(par_filename,'-nohor');
