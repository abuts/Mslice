function reset_to_powder0
% function resets all folders to the state was when the mslice was initially installed;
%
%  $Revision: 130 $   ($Date: 2010-08-10 12:41:14 +0100 (Tue, 10 Aug 2010) $)
%
msp_dir  = get(mslice_config,'SampleDir');
msp_file = 'crystal_psd.msp';

set(mslice_config,'MspDir',msp_dir);
set(mslice_config,'MspFile',msp_file);

MspFile=fullfile(msp_dir,msp_file);
ms_load_msp(MspFile)