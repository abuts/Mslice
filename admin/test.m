datadir='T:\matlab\mslice\ver2007a\mslice\mslice\HET\';
spefile=[datadir,'spe250.spe'];
phxfile=[datadir,'pix_981.phx'];

mslice_start

mslice_load_data (spefile, phxfile, 250, 1, 'loadsa counts', 'blobby')

mslice_sample([5.354,13.153,5.401],[90,90,90],[1,0,0],[0,1,0],98.5)

mslice_calc_proj([1,0,0],[0,0,1],[0,0,0,1],'H','L','En')


% 3D volume
% -----------
w3=slice_3d(fromwindow,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,5,190]);

mslice_3d ([-1.5,0.05,0],[-0.8,0.025,0.8],[100,5,200]);


% 2D slices
% ------------
mslice_2d ([-1.5,0.05,0],[-0.1,0.1],[100,5,200]);

mslice_2d ([-1.5,0.05,0],[-0.1,0.1],[100,0,200]);   % makes energy bins coincident with intrinsic bins


wref=mslice_2d([-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'file','c:\temp\aaa.slc','plot',2,'range',[0,0.5]);

[w2,w2full]=slice_2d(fromwindow,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,190]);


% Example of 1D cut
% -------------------
mslice_1d([-1.2,-1],[-0.2,0.2],[50,5,170],'range',[0,3])

w1=mslice_1d('file','c:\temp\greedy.cut','noplot');

% Store cut
w1=mslice_1d('store','noplot');


% Example of 1D cut and fit two Gaussians
w1=slice_1d(fromwindow,[-1.1,-0.9],[-0.6,0.03,0.6],[150,200]);

[wfit,ff]=multifit(w1,@mgauss_bkgd,[0.2,-0.2,0.03,0.2,0.2,0.03,0.2,0],'list',2);


