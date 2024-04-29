classdef graph_objects_collection
% class intended to keep togeter group of graphical objects and do general
% operation over these objects

%   Detailed explanation goes here    
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%
    properties
        name;    % group name
        handles; % list of handles for graphical objects
        r_min = [ 1.e+32, 1.e+32];  % min screen value of the composed object position
        r_max = [-1.e+32,-1.e+32];  % max screen value of the composed object position
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
           %
 
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
        % find min-max screen values of the object group. 
        %
            if ~iscell(handles)
                error('GRAPH_OBJECT_COLLECTION:find_min_max',' input argument has to be cellarray of handles');
            end
            r_min = [ 1.e+32, 1.e+32];
            r_max = [-1.e+32,-1.e+32];                   
            for i=1:numel(handles)
                if isempty(handles{i})||~ishandle(handles{i}); continue; end
                
                pos = get(handles{i},'Position');
                rmi = pos(1:2);
                rma = pos(1:2)+pos(3:4);
                for j=1:2
                    if (rmi(j) < r_min(j)); r_min(j)=rmi(j); end
                    if (rma(j) > r_max(j)); r_max(j)=rma(j); end                        
                end
            end
            if exist('not_reset_class_min_max','var')
                return;
            else
                for j=1:2
                    if (this.r_min(j) <r_min(j)); r_min(j) = this.r_min(j); end
                    if (this.r_max(j)>r_max(j));r_max(j)   = this.r_max(j); end                        
                end                
                this.r_min = r_min;
                this.r_max = r_max;                
            end
        end
        %
        function pos = get_line_pos(this)
            pos(1:2) = this.r_min;
            pos1     = get(this.handles{1},'Position');
            pos(3:4) = pos1(3:4);
        end
    end
    
end

