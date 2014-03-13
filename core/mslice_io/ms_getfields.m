function vals = ms_getfields
% Get names of values that can be set with ms_getvalue (?).
% Requires that mslice is running.
%
%   >> vals = ms_getfields
%
% T.G.Perring 13 July 2005
%
% $Rev$  ($Date$)
%
% After examining the function ms_setvalue, the following would appear to get
% all the tags corresponding to mslice variables
h_cw=findobj('Tag','ms_ControlWindow');
h=findobj(h_cw);
a=get(h,'Tag'); % all the tags

% Now get a list of the ones beginning 'ms_'
cell_ind=strfind(a,'ms_');
ind=zeros(length(cell_ind),1);
for i=1:length(cell_ind)
    if ~isempty(cell_ind{i}) && cell_ind{i}==1
        ind(i)=i;
    end
end
vals=a(find(ind~=0));

% Strip off leading 'ms_'
for i=1:length(vals)
    vals{i} = vals{i}(4:end);
end
