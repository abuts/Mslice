function mslice_start
% Starts up mslice if not already started
%
%   >> mslice_start


% Determine if mslice is running, and try to open if it is not
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
    disp('Mslice control window not active. Starting mslice...');
    disp (' ')
    mslice
    disp (' ')
    opened_mslice = findobj('Tag','ms_ControlWindow');
    if isempty(opened_mslice),
        error('ERROR: Unable to start mslice. Please check your mslice setup.');
    end
end

