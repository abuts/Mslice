% --------------------------------------------------------------------
% Script file to exercise the single crystal scripting options
% --------------------------------------------------------------------

% Get locations of test data:
% ----------------------------------------
% root directory is assumed to be that in which this function resides
rootpath = fileparts(which('mslice_init'));

% Location of example spe and phx files:
data_dir=fullfile(rootpath,'mslice','het');


% Set values of arguments to pass to functions
% ------------------------------------------------
spefile=fullfile(data_dir,'spe250.spe');
phxfile=fullfile(data_dir,'pix_981.phx');

efix=250;   % incident energy
emode=1;    % direct geometry

intensity_label='S(Q,w)';
title_label='Test of scripting';

alatt=[5.354,13.153,5.401]; % lattice parameters
angdeg=[90,90,90];

uvec=[1,0,0];
vvec=[0,1,0];
psideg=98.5;


% Run mslice
% ----------------
% start mslice
mslice_start
% load data
mslice_load_data (spefile, phxfile, efix, emode, intensity_label, title_label)
% calculate projections
mslice_sample(alatt,angdeg,uvec,vvec,psideg)
mslice_calc_proj([0,0,1],[1,0,0],[0,0,0,1],'L','H','E')

% multiple by energy transfer raised to power of 3/2:
msfun_mult_eps(1.5)

% Perform 2D plot
mslice_2d([-0.1,0.1],[-1.4,0.055,0.3],[52.5,5,202.5],'range',[0,1500],'plot',2)
% Write to file:
mslice_2d('file','c:\temp\test_slice.slc')

% Perform 1D cut
mslice_1d([-0.6,0.03,0.6],[-1.1,-0.9],[150,200],'range',[0,1500])
% Write to file:
mslice_1d('file','c:\temp\test_cut.slc')
