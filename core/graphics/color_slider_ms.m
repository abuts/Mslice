function color_slider_ms(fig,cmd)

% function color_slider(fig,obj,index)
% fig = current figure
% cmd = 'slider' , 'min' , 'max'
% adjust colour table and slider limits

slider_min=findobj(fig,'Tag','color_slider_min');
slider_min_value=findobj(fig,'Tag','color_slider_min_value');
slider_max=findobj(fig,'Tag','color_slider_max');
slider_max_value=findobj(fig,'Tag','color_slider_max_value');

i_min=get(slider_min,'Value');
i_max=get(slider_max,'value');
if strcmp(cmd,'slider'),
    % === slider move, either top or bottom
elseif strcmp(cmd,'min'),
    % only change i_min if numeric value entered and would not make range=0
    try
        temp=str2double(get(slider_min_value,'String'));
        if isnan(temp) | temp==i_max, % do not change i_min if range becoms 0 or NaN
            i_min=get(slider_min,'value');
        else
            i_min=temp;
        end
    catch
    end
elseif strcmp(cmd,'max'),
    % only change i_max if numeric value entered and would not make range=0
    try
        temp=str2double(get(slider_max_value,'String'));
        if isnan(temp) || temp==i_min, % do not change i_max if range becoms 0
            i_max=get(slider_max,'value');
        else
            i_max=temp;
        end
    catch
    end
else
    disp('Unknown slider command. Return.');
    return;
end
temp=min(i_min,i_max);
i_max=max(i_min,i_max);
i_min=temp;

c_bar = findobj(fig,'Tag','Colorbar');
if verLessThan('matlab','8.4')
    is_linear= strcmp(get(c_bar,'YScale'),'linear');
else
    is_linear=true;
end

if is_linear
    caxis([i_min i_max]);
    range=abs(i_max-i_min);
    set(slider_min,'Min',i_min-range/2,'Max',i_max-range*0.1,'Value',i_min);
    set(slider_max,'Min',i_min+range*0.1,'Max',i_max+range/2,'Value',i_max);
    
    set(c_bar,'YLim',[i_min i_max]);
    set(get(c_bar,'Children'),'YData',[i_min i_max]);
    set(slider_min_value,'String',num2str(i_min));
    set(slider_max_value,'String',num2str(i_max));
end
