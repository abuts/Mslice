function vol_d=mslice_3d(varargin)
% Make a 3D slice from single crystal, PSD mode. 
% Must have previously done a 'calculate projections' in mslice.
%
% Valid input arguments are:
%   >> mslice_3d (du)                       % Slice with current values in GUI for the 2D plot,
%                                           % giving bin size for the 'perp' axis
%   >> mslice_3d (u1, u2, u3)               % Slice, changing values
%
%   e.g.  >> mslice_3d (2.5);
%         >> mslice_3d ([0.5,0.03,1.5],[-0.1,0.02,0.1],[-0.5,2.5,95]);
%
% Optional additional arguments:
% ------------------------------
%   >> mslice_3d (..., 'file')              % prompt for a file name to write results
%   >> mslice_3d (..., 'file', filename)    % write results to named file
%
%   >> mslice_3d (..., 'noplot')            % turn off plotting
%
%   >> mslice_3d (..., 'plot')              % plot, with current smoothing (DEFAULT)
%   >> mslice_3d (..., 'plot', nsmooth)     % plot, changing smoothing to current value
%
%   >> mslice_3d (..., 'range', [i_min,i_max])  % intensity range for plot

% T.G.Perring   Feb 2009
% Currently works only for single crystal PSD mode

% Check mslice running
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig)
   error('Control Window not active. Return.');
end

% Check that the mode is correct
if ~(strcmpi(ms_getvalue('analysis_mode'),'single crystal') && strcmpi(ms_getvalue('det_type'),'PSD'))
    error('Function currently only works for single crystal, PSD mode')
end

% Check data is loaded
data=get(fig,'UserData');
if isempty(data)
    error('Load data first, then do slice')
end
if isstruct(data)
    if ~isfield(data,'S')||isempty(data.S),
        error('Loaded data set has no intensity matrix. Load data again.')
    elseif ~isfield(data,'v')||isempty(data.v),
        error('Calculate projections first and then take slices.')
    end
else
    error('Loaded data set has wrong type. Load data again')
end


% Parse the input arguments
[p,ux,uy,uz,file,filename,plotcmd,nsmooth,range,lims]= slice_3d_parse(data,varargin{:});
if ~isempty(nsmooth)
    disp('Smoothing not yet implemented for 3D volume data - smoothing ignored')
end

% Set values in GUI if just given the z axis binning, and one of the axes is energy with zero bin size
if isempty(p)
    dz=uz;  % store with new name
    ux=zeros(1,3); uy=zeros(1,3); uz=zeros(1,3);
    ux(1)=ms_getvalue('slice_vx_min');
    ux(2)=ms_getvalue('slice_bin_vx');
    ux(3)=ms_getvalue('slice_vx_max');
    uy(1)=ms_getvalue('slice_vy_min');
    uy(2)=ms_getvalue('slice_bin_vy');
    uy(3)=ms_getvalue('slice_vy_max');
    uz(1)=ms_getvalue('slice_vz_min');
    uz(2)=dz;
    uz(3)=ms_getvalue('slice_vz_max');
    % If a plot axis is energy, treat gui values as in slice_2d_parse i.e. zero bin, or empty limits
    % If error trying to do so, then just use values in the gui.
    ien=find(data.u(:,4),1); if isempty(ien), ien=0; end    % index of energy axis (=0 if none are energy)
    iperp=get(findobj(fig,'Tag','ms_slice_z'),'Value');     % index of viewing axis that is perpendicular to slice
    if ien~=0     % one of the axes is energy
        ix=ien-iperp; if ix<=0, ix=ix+3; end     % this happens to give ix=1 if ux is energy, ix=2 if uy is energy, ix=3 if integration is energy
        if ix==1
            [ux,mess,unchanged]=make_ebins(ux,data.en);
            if isempty(mess) && ~unchanged
                ms_setvalue('slice_bin_vx',ux(2))
                ms_setvalue('slice_vx_min',ux(1))
                ms_setvalue('slice_vx_max',ux(3))
            end
        elseif ix==2
            [uy,mess,unchanged]=make_ebins(uy,data.en);
            if isempty(mess) && ~unchanged
                ms_setvalue('slice_bin_vy',uy(2))
                ms_setvalue('slice_vy_min',uy(1))
                ms_setvalue('slice_vy_max',uy(3))
            end
        elseif ix==3
            [uz,mess,unchanged]=make_ebins(uz,data.en);
            if isempty(mess) && ~unchanged
                ms_setvalue('slice_vz_min',uz(1))
                ms_setvalue('slice_vz_max',uz(3))
            end
        end
    end
    % permute ux,uy,uz to match viewing axes
    u=[ux;uy;uz];
    ind=[1,2,3,1,2];
    ux=u(ind(4-iperp),:);
    uy=u(ind(5-iperp),:);
    uz=u(ind(6-iperp),:);
end

% Create volume dataset
vol_d_tmp=vol_spe(data,ux,uy,uz);

% Write to file if required
if file
    error('Writing volume dataset to file not yet implemented')
end

% Now do plotting
if ~strcmp(plotcmd,'noplot')    % default is to plot
    if range
        plot_vol (vol_d_tmp, lims(1), lims(2))
    else
        plot_vol (vol_d_tmp)
    end
end

% Output, if requested
if nargout>0
    vol_d=vol_d_tmp;
end
