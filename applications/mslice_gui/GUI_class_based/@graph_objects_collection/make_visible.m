function this=make_visible(this)
%
%   $Rev$ ($Date$)
%
for i=1:numel(this.handles)
    set(this.handles{i},'Visible','on');
end



