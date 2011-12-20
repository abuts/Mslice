function data=rebin_cryst_img_to_rings(data)
% function rebins spe data (singals and errors), obtained as function theta&phi of detecors into 
% rings of equal phi+dPhi values;
%
%>> data=rebin_cryst_img_to_rings(data);
%  where data mast have fields:
%  S, Err, (as in spe) and
%  det_theta,det_psi,det_group,det_dtheta,det_dpsi as in phx file
%  

fields_requested={'S','ERR','det_theta','det_psi','det_dtheta','det_dpsi','det_group'};
% fields exisiting:
fle  = fields(data);
if ~all(ismember(fields_requested,fle))
    error('MSLICE:rebin_cryst_img_to_rings','input data do not have all requested fields');
end
%
if numel(data.det_theta) ~= size(data.S,1)
    error('MSLICE:rebin_cryst_img_to_rings','Signal dimension does not coinside with number of detectors');
end

if ~isfield(data,'range')
    range.polar_min=[];
    range.polar_max=[];    
    range.polar_delta=[];
else
   range = data.range;
end
% veryfy reninning ranges
min_pol  = min(data.det_theta);
max_pol = max(data.det_theta);
pol_step = min(data.det_dtheta);
if isempty(range.polar_min)||range.polar_min<min_pol   % if limits changed, the GUI values have to change too.
    range.polar_min = min_pol;
    ms_setvalue('polar_min',min_pol*180/pi,'highlight');    
else
    min_pol = range.polar_min;
end
if isempty(range.polar_max)||range.polar_max>max_pol;   % if limits changed, the GUI values have to change too.
      range.polar_max = max_pol;
      ms_setvalue('polar_max',max_pol*180/pi,'highlight');
else
      max_pol   = range.polar_max;
end
if isempty(range.polar_delta)||range.polar_delta<pol_step % if limits changed, the GUI values have to change too.
    range.polar_delta = pol_step;
    ms_setvalue('polar_delta',pol_step*180/pi,'highlight');    
else    
    pol_step = range.polar_delta;    
end
if (range.polar_min>max_pol)||(range.polar_max<min_pol)
    error('MSLICE:rebin_cryst_img_to_rings','no detectors in angular range from %d to %d, no remapping performed',range.polar_min,range.polar_max);
end
data.range = range;
% multiply to radde2deg
%
% Rebin: despite dtheta is different, here we ignore this fact for the time
% being; (which can be deeply right)
%
% calculate indexes of old psi-s wrt the new bins
psi_ind = floor((data.det_theta-min_pol)/pol_step)+1;
ind_max = floor((max_pol-min_pol)/pol_step)+1; % 
%
valid       = psi_ind>0 & psi_ind<=ind_max;
% select  arrays elements which fit into the angular range requested;
S        =  data.S(valid,:);
ERR      =  data.ERR(valid,:);
psi_ind  = psi_ind(valid); % make indexes column-wise as this is accumarray request
rez_size = size(S);
mm       = rez_size(1)*rez_size(2);
S        = reshape(S,mm,1);
ERR      = reshape(ERR,mm,1);

% extend indexes to all energies, as every detector contributes in number
% of energies;
psi_ext  = repmat(psi_ind,1,rez_size(2));
for i=1:rez_size(2)
    psi_ext(:,i)  = psi_ext(:,i)+(i-1)*ind_max;
end
psi_ext  = reshape(psi_ext,mm,1);
% calculate number of detectors, contributed into each bin;
n_hits    =   ones(numel(psi_ind),1);
n_det     =   accumarray(psi_ind,n_hits);
n_det_ex  =   reshape(repmat(n_det,1,rez_size(2)),ind_max*rez_size(2),1);

%
SS         = (accumarray(psi_ext,S)./n_det_ex);
SE         = sqrt(accumarray(psi_ext,ERR.*ERR)./n_det_ex);
nans       = isnan(SS); % make NaN sticky i.e any nan contrubuting to a cell invalidates cell. 
SS(nans)=NaN;
SE(nans)=0;

data.S    = reshape(SS,ind_max,rez_size(2));
data.ERR  = reshape(SE,ind_max,rez_size(2));
% redefine new detectors, which correspond to valid values; 
data.det_theta = (min_pol:pol_step:max_pol)';
data.det_dtheta= ones(ind_max,1)*pol_step;
data.det_psi   = zeros(ind_max,1);
data.det_dpsi  = ones(ind_max,1); % should be recalculated as an average?
% det_group left untouched -- should we regroup them?
% det_id=data.det_group(valid);
% block=[psi_ind,det_id];
% block = sortrows(block,1);
% [n_cells,det_ind]=unique(block(:,1),'first');
% data.det_group = block(det_ind,2);
data.det_group= (1:ind_max)';
