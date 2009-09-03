function mslice_finish
% closes mslice if running
%
%   >> mslice_finish

% Determine if mslice is running, and close it if it is
fig=findobj('Tag','ms_ControlWindow');
if ~isempty(fig),
    disp('Mslice control window active. Closing mslice...');
    delete(fig);
end

% Delete all mslice plot windows
taglist={'plot_slice','surf_slice','plot_cut','plot_traj'};
for i=1:numel(taglist)
    h=findobj('Tag',taglist{i});
    if ~isempty(h)
        delete(h)
    end
    h=findobj('Tag',['old_',taglist{i}]);
    if ~isempty(h)
        for j=1:numel(h)
            delete(h(j));
        end
    end
end
    