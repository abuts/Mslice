function output_args = ms_selectPhxFromNxSpe( )
% function controls the state of the PhxFromNxSpe checkbox
% and should be storing this for future usage
% As nxspe does not currently work properly in all situations, 
% a warning is issued when the option is enabled and the state of the
% checkbox is not saved 


h_cw     =findobj('Tag','ms_ControlWindow');        
h_checkbox=findobj(h_cw,'Tag','ms_usePhxFromNXSPE');
Value=get(h_checkbox,'Value');

if Value
warning('Mslice:gettingPhxFromNxspe','  Getting phx from nxspe currently works correctly for 1:1 maps and for equidistant rings only ');
end

% set(h_checkbox,'Value',false);

end

