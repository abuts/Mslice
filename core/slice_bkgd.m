function [p_back_full, p_sub, p_back, p_mask, qvals, wlo, whi] = ...
    slice_bkgd(p, q_buffer, e_buffer, dq, de, handle_lower, plo, handle_upper, phi)

%  Calculates a smoothed background for a slice from outside a region defined
% by two functions giving upper and lower bounds of the signal as a function
% of x-value. The background is interpolated into the signal region
%  Usually used on slices where the x-axis is momentum, y-axis is energy, but
% there is no intrinsic restriction.
%
%   >> [p_back_full, p_sub, p_back, p_mask, q, wlo, whi] = slice_bkgd
%          (p, q_buffer, e_buffer, dq, de, handle_lower, plo, handle_upper, phi)
%
% Input: (all are required)
%   p               Slice data structure produced by slice_spe (mslice function)
%   q_buffer        Extra momentum window to select background region far from signal
%   e_buffer        Extra energy window to select background region far from signal
%   dq              Momentum scale for smoothing the background in Q
%   de              Energy scale for smoothing the background in energy
%   handle_lower    Function handle for lower bound
%   plo             Array of parameters needed by lower bound function
%   handle_upper    Function handle for upper bound
%   phi             Array of parameters needed by upper bound function
%
% Output:
%   p_back_full     Background defined across the whole slice i.e. no NaN in the array
%                  Suitable for subtracting from an spe file using sub_slice.
%   p_sub           Subtracted data set
%   p_back          The background that was subtracted, defined only in region of data
%   p_mask          Mask array = 1 where signal was removed from calculation of background
%   qvals           Array of q values at which lower, upper bounds are output
%   wlo             Lower bound
%   whi             Upper bound
%
% Note: the structures of p_back_full, p_sun, p_back, p_mask are all the same as the
%       result of performing a slice using ms_slice or slice_spe
%
% EXAMPLE:
%   >> p = ms_slice     % calculates slice from data in mslice window
%                       % Alternatively, use slice_spe
%   >> [bkgd,ps,pb,pm,q,wlo,whi]=slice_bkgd(p,0.05,30,0.2,10,...
%                                   @muller_lower,240,@muller_upper,240);
%   >> plot_slice(pm)   % plot mask array
%   >> hold on;
%   >> plot(q,wlo)      % overplot lower bound
%   >> plot(q,whi)      % overplot upper bound
%   >> data = fromwindow;           % get data from window
%   >> data = sub_slice(data, bkgd) % subtract the background from the spe file
%   >> towindow(data);              % put back into mslice


% Original version: Bella Lake, for Muller ansatz only
% 25th August 2006, Andrew Walters: Rewritten, code made tidier
% 3 September 2006, Toby Perring: Generalised to take arbitrary lower and upper bounds
%                                 Added some other improvements

% create internal variables for intensity Int, wavevector q, energy en.
int_withNaNs=p.intensity; q_hist=p.vx; e_hist=p.vy;

% create a 2d mask which has NaNs at the same positions as there are NaNs
% in int_withNaNs, and zeros everywhere else
NaN_mask = isnan(int_withNaNs).*int_withNaNs;

% create internal version of the 2d intensity array, as the 2d intensity 
% array created by slice_spe has NaN at the end of every row 
% and column. These are removed
int=p.intensity(1:end-1,1:end-1);

% The wavevector and energy arrays are bin boundaries for the intensity 
% plot, so the conversion from histogram to point data is done
q = (q_hist(1:end-1) + q_hist(2:end))/2;
e = (e_hist(1:end-1) + e_hist(2:end))/2;

% create 2d arrays of the same size as int
[q_2d,e_2d]=meshgrid(q,e);

% create 2d arrays of the bin boundaries
[q_2d_bounds,e_2d_bounds]=meshgrid(q_hist,e_hist);

% Calculate lower and upper boundaries for the spinon continuum at the
% bin centres and bin edges. Allow also for 'buffer zones' in q and e
w_qmid= handle_lower(q_2d(1,:),plo);
w_qlo = handle_lower(q_2d_bounds(1,1:end-1)-abs(q_buffer),plo);
w_qhi = handle_lower(q_2d_bounds(1,2:end)+abs(q_buffer),plo);
wlo = min(min(w_qmid,w_qlo),w_qhi) - e_buffer;

w_qmid= handle_upper(q_2d(1,:),phi);
w_qlo = handle_upper(q_2d_bounds(1,1:end-1)-abs(q_buffer),phi);
w_qhi = handle_upper(q_2d_bounds(1,2:end)+abs(q_buffer),phi);
whi = max(max(w_qmid,w_qlo),w_qhi) + e_buffer;

% Create 2D arrays of wlo, whi for comparisons later on:
lower_bound = repmat(wlo,length(e),1);
upper_bound = repmat(whi,length(e),1);

% Create output arrays of lower, upper bounds for reference
qvals = linspace(q_hist(1),q_hist(end),501);
wlo = handle_lower(qvals,plo);
whi = handle_upper(qvals,phi);

% find elements in the 2d energy array (created by meshgrid) which are
% inside the spinon continuum. If an element is inside the spinon 
% continuum, the corresponding element is 1 in a logical array 
% identical in size to int, otherwise it is zero.
is_continuum = (e_2d>lower_bound)&(e_2d<upper_bound);

% make exact 2d reverse logical matrix of is_continuum
not_continuum=abs(is_continuum-1);

% create intensity array which has zeros within the spinon continuum
% and zeros where there were NaNs in int
int_zero_mag = int; int_zero_mag(is_continuum|isnan(int)) = 0;

% create intensity array which has NaNs within the spinon continuum
int_nan_mag = int;  int_nan_mag(is_continuum) = NaN;

% initialise the smoothed version of the background back_smoothed
back_smoothed = int_zero_mag;

for n=1:length(e)
    for m=1:length(q)
        % if the values of n and m correspond to a value of q,w which is
        % outside the spinon continuum:
        if ~isnan(int_nan_mag(n,m))
            % calculate gaussian weighting of all points relative to the 
            % point labelled by indices n and m. Every other point is
            % weighted using the difference in both wavevector and energy 
            % between the other point and the current point.
            smooth_func=exp( -2.7726*((q_2d-q_2d(n,m)).^2/dq^2 + (e_2d-e_2d(n,m)).^2/de^2 ));
            % all elements of smooth_func which correspond to q,w inside 
            % the spinon continuum or correspond to NaN intensities in 
            % int are set to zero
            smooth_func(is_continuum|isnan(int)) = 0;
            % The weighting is normalised
            smooth_func=smooth_func/sum(sum(smooth_func));
            % Place newly smoothed value of intensity into the current
            % element of back_smoothed
            back_smoothed(n,m)=sum(sum(smooth_func.*int_zero_mag));     
        end
    end
    % find indices of non-zero elements in the nth row of the 2d 
    % intensity array which has had the spinon continuum removed and the 
    % background smoothed
    is_nonzero=find(back_smoothed(n,:));
    % create wavevector array q_short with the elements removed which 
    % correspond to zero intensity in back_smoothed(n,:)
    q_short=q(is_nonzero); 
    % create new version of back_smoothed(n,:) with all zero elements removed
    back_smoothed_short=back_smoothed(n,is_nonzero);
    
    % If there is only one element which is nonzero in back_smoothed(n,:), 
    % the final intensity array is simply filled with back_smoothed(:,n)
    if length(is_nonzero)<2
        back_interp=back_smoothed(n,:);
    else
        % If there is at least two non-zero elements in back_smoothed(:,n) 
        % then interpolate over the 1d array
        back_interp(n,:)=interp1(q_short,back_smoothed_short,q,'linear','extrap');
    end
end

%------------------------------------------------------------------------
% Output slice which contains 1s and 0s, which shows where the background
% has been cut out 
%------------------------------------------------------------------------
p_mask=p;

% add extra row and column to back_mask, so that it has the same size as
% the inputted 2d intensity array
back_mask = [is_continuum; ones(1,length(q))];
back_mask = [back_mask, ones(length(e)+1,1)];

% create double precision array which contains 1s at all the points that
% were not considered to be background (and has NaN at the end of every 
% row and every column
p_mask.intensity=(back_mask|isnan(int_withNaNs))*1 +NaN_mask;

%------------------------------------------------------------------------
% Output slice which is just the background which is to be subtracted from
% the real signal
% Also output slice which has interpolated background over the whole slice
%------------------------------------------------------------------------
p_back=p;
p_back_full=p;

% add extra row and column to back, so that it has the same size as
% the inputted 2d intensity array
back = [back_interp; nan(1,length(q))];
back = [back, nan(length(e)+1,1)];

% create array which has NaN at the end of every row and every column
p_back.intensity = back+NaN_mask;
p_back_full.intensity = back;

%------------------------------------------------------------------------
% Newly calculated background is subtracted from the detected signal
%------------------------------------------------------------------------
p_sub = p;

int_back_sub = int-back_interp; 

% add extra row and column to int_back_sub, so that it has the same size as
% the inputted 2d intensity array
int_back_sub = [int_back_sub; ones(1,length(q))];
int_back_sub = [int_back_sub, ones(length(e)+1,1)];

% create array which has NaN at the end of every row and every column
p_sub.intensity=int_back_sub+NaN_mask;