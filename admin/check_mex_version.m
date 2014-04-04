function [rez,n_errors,minVer,maxVer,compilation_date]=check_mex_version()
% function checks if mex-function below compiled propertly and can be executed
% and it they do -- if the mex files are sufficiently new to support code
% version; it they support code version
% returns this version
%
% Rev:   $ ($Date$)
%

functions_name_list={'Avpix         : ','Cut2D         : ','Cut3D         : ',...
    'Cut3Dxye      : ','loadSPE       : ','Slice_df      : ', ...
    'Slice_df_full : ','spe2proj      : ','ffind         : ', ...
    'get_ascii_file: '};
% list of the mex files handles used by horace and verified by this script.
functions_handle_list={@avpix_df,@cut2d_df,@cut3d_df,@cut3dxye_df,...
    @load_spe_df,@slice_df, @slice_df_full,...
    @spe2proj_df,@ffind,@get_ascii_file};
rez = cell(numel(functions_name_list),1);

n_errors=0;
for i=1:numel(functions_name_list)
    try
        rez{i}=[functions_name_list{i},functions_handle_list{i}()];
    catch Err
        rez{i}=[' Error in',functions_name_list{i},Err.message];
        n_errors=n_errors+1;
    end
end
%mex_version =char(res);

% calculate minumal and maximal versions of mex files; if there are errors
% in deploying mex-files, the versions become undefined;
minVer = 1e+32;
maxVer = -1;
if nargout>2 && n_errors==0
    n_mex=numel(rez);
    
    for i=1:n_mex
        ver_str=rez{i};
        ind = regexp(ver_str,':');
        ver_s=ver_str(ind(3)+1:ind(3)+5);
        ver=sscanf(ver_s,'%d');
        if ver>maxVer;
            maxVer=ver;
            al=regexp(ver_str,'\(','split');
            compilation_date  = al{3};
        end
        if ver<minVer;       minVer=ver;
        end
    end
else
    minVer=[];
    maxVer=[];
end

