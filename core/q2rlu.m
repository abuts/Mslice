function hkl=q2rlu(data,varargin)

[use_mex,force_mex] = get(mslice_config,'use_mex','force_mex_if_use_mex');    
if isstruct(data)
    if use_mex
        try % fortran optimised routine
            %data.hkl=zeros(length(data.det_group),length(data.en),3);
            %[data.hkl(:,:,1),data.hkl(:,:,2),data.hkl(:,:,3)]=...
            %    spe2proj_df(data.emode,data.efixed,data.en,...
            %    data.det_theta,data.det_psi,data.psi_samp,...
            %   [aa 0],[bb 0],[cc 0]);
            %disp('Using spe2proj_df for smh');
            [aa,bb,cc]=basis_hkl(data.ar,data.br,data.cr);            
            [v1,v2,v3]=spe2proj_df(data.emode,data.efixed,data.en,...
                                   data.det_theta,data.det_psi,data.psi_samp,...
                                  [aa 0],[bb 0],[cc 0]);
            
            hkl = [v1,v2,v3];
        catch            
            if force_mex 
                error('MSLICE:q2rlu',' can not use mex when forced to do it');
            end
            use_mex = false
            warning('mslice:q2rlu',['Fortran optimised routine failed with error: ',lasterr()]);    
        end
    end
    if ~use_mex        
        hkl=q2rlu_m(sqe2samp(spe2sqe(data),data.psi_samp),data.ar,data.br,data.cr);  % (h,k,l)
    end   
else
    ar = varargin{1};
    br = varargin{2};    
    cr = varargin{3};
    hkl=q2rlu_m(data,ar,br,cr);  % (h,k,l)
end

   
   
   