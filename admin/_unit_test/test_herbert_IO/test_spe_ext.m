classdef test_spe_ext<TestCase
%   Detailed explanation goes here
    
    properties
    end
    
    methods
       function this=test_spe_ext(name)
            this = this@TestCase(name);
       end
       
       function test_simpleext_win(this)
           ext = spe_ext('-testwin');
           assertEqual([3,1],size(ext));
           assertTrue(all(ismember({'*.spe','*.spe_h5','*.nxspe'},ext)));
       end
       function test_simpleext_nix(this)
           ext = spe_ext('-testunix');
           assertEqual([6,1],size(ext));
           assertTrue(all(ismember({'*.spe','*.spe_h5','*.nxspe','*.SPE','*.SPE_H5','*.NXSPE'},ext)));
       end
       function test_fuleext_win(this)
           ext = spe_ext('-testwin','descr');
           assertEqual([4,2],size(ext));
           assertTrue(all(ismember({'*.spe','*.spe_h5','*.nxspe'},ext)));
       end
       function test_fulext_nix(this)
           ext = spe_ext('-testunix','descr');
           assertEqual([4,2],size(ext));
           assertTrue(all(ismember({'*.spe;*.SPE','*.spe_h5;*.SPE_H5','*.nxspe;*.NXSPE'},ext)));
       end

       
% 
    end
    
end
