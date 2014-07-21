function [slice_d,slice_full]=slice_2d (data, varargin)
% Make a slice from single crystal, PSD mode. 
% Must have previously done a 'calculate projections', and obtain data with fromwindow.
%
%   >> data = fromwindow;
%   >> wout = slice_2d (data, u1, u2, u3)
%
%   Determines which is the perpendicular axis as being the instance of u1,
%  u2 or u3 that has only two elements
%   e.g.  >> make_slice([0.5,0.03,1.5],[-0.1,0.1],[-0.5,2,95]);
%  has the second projection axis as the plane perpendicular
%
% Optional additional arguments:
% ------------------------------
%   >> wout = slice_2d (..., 'file')              % prompt for a file name to write results
%   >> wout = slice_2d (..., 'file', filename)    % write results to named file
%   >> mslice_1d (..., 'type', cut_type)    % slice type:
%               'slc'       Full pixel info. with labels (DEFAULT)
%               'xye'       x-y-z-e data
%
%   >> wout = slice_2d (..., 'noplot')            % turn off plotting (DEFAULT)
%
%   >> wout = slice_2d (..., 'plot')              % plot, without smoothing
%   >> wout = slice_2d (..., 'plot', nsmooth)     % plot, with smoothing
% 
%   >> wout = slice_2d (..., 'surf')              % surface plot, with current smoothing
%   >> wout = slice_2d (..., 'surf', nsmooth)     % surface plot, changing smoothing to current value
%
%   >> wout = slice_2d (..., 'range', [i_min,i_max])  % intensity range for plot
%
% Examples:
%   >> wout = slice_2d (data,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,190])
%   >> wout = slice_2d (data,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'file','c:\temp\aaa.slc')   % save to file, no plotting
%   >> wout = slice_2d (data,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'surf')    % surface plot
%   >> wout = slice_2d (data,[-1.5,0.05,0],[-0.8,0.03,0.8],[150,190],'file','c:\temp\aaa.slc','plot',2,'range',[0,0.5]);

% T.G.Perring   Feb 2009
% Currently works only for single crystal PSD mode


% Parse the input arguments
[p,ux,uy,uz,file,filename,type,plotcmd,nsmooth,range,lims]= slice_2d_parse(data,varargin{:});
if isempty(p)
    error ('Must give binning and integration ranges')
end
if isempty(nsmooth), nsmooth=0; end     % no smoothing if nsmooth not given

% Create slice, writing to file if required, but no plotting yet.
if file
    if isempty(filename)
        filename = ms_putfile_full(['*.',type]);
        if isempty(filename)
            error('No output file name given')
        end
    end
    if strcmp(type,'slc')
        [slice_d_tmp,slice_full_tmp]=slice_spe_full(data,p,uz(1),uz(2),ux(1),ux(3),ux(2),uy(1),uy(3),uy(2),'','','','noplot',filename);
    else
        [slice_d_tmp,slice_full_tmp]=slice_spe_full(data,p,uz(1),uz(2),ux(1),ux(3),ux(2),uy(1),uy(3),uy(2),'','','','noplot','');
        slice_d_tmp_smooth=smooth_slice(slice_d_tmp,nsmooth);
        save_slice_xye(slice_d_tmp_smooth,filename)
    end
else
    [slice_d_tmp,slice_full_tmp]=slice_spe_full(data,p,uz(1),uz(2),ux(1),ux(3),ux(2),uy(1),uy(3),uy(2),'','','','noplot','');
end

% Now do plotting
if range
    i_min=lims(1); i_max=lims(2);
else
    i_min=''; i_max='';     % plot command will autoscale
end

if strcmp(plotcmd,'plot')
    plot_slice(smooth_slice(slice_d_tmp,nsmooth),i_min,i_max,'flat');
elseif strcmp(plotcmd,'surf')
    surf_slice(smooth_slice(slice_d_tmp,nsmooth),i_min,i_max,'flat');
end

% Output, if requested
if nargout>0
    slice_d=slice_d_tmp;
end
if nargout>1
    slice_full=slice_full_tmp;
end
