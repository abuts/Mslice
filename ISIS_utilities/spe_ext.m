function ext=spe_ext()
% function is to provide compartibility between libisis and mslice but to
% allow mslice running without libisis initiated;
% the function has to retiurn the same result as the libisis spe class
% method spe_ext(spe) and have to be changed manualy if this method
% returns different results
%
% $Revision$ ($Date$)
%
ext={'*.spe',['*',spe_hdf_filestructure('spe_hdf_file_ext')]};