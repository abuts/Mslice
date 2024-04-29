function this=make_visible(this)
%
%   $Rev: 345 $ ($Date: 2017-09-27 15:50:53 +0100 (Wed, 27 Sep 2017) $)
%
for i=1:numel(this.handles)
    set(this.handles{i},'Visible','on');
end



