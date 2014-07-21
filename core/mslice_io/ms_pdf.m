function ms_pdf (file)
% Save mslice figure as a PDF file 
%
%   >> ms_pdf           % prompts for file name
%   >> ms_pdf(my_file)  % Given the file name

% Get file name - prompting if necessary
% --------------------------------------
if (nargin==0)
    file_internal = ms_putfile_full('*.pdf');
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==1)
    file_internal = file;
end

status=get(gcf, 'InvertHardCopy');
set(gcf, 'InvertHardCopy', 'on');   % control the background colour of hardcopy
print('-dpdf','-r600',file_internal);
set(gcf, 'InvertHardCopy', status); % return the background colour of hardcopy
