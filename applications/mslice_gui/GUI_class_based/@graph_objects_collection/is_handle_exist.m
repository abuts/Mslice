function [isthere,nh] = is_handle_exist(this,h)
 % handle already there
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
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

