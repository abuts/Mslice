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
