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
        function rez = isempty(this)
            rez=(numel(this.handles)>0);
        end
        %
        function delta=get_size(this,i)
            delta=this.r_max(i)-this.r_min(i);            
        end
        % 
        %
        function pos = get_line_pos(this)
            pos(1:2) = this.r_min;
            pos1     = get(this.handles{1},'Position');
            pos(3:4) = pos1(3:4);
        end
    end
    
end

