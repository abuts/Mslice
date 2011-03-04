function output_args = ms_selectPhxFromNxSpe( )
% function controls the state of the PhxFromNxSpe checkbox
% and store its state for future usage

warning('mslice::get_phx from nxspe: This option has not been implemented yet as nxspe phx is valid for 1:1 masks only');

h_cw     =findobj('Tag','ms_ControlWindow');        
h_checkbox=findobj(h_cw,'Tag','ms_usePhxFromNXSPE');
Value=get(h_checkbox,'Value');
set(h_checkbox,'Value',false);

end

