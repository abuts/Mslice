function data=add_spe(weight,spedir,spefiles,spefileout,scale)
% Adds normalised spe files together, normalising the final output
% 
%   >> add_spe(weight,spedir,spefiles,spefileout)
%   >> add_spe(weight,spedir,spefiles,spefileout,scale)
%
%   weight      Array of relative weights e.g. [1000,1500] (proton current in uAhrs);
%
%   spedir      Directory containing the spe files e.g. 'c:\temp\mt_data\spe\'
%
%   spefiles    Cell array of spe file names e.g. {'map01234.spe','map01299.spe'}
%
%   spefileout  Name of spe file to contain the overall sum e.g. 'map01234_99.spe'
%               Default: place in the directory spedir if a full path is not given
%
%   scale       [Optional] Overall scaling factor by which to multiply the resulting data file
%               Default: unity
%
% EXAMPLE:
%         % define relative or absolute weights of different spe files (these numbers can be uAhrs)
%         weights=[222.6 267.7 250.1 233.8 250.1];
% 
%         % give path and filenames of spe files to be added
%         spedir='m:\matlab\iris\ornl\';
%         files={'irs17866.spe','irs17867.spe','irs17868.spe',...
%                'irs17869.spe','irs17870.spe'}; 
% 
%         % give filename to save results 
%         fileout=[spedir 'irs17866sum.spe']; 
%         data=add_spe(weights,spedir,files,fileout);
%

% Radu Coldea 02-Oct-1999 
% Modified T.G.Perring to improve help and use default output directory as spedir

% === define value for nulldata
nulldata=-1e+30;

% === return if number of weights and spefiles are inconsistent
if length(weight)~=length(spefiles),
   disp(['Error: ' num2str(length(weight)) ' weights not consistent with ' num2str(length(spefiles)) ' spe files given.']);
   data=[];
   return;
end

% === read one file at a time
for i=1:length(weight),

   data=load_spe([spedir spefiles{i}]);
   if isempty(data),
      disp(['Could not load .spe file ' spedir spefiles{i}]);
      return;
   end
   index=~(data.S(:,1)<=nulldata);	% (ndet,1) is 1 where pixel is data and 0 where detector has 'nulldata' in current data set

   if ~exist('cumm_index','var'),	% if it is the first file to be loaded, initaialize cumm_index, cumm_S, ERR2 ...
      det_theta=data.det_theta;
      en=data.en;
      cumm_index=index; 	% cummulative index 1 (data) 0 (nulldata) for all files loaded so far  	
      cumm_weight=weight(i)*index;	% (ndet,1) contains cummulative weights of each detector, 0 if pixel is 'nulldata' in all sets loaded so far    
      cumm_S=weight(i)*(index*ones(size(data.en))).*data.S;	% summulative S summation, has 0 where cumm_index is 0
      cumm_ERR2=(weight(i)^2)*((data.ERR).^2).*(index*ones(size(data.en)));	% cummulative ERR2 summation, has 0 where cumm_index is 0
   else
      if any(size(data.S)~=size(cumm_S)),
         disp('Current data set not consistent with number of detectors or energy bins of previous data sets. Return.');
         return;
      end
%     Accept any values in the arrays for det_theta
%       if any(det_theta~=data.det_theta),
%          disp('Warning: phi grid not equivalent');
%       end
      if any(en~=data.en),
         disp('Warning: energy grid not equivalent');
      end
      cumm_index=cumm_index|index;	% one detector has data if it either has had data 
      	% in one of the previous data sets or has data in this current data set
      cumm_weight=cumm_weight+weight(i)*index;	% (ndet,1)
      cumm_S=cumm_S+weight(i)*(index*ones(size(data.en))).*data.S;	% (ndet,ne)
	   cumm_ERR2=cumm_ERR2+(weight(i).^2)*((data.ERR).^2).*(index*ones(size(data.en)));	% (ndet,ne)
   end
   disp(sprintf('masked detectors %d and weight %15.5g',sum(not(index(:))),weight(i)));
   disp(sprintf('overall masked detectors %d',sum(not(cumm_index(:)))));      
end

% === put 'nulldata' with 0 error bar in final data set for pixel positions which were 'nulldata' in ALL data sets
data.S=nulldata*ones(size(data.S));
data.S(cumm_index,:)=cumm_S(cumm_index,:)./(cumm_weight(cumm_index)*ones(size(data.en)));
data.ERR=zeros(size(data.ERR));
data.ERR(cumm_index,:)=sqrt(cumm_ERR2(cumm_index,:))./(cumm_weight(cumm_index)*ones(size(data.en)));

if exist('scale','var')&~isempty(scale)&isnumeric(scale),
   data.S=data.S*scale;
   data.ERR=data.ERR*scale;
end
   
% === save result in filename fileout
tmp=fileparts(spefileout);
if ~isempty(tmp)
    data.filename=spefileout;
else
    data.filename=fullfile(spedir,spefileout);
end
save_spe(data,spefileout);
disp(sprintf('masked detectors %d and weight %15g',sum(not(index(:))),sum(weight(:))));
