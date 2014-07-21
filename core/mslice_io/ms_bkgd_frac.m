function wback = ms_bkgd_frac (w,frac,zero_opt)
% Using the output of mslice_3d or slice_3d, with energy as one of the axes,
% construct an mgenie spectrum with energy as the x-axis, and for which the
% intensity in any one bin corresponds to the average in the lowest fraction
% of the pixels defined by frac.
% Can also take the data from the result of fromwindow
%
%   >> w = mslice_3d    % for example
% OR
%   >> w = fromwindow
%
%   >> wback = ms_bkgd_frac (w, frac)
%   >> wback = ms_bkgd_frac (w, frac, 'zero')   % include zeros in average
%
% Ignores bins which contain NaNs (as bad) and zeros (will drag down the background
% if bins rather small. Usually will have chosen large enough bins)

% Get option
if nargin==3 && isequal(zero_opt,'zero')
    keep_zeros=true;
else
    keep_zeros=false;
end

% Check that the input has the correct structure
ndim = mslice_cut_dimension(w);
if ~isempty(ndim) && ndim==3
    e_ax=[];
    for i=1:3
        if isempty(findstr(w.axis_label(i,:),'Å^{-1}'))
            e_ax=i;
            break
        end
    end
    if isempty(e_ax)
        error('None of the projection axes is energy')
    end

    % Get energy bin centres and permute signal to have energy as outer axis
    if e_ax==1
        en=w.vx;
        signal=permute(w.intensity,[2,3,1]);
        err=permute(w.error_int,[2,3,1]);
    elseif e_ax==2
        en=w.vy;
        signal=permute(w.intensity,[3,1,2]);
        err=permute(w.error_int,[3,1,2]);
    elseif e_ax==3
        en=w.vz;
        signal=w.intensity;
        err=w.error_int;
    end
    en=0.5*(en(1:end-1)+en(2:end));
    np=size(signal);
    signal=reshape(signal,prod(np(1:end-1)),np(end));   % Make signal a 2D array
    err=reshape(err,prod(np(1:end-1)),np(end));   % Make error a 2D array

elseif isempty(ndim) && isfield(w,'S') && isfield(w,'ERR') && isfield(w,'en') && size(w.S,numel(size(w.S)))==numel(w.en)    % will be result of fromwindow
    en=w.en;
    np=size(w.S);
    signal=reshape(w.S,prod(np(1:end-1)),np(end));   % Make signal a 2D array
    err=reshape(w.ERR,prod(np(1:end-1)),np(end));   % Make error a 2D array
    
else
    error('Data source must be 3D mslice cut')
end


% Average over lower fraction frac of the pixels for each energy bin
ne=numel(en);
yback=zeros(1,ne);
eback=zeros(1,ne);
nzero=zeros(1,ne);
nnotfinite=zeros(1,ne);
ns=zeros(1,ne);
nsum=zeros(1,ne);
nmax=numel(signal(:,1));
for i=1:ne
    s=signal(:,i); e=err(:,i);
    if keep_zeros
        keep=isfinite(s); % ignore NaNs
    else
        nzero(i)=length(find(s<=0));
        nnotfinite(i)=length(find(~isfinite(s)));
        keep=isfinite(s) & s>0; % ignore zeros and NaNs
    end
    s=s(keep); e=e(keep);
    [s,ix]=sort(s); e=e(ix);
    ns(i)=length(s);
    if ns(i)>0
        nsum(i)=min(ceil(max(0,min(frac,1))*ns(i)),ns(i));
        yback(i)=sum(s(1:nsum(i)))/nsum(i);
        eback(i)=sqrt(sum(e(1:nsum(i)).^2))/nsum(i);
    else
        yback(i)=NaN;
        eback(i)=NaN;
    end
end

% disp('% zeros     % contribute')
% disp('--------------------------')
% [nzero'*(100/nmax),nsum'.*(100./ns(i))];
% [en',nzero',nnotfinite',ns',nsum']

% Make a structure that mslice recognises as a 1D cut
%  [previously an mgenie spectrum:
%   wback=spectrum(en,yback,eback,'Energy cut','Energy transfer (meV)','Intensity','meV',0);]
wback.x=en;
wback.y=yback;
wback.e=eback;
wback.title='Energy cut';
wback.x_label='Energy transfer (meV)';
wback.y_label='Intensity';
