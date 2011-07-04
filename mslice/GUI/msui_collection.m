classdef msui_collection
 % the class supports set of objects (graph_object_collection) and special
 % add/remove operations on this set, intended to guarantee that every
 % object in the collection is created only once for every picture, the set
 % is associated with
 % 
    
    properties
        fig
        h_menu;
        collection_name; 
        element_list;
        elements_names;
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
        function this=add(this,gui_element,visible)
         % add collection of graphic elements to users menue
      
           if any(ismember(this.elements_names,gui_element.name))
               return;
           end
           n_elements = numel(this.element_list);  
           this.elements_names{n_elements+1} = gui_element.name;
           this.element_list{n_elements+1}=gui_element;
           set(this.h_menu,'UserData',this); 
           
           % default -- make gui element visible after adding it to collection;
           if ~exist('visible','var')||(~strcmpi(visible,'no'))
               make_visible(gui_element);
           end
        end
        function gr_object=get(this,element_name)
            here = ismember(this.elements_names,element_name);
            gr_object = this.element_list{here};
        end
        %
        function this=delete(this,element_names)
          to_keep  = ~ismember(this.elements_names,element_names);
          if isempty(to_keep)||all(to_keep)
              return;
          end
          this.elements_names = this.elements_names(to_keep); 
          for i=1:numel(this.element_list)
              if ~to_keep(i)
                  delete(this.element_list{i});
              end
          end
          this.element_list      =  this.element_list(to_keep);   
          set(this.h_menu,'UserData',this);
        end
        %
        function is=exist(this,name)
            is = all(ismember(name,this.elements_names));
        end
    end
    
end

