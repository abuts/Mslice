function ms_setvalue(field_name,value,highlight,h_cw,colour)
% Set values in the Mslice ControlWindow from the command line
%
%   >> ms_setvalue(field_name,value,[highlight,[h_cw,[colour]]])
%
% highlight  -- if present, mark set values with color, different from the
%               default one
% h_cw        -- if present, use this handle instead of default handle to
%                ms_ControlWindow
% colour     -- if present, highlight with colour provided instead of
%               default highight code (currently 'b');
% Field_name is the same name as in an msp parameter file
% For a list of field names, type >> ms_getfields
%
% value could either be numeric or string
%  - for checkboxes use 0/1
%  - for popupmenu use index 1..n or 'string'
%
% R. Coldea 18-Sep-2003
%
%  $Rev$  ($Date$)
%

% === return if Mslice ControlWindow not opened
if ~exist('h_cw','var') || isempty(h_cw)
    h_cw=findobj('Tag','ms_ControlWindow');
    if isempty(h_cw),
        disp('No Control widow opened, can not set parameter value');
        return;
    end
end
% === locate handle to field object
h=findobj(h_cw,'Tag',['ms_' field_name]);
if isempty(h)||~isnumeric(h)||(numel(h)~=1)||~ishandle(h),
    fprintf('Could not locate a unique handle to object of name %s. Return.\n',field_name);
    return;
end

% === convert value into a universal string format
if ~exist('value','var'), % if ~exist assume []
    value=[];
end
if iscell(value), % if iscell take first element
    val=value{1};
else
    val=value;
end
if isnumeric(val)&&(numel(val)==1),  % #ok<PSIZE> % if numeric transform real part into a string
    val=num2str(real(val));
elseif ischar(val)&&(min(size(val))==1), % one-dimensional string of characters
    val=val(:)'; % put characters in a row
    val=deblank(val);	% remove trailing blanks from both the beginning and end of string
    val=strtrim(val);
elseif isempty(val),
    val='';
elseif islogical(val)
    val = real(val);
else
    fprintf('Could not set value of field %s . Invalid input value type.',field_name);
    return;
end

% === set value depending on uimenu type
if strcmp(get(h,'Style'),'checkbox'),
    if (floor(str2double(val))==0)||(floor(str2double(val))==1),
        set(h,'Value',floor(str2double(val)));
        %disp(['ms_' field_name ' gets ''Value'' property ' num2str(floor(str2num(val)))]);
    elseif isnumeric(val) &&( val>=0 && val <2)
        set(h,'Value',floor(val));        
    else
        fprintf('Invalid value for a checkbox, could be only 0 or 1 (unchecked or checked)');
        return;
    end
elseif strcmp(get(h,'Style'),'popupmenu'),
    values=get(h,'String'); % with will be a list of strings
    j=[];
    for i=1:length(values),
        if strcmp(val,values{i}),
            j=i;
        end
    end
    if ~isempty(j),
        set(h,'Value',j);
        %disp(['ms_' field_name ' gets ''Value'' property ' num2str(j)]);
    else % could not identify value with one of the string values
        % perhaps value is already the index
        j=str2num(val);
        if ~isempty(j)&&isnumeric(j)&&(numel(j)==1)&&(sum(j==[1:length(values)])==1),
            % j is uniquely identified with an valid index
            set(h,'Value',j);
            %disp(['ms_' field_name ' gets ''Value'' property ' num2str(j)]);
        else
            fprintf('Invalid value type for field %s. Return.\n',field_name);
            fprintf('Valid possibilities are\n');
            fprintf('''%s'',',values{:});
            fprintf('or index numbers %d to %d\n',1,length(values));
            return;
        end
    end
else
    if exist('highlight','var')
        if exist('colour','var')
            set(h,'String',val,'ForegroundColor',colour);            
        else
            set(h,'String',val,'ForegroundColor','b');
        end
    else
        set(h,'String',val);
    end
    
    %disp(['ms_' field_name ' gets ''String'' property ' val]);
end
eval(get(h,'Callback'));
drawnow;
