function this=make_visible(this)
%
%   $Rev: 201 $ ($Date: 2011-11-24 17:30:22 +0000 (Thu, 24 Nov 2011) $)
%
for i=1:numel(this.handles)
    set(this.handles{i},'Visible','on');
end



