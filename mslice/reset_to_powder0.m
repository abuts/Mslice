function reset_to_powder0
% function resets all folders to the state was when the mslice was initially installed;
%
%  $Revision$   ($Date$)
%
msp_dir  = get(mslice_config,'SampleDir');
msp_file = 'crystal_psd.msp';

set(mslice_config,'MspDir',msp_dir);
set(mslice_config,'MspFile',msp_file);

MspFile=fullfile(msp_dir,msp_file);
ms_load_msp(MspFile)