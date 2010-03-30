function mex_version=check_mex_version()
% function checks if mex-function below compiled propertly and can be executed 
% and it they do -- if the mex files are sufficiently new to support code
% version; it they support code version
% returns this version
%
% Rev:   $ ($Date$)
%
results=cell(9,1);
try  %(1)
    ver=avpix_df();
catch
    ver=['Can not check Avpix Version  ERR: ',lasterr];
end
results{1} =ver;
try %(2)
    ver=cut2d_df();
catch
    ver =['Can not check Cut2D Version, ERR: ',lasterr];
end 
results{2} =ver;
try %(3)
    ver=cut3d_df();
catch
    ver=['Can not check Cut3D Version, ERR: ',lasterr];
end
results{3} =ver;

try %(4)
    ver= cut3dxye_df();
catch
    ver=['Can not check Cut3Dxye Version, ERR: ',lasterr];
end
results{4} =ver;
try %(5)
    ver=load_spe_df();
catch
    ver=['Can not check loadSPE Version, ERR: ',lasterr];
end
results{5} =ver;

try %(6)
    ver=slice_df();
catch
    ver=['Can not check Slice Version, ERR: ',lasterr];
end
results{6} =ver;

try %(7)
    ver=slice_df_full();
catch
    ver=['Can not check Full Slice Version, ERR: ',lasterr];
end
results{7} =ver;

try %(8)
    ver=spe2proj_df();
catch
    ver=['Can not check SPE 2 proh Version, ERR: ',lasterr];
end
results{8} =ver;
try %(9)
    ver=ffind();
catch
    ver=['Can not check ffind Version, ERR: ',lasterr];
end
results{9} =ver;
mex_version =char(results);
