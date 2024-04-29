function this=add_collection(this,collection,direction,gap)
% Method adds existing collection to the current one
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%


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
 
noh = numel(this.handles);
nah = numel(collection.handles);
 %
mask(1)=abs(direction(1));
mask(2)=abs(direction(2));         
 %         
 
r0 = this.r_min;      
for i=1:2
 if mask(i)~=0
    if direction(i)>=0
       r0(i)          = this.r_max(i)+gap(i);
       this.r_max(i)  = r0(i)+get_size(collection,i);
    else
       r0(i)          = this.r_min(i)-get_size(collection,i)-gap(i);
       this.r_min(i)  = r0(i);
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
 
