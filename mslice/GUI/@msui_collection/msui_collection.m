classdef msui_collection
% the class supports set of objects (graph_object_collection) and special
% add/remove operations on this set, intended to guarantee that every
% object in the collection is created only once for every picture, the set
% is associated with
% 
    
properties
  fig    % the hanlde for the picture, this object belong
  h_menu; % pointer? to itself
  collection_name; % name for this collection
  element_list;    % list of its graphical elements (handles)
  elements_names;  % Names of the handles
end
    
    methods
        function this=msui_collection(fig,collection_name)
            if ~ishandle(fig)
                error('MATLAB:msui_collection',' has to be initiated with valid picture handle');
            end
            % make this class an fig-related singleton;
            hm  = findobj('Tag',collection_name);
            if isempty(hm)
                this.fig=fig;
                this.element_list = struct([]);
                this.elements_names={};
                this.collection_name=collection_name;
            % allows to retrieve this class accessing the figure;
                this.h_menu=uimenu(fig,'Visible','off','UserData',this,'Tag',collection_name);
                set(this.h_menu,'UserData',this);   
            else
                this = get(hm,'UserData');
                this.h_menu = hm;
            end
                
        end
        %
        function gr_object=get(this,element_name)
            here = ismember(this.elements_names,element_name);
            gr_object = this.element_list{here};
        end
        %
        %
        function is=exist(this,name)
            is = all(ismember(name,this.elements_names));
        end
    end
    
end

