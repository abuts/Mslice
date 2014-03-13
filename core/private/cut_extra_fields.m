function data_out=cut_extra_fields(data,OutputType)  
% Mslice cut_spe needs extra fields added to the data to enable cuts to be made/written
% See ms_cut.m where the code was originally taken from
%
% T.G.Perring   Feb 2009

data_out=data;

% Determine if single crystal. I think this can be done from the fields of data:
if isfield(data,'ar') && isfield(data,'cr') && isfield(data,'cr')
    sample=1;
else
    sample=2;
end

% === if cut to be saved in .hkl format calculate reciprocal space projections
if (sample==1)&&~isempty(findstr(lower(OutputType),'hkl')),
    % === calculate h,k,l, projections
    data.hkl = q2rlu(data);    
elseif ~isempty(findstr(lower(OutputType),'smh')),
    % === calculate h,k,l, projections if cut to be saved in smh format
    if (sample==1),	% single crystal sample either SingleCrystal or Powder AnalysisMode
        data.hkl = q2rlu(data);
    else	% sample is 'powder'
        data_out.hkl=cat(3,spe2modQ(data),data.det_theta*180/pi*ones(size(data.en)),...
            data.det_psi*180/pi*ones(size(data.en)));	% (|Q| (Angs^{-1}),2Theta (deg), Azimuth(deg))
    end
elseif ~isempty(findstr(lower(OutputType),'cut'))&&(~isempty(findstr(lower(OutputType),'mfit'))),
    data_out.MspDir='';     % we want all info to be in structure data. So just fill dummy information here
    data_out.MspFile='';
    data_out.sample=sample;	% numeric
    if sample==1,	% if sample is single crystal put also lattice parmeters
        [as,bs,cs,aa,bb,cc]=lattice_parameters(data.ar,data.br,data.cr);
        data_out.abc=[as,bs,cs;aa,bb,cc];
        % it doesn't seem necessary to fill data.uv - this info is already correct
    end
end

%--------------------------------------------------------------------------------------
function [as,bs,cs,aa,bb,cc]=lattice_parameters(ar,br,cr)
% Det the lattice parameters (Ang and degrees) from the vectors ar,br,cr
% calculated by basis_r
%
% T.G.Perring    Feb 2009

vol=dot(ar,cross(br,cr));
a=(2*pi/vol)*cross(br,cr);
b=(2*pi/vol)*cross(cr,ar);
c=(2*pi/vol)*cross(ar,br);

as=norm(a);
bs=norm(b);
cs=norm(c);

aa=(180/pi)*atan2(norm(cross(b,c)),dot(b,c));
bb=(180/pi)*atan2(norm(cross(c,a)),dot(c,a));
cc=(180/pi)*atan2(norm(cross(a,b)),dot(a,b));
