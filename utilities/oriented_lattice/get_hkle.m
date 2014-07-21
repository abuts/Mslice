function [Qhkl,en] = get_hkle(data)
% Get h,k,l,energy for every pixel
%
% 	>> [Q,e] = get_hkle(data)
%
% Input:
% ------
% data      Data as obtained from >> data = fromwindow; after
%          performing 'load data' and 'calculate projections'
% Output:
% -------
% Qhkl      nx3 array of h,k,l
% en        nx1 array of energy transfer
%
%
% T.G.Perring, Sept 2006: edited from ms_simulate (R.Coldea)


%Q=spe2sqe(data);                % Get wavevector Q (ndet,ne,3) in spectrometer reference frame 	
%Q=sqe2samp(Q,data.psi_samp);	% Transform into sample reference frame
%Q=q2rlu(Q,data.ar,data.br,data.cr);
Q=q2rlu(data);

[ndet,ne]=size(Q(:,:,1));       % ndet = number of detector groups, ne=numberof energy bins
Qx=Q(:,:,1); % (ndet,ne)
Qy=Q(:,:,2);
Qz=Q(:,:,3);
Qhkl=[Qx(:) Qy(:) Qz(:)];
en=ones(ndet,1)*data.en;
en=reshape(en,prod(size(en)),1);