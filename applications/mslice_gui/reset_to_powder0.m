function reset_to_powder0
% function resets all folders to the state was when the mslice was initially installed;
%
%  $Revision: 159 $   ($Date: 2011-02-25 13:46:33 +0000 (Fri, 25 Feb 2011) $)
%
msp_dir  = get(mslice_config,'SampleDir');
msp_file = 'crystal_psd.msp';

set(mslice_config,'MspDir',msp_dir);
set(mslice_config,'MspFile',msp_file);

MspFile=fullfile(msp_dir,msp_file);
ms_load_msp(MspFile)