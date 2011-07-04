classdef graph_objects_collection
% class intended to keep togeter group of graphical objects and do general
% operation over these objects

%   Detailed explanation goes here    
    properties
        name;
        handles;
        r_min =[ 1.e+32, 1.e+32];
        r_max=[-1.e+32,-1.e+32];       
    end
    
    methods    
        %
        function this=graph_objects_collection(name,h,position)
            this.name    = name;   
            
            if (~exist('h','var'))||(~ishandle(h)) 
                this.handles={};
                return;
            end
            if exist('position','var')
                set(h,'Position',position);
            else
                position = get(h,'Position');
            end
          
            this.r_min(1)=position(1);
            this.r_min(2)=position(2);            
            this.r_max(1)=this.r_min(1)+position(3);
            this.r_max(2)=this.r_min(2)+position(4);  
            this.handles{1}=h;
        end
        %
        function this=add_handles(this,h) 
            ic=numel(this.handles);            
            if ~iscell(h)
                if ~ishandle(h); return; end                                                               
                h = {h};
            end
            
            for i=1:numel(h)
                if ishandle(h{i})
                     ic=ic+1;
                     this.handles{ic}=h{i};
                end
            end           

            if ic==1
                pos = get(this.handles{1},'Position');
                this.r_min =pos(1:2);
                this.r_max=pos(1:2)+pos(3:4);
            else
                [this.r_min,this.r_max]=find_min_max(this,this.handles,'ignore_previous_min_max');
            end

        end
        %
        function this=add_right(this,h,gap)
            if ~ishandle(h); return; end                                       
           [h_exist,nh]= is_handle_exist(this,h);
           if h_exist                                
                return                
           else
                this.handles{nh+1}=h;
           end  
     
            
            position = get(h,'Position');            
            new_position=[this.r_max(1),this.r_min(2),position(3),position(4)];
            if exist('gap','var')
                new_position(1)=new_position(1)+gap;
            end
            set(h,'Position',new_position)
            size= get(h,'Position');
            width = size(3);
            height= size(4);            
            this.r_max(1)=size(1)+width;
            if  this.r_max(2)<size(2)+size(4);  this.r_max(2)=size(2)+height;                
            end
            % do nice box;

            for i=1:nh
                alighn = false;                
                pos = get(this.handles{i},'Position');
                if pos(3)~=width
                    alighn = true;
                    pos(3) = width;
                end
                if pos(4)~=height
                    alighn = true;
                    pos(4) = height;
                end
                if alighn 
                    set(this.handles{i},'Position',pos);
                end                
            end

        end
        %
        function this=add_bottom(this,h,gap)
            if ~ishandle(h); return; end                           
            
            [h_exist,nh] = is_handle_exist(this,h);
            if h_exist                                
                return                
            else
                this.handles{nh+1}=h;
            end  

            position = get(h,'Position');            
            new_position=[this.r_min(1),this.r_min(2)-position(4),position(3),position(4)];
            if exist('gap','var')
                new_position(2)=new_position(2)-gap;
            end
            set(h,'Position',new_position)
            this.r_min(2)=new_position(2);
        end
        %
       function this=add_collection(this,collection,direction,gap)
          if ~isa(collection,'graph_objects_collection')
              error('GRAPH_OBJECT_COLLECTION:add_collection','second argument has to be graphic object collection');
          end
          if is_handle_exist(this,collection.handles)
               error('GRAPH_OBJECT_COLLECTION:add_collection','duplicate handles exist in collection');              
          end
          if ~exist('direction','var')
              direction=[1,0]; % default direction is x-direction
          end
          if numel(direction)~=2
               error('GRAPH_OBJECT_COLLECTION:add_collection','direction has to be vector of 2 elements '); 
          end
           if ~exist('gap','var')
              gap=[0,0];
           end
           if numel(gap)~=2
               error('GRAPH_OBJECT_COLLECTION:add_collection','shift has to be vector of 2 elements '); 
           end            
          
          noh  = numel(this.handles);
          nah = numel(collection.handles);
          %
         mask(1)=abs(direction(1));
         mask(2)=abs(direction(2));         
          %         
          
          r0 = this.r_min;      
          for i=1:2
            if mask(i)~=0
                    if direction(i)>=0
                              r0(i)            = this.r_max(i)+gap(i);
                              this.r_max(i)= r0(i)+get_size(collection,i);
                    else
                             r0(i)             = this.r_min(i)-get_size(collection,i)-gap(i);
                             this.r_min(i) = r0(i);
                    end
            end      
          end
  
          for i=1:nah
             h                        = collection.handles{i}; 
             if ~ishandle(h); continue; end               
             this.handles{noh+i}=h;
             point = get(h,'Position');
             r1= point(1:2);
             r  = r0+(r1-collection.r_min);
             point(1:2)=r;
             set(h,'Position',point);
          end          

        end         
        %
        function this=delete(this)
            for i=1:numel(this.handles)
                if ishandle(this.handles{i})
                    delete(this.handles{i});
                end
            end
            this.handles={};
            this.r_min   =[ 1.e+32, 1.e+32];
            this.r_max  =[-1.e+32,-1.e+32];            
            
        end
        %
        function this=make_visible(this)
            for i=1:numel(this.handles)
                set(this.handles{i},'Visible','on');
            end
        end
        % 
        function rez = isempty(this)
            rez=(numel(this.handles)>0);
        end
    % handle already there
        function [isthere,nh] = is_handle_exist(this,h)
           nh = numel(this.handles);                  
           isthere=false;          
           if numel(h)==1
                if ~ishandle(h); return; end               
                for i=1:nh
                   if  this.handles{i}==h
                       isthere= true;
                       break;
                   end               
               end
           else %multiple handles
               nah = numel(h);
                for i=1:nh
                    for j=1:nah
                        if  this.handles{i}==h{j}
                            isthere= true;
                             return;
                        end               
                    end
                end                               
           end
        end
        %
        function delta=get_size(this,i)
            delta=this.r_max(i)-this.r_min(i);            
        end
        % 
        function this=set_width(this,width,gap)
            nw = numel(width);
            if ~exist('gap','var')
                gap = zeros(nw,1);
            else
                if numel(gap)~=nw
                    error('GRAPH_OBJECT_COLLECTION:set_width',' gap, if present has to have the same size as width')
                end
            end
            ic=1;
            x1 =this.r_min(1);
            for i=1:numel(this.handles)
                pos = get(this.handles{i},'Position');
                %
                pos(3) =width(ic);
                pos(1)= x1;                
                set(this.handles{i},'Position',pos);                                    
                % next x
                x1      = x1+width(ic)+gap(ic);
                x_max= x1;
                %
                ic=ic+1;
                if ic>nw
                    ic=1;
                    x1 =this.r_min(1);
                end
            end
            this.r_max(1) = x_max;
        end
        %
        function [r_min,r_max,this]=find_min_max(this,handles,not_reset_class_min_max)
            if ~iscell(handles)
                error('GRAPH_OBJECT_COLLECTION:find_min_max',' input argument has to be cellarray of handles');
            end
            r_min =[ 1.e+32, 1.e+32];
            r_max=[-1.e+32,-1.e+32];                   
            for i=1:numel(handles)
                if isempty(handles{i})||~ishandle(handles{i}); continue; end
                
                pos = get(handles{i},'Position');
                rmi   = pos(1:2);
                rma  = pos(1:2)+pos(3:4);
                for j=1:2
                    if (rmi(j) <r_min(j)); r_min(j)=rmi(j); end
                    if (rma(j)>r_max(j));r_max(j)=rma(j); end                        
                end
            end
            if exist('not_reset_class_min_max','var')
                return;
            else
                for j=1:2
                    if (this.r_min(j) <r_min(j)); r_min(j) =this.r_min(j); end
                    if (this.r_max(j)>r_max(j));r_max(j)=this.r_max(j); end                        
                end                
                this.r_min =r_min;
                this.r_max=r_max;                
            end
        end
        %
        function pos = get_line_pos(this)
            pos(1:2)=this.r_min;
            pos1    = get(this.handles{1},'Position');
            pos(3:4)=pos1(3:4);
        end
    end
    
end

