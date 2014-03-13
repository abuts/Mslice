function this=add_handles(this,h) 
% Method adds list of graphical handles to the existing object collection
%
% Modifys the location and the coordinates of the enclosing box accordingly
%
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
%
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
       this.r_min = pos(1:2);
       this.r_max = pos(1:2)+pos(3:4);
else
      [this.r_min,this.r_max]=find_min_max(this,this.handles,'ignore_previous_min_max');
end


