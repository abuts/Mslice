function [isthere,nh] = is_handle_exist(this,h)
 % handle already there
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%
 
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

