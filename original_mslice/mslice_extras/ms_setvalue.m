function ms_setvalue(field_name,value)
% Set values in the Mslice ControlWindow from the command line
%
%   >> ms_setvalue(field_name,value)
%
% For a list of field names, type >> ms_getfields
%
% field_name is the same name as in an msp parameter file 
% value could either be numeric or string  
% for checkboxes use 0/1
% for popupmenu use index 1..n or 'string' 
% R. Coldea 18-Sep-2003

% === return if Mslice ControlWindow not opened 
h_cw=findobj('Tag','ms_ControlWindow');
if isempty(h_cw),
   disp(['No Control widow opened, can not set parameter value']);
   return;
end

% === locate handle to field object
h=findobj(h_cw,'Tag',['ms_' field_name]);
if isempty(h)|~isnumeric(h)|(prod(size(h))~=1)|~ishandle(h),
    disp(sprintf('Could not locate a unique handle to object of name %s. Return.',field_name));
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
if isnumeric(val)&(prod(size(val))==1),  % if numeric transform real part into a string 
    val=num2str(real(val));
elseif ischar(val)&(min(size(val))==1), % one-dimensional string of characters
    val=val(:)'; % put characters in a row
    val=deblank(val);	% remove trailing blanks from both the beginning and end of string
   	val=fliplr(deblank(fliplr(val)));    
elseif isempty(val),
    val='';
else
    disp(sprintf('Could not set value of field %s . Invalid input value type.',field_name));
    return;
end    
    
% === set value depending on uimenu type
if strcmp(get(h,'Style'),'checkbox'),
    if (floor(str2num(val))==0)|(floor(str2num(val))==1), 
        set(h,'Value',floor(str2num(val)));
   	    %disp(['ms_' field_name ' gets ''Value'' property ' num2str(floor(str2num(val)))]);           
    else 
        disp(sprintf('Invalid value for a checkbox, could be only 0 or 1 (unchecked or checked)'));
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
         if ~isempty(j)&isnumeric(j)&(prod(size(j))==1)&(sum(j==[1:length(values)])==1),
             % j is uniquely identified with an valid index
             set(h,'Value',j);
	         %disp(['ms_' field_name ' gets ''Value'' property ' num2str(j)]); 
         else
             disp(sprintf('Invalid value type for field %s. Return.',field_name));
             disp(sprintf('Valid possibilities are'));
             disp(sprintf('''%s'',',values{:}));
             disp(sprintf('or index numbers %d to %d',1,length(values)));
             return;
         end    
    end 
else
    set(h,'String',val);
   	%disp(['ms_' field_name ' gets ''String'' property ' val]); 
end    
eval(get(h,'Callback'));
drawnow;