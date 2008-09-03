function store_data(wk_sp)
% stores workspace data for mslice. Used as a callback in the workspace
% menu item, 
%
% >> store_data(wk_sp)
%
% stores the data currently in the mslice window into the work space wk_sp.
%
% wk_sp must be a character. 


% h1=uimenu(h,'Label','W1','Callback','store_data(''W1'');');
% h1=uimenu(h,'Label','W2','Callback','store_data(''W2'');');
% h1=uimenu(h,'Label','W3','Callback','store_data(''W3'');');
% h1=uimenu(h,'Label','W4','Callback','store_data(''W4'');');
% h1=uimenu(h,'Label','W5','Callback','store_data(''W5'');');
% h1=uimenu(h,'Label','W6','Callback','store_data(''W6'');');

%first sort which workspace we want

% Load the dataset automatically in case the user forgets

 if strcmp('RESET', wk_sp)
            
        % reset the variables int he global var file
        ms_global_var('workspaces','clear')
            
            % reset the text strings in the mslice window
            h=findobj('Callback','store_data(''W1'');');
            set(h,'Label','W1')
            h=findobj('Callback','store_data(''W2'');');
            set(h,'Label','W2')
            h=findobj('Callback','store_data(''W3'');');
            set(h,'Label','W3')
            h=findobj('Callback','store_data(''W4'');');
            set(h,'Label','W4')
            h=findobj('Callback','store_data(''W5'');');
            set(h,'Label','W5')
            h=findobj('Callback','store_data(''W6'');');
            set(h,'Label','W6')
            
           
 else
     
     % Get the workspace variable
        workspace_var = ms_global_var('workspaces','get',wk_sp);
        
        % If it's empty, put some data in
        if isempty(workspace_var) 
                    display('Data loaded automatically')
        ms_load_data;               % make sure data is loaded
        dataset = fromwindow;       % get data from window
        if isempty(dataset)
            warning('No data has been loaded into MSlice.')
            return
        end
        h=findobj('Label',wk_sp);           % set the menu item to the filename
            set(h,'Label', dataset.filename)
            dataset.space=1;
            fprintf(['Data from %s saved to workspace'  wk_sp '\n '],dataset.filename)
            ms_global_var('workspaces','set',wk_sp,dataset)  % set the variable as global
        else        % if not empty, then load the variable into mslice.
            towindow(workspace_var)
            fprintf('Data from %s sent to mslice\n ',workspace_var.filename)
        end
 end

   