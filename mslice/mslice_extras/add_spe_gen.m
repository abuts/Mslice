function add_spe_gen(weight,spedir,spefiles,spefileout)
% Add together spe files with arbitrary weight
%   >> data=add_spe(weight,spedir,spefiles,spefileout)
%
%   weight      Multiplicative factors for the spe files
%   spedir      Directory containing spe files
%   spefiles    Cell array of character strings {'','',} with names of .spe files to be added
%   spefileout  Name of file with combined spe files to be saved in directory spedir
%
% Does not normalise data by wieghts; can be used to take differences, for example.
%
% The algorithm is:
%   spe_out = w(1)*spe(1) + w(2)*spe(2) + ...           ; only detectors that appear in all files retained
%
% Compare with add_spe:
%   spe_out = (w(1)*spe(1) + w(2)*spe(2) + ...)/sum(w)  ; detectors retained if signal in any file

% T.G.Perring 26-Nov-2007. Based on function add_spe by Radu Coldea 02-Oct-1999 


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
      error(['Could not load .spe file ' spedir spefiles{i}]);
      return;
   end
   index=~(data.S(:,1)<=nulldata);	% (ndet,1) is 1 where pixel is data and 0 where detector has 'nulldata' in current data set

   if ~exist('cumm_index','var'),	% if it is the first file to be loaded, initaialize cumm_index, cumm_S, ERR2 ...
      det_theta=data.det_theta;
      en=data.en;
      cumm_index=index; 	% cummulative index 1 (data) 0 (nulldata) for all files loaded so far  	
      cumm_S=weight(i)*(index*ones(size(data.en))).*data.S;	% summulative S summation, has 0 where cumm_index is 0
      cumm_ERR2=(weight(i)^2)*((data.ERR).^2).*(index*ones(size(data.en)));	% cummulative ERR2 summation, has 0 where cumm_index is 0
   else
      if any(size(data.S)~=size(cumm_S)),
         error('Current data set not consistent with number of detectors or energy bins of previous data sets. Return.');
         return;
      end
      if any(det_theta~=data.det_theta),
         error('Warning: phi grid not equivalent');
      end
      if any(en~=data.en),
         error('Warning: energy grid not equivalent');
      end
      cumm_index=cumm_index&index;	% only keep detectors which appear in all spe files
      cumm_S=cumm_S+weight(i)*(index*ones(size(data.en))).*data.S;	% (ndet,ne)
	  cumm_ERR2=cumm_ERR2+(weight(i).^2)*((data.ERR).^2).*(index*ones(size(data.en)));	% (ndet,ne)
   end
   disp(sprintf('masked detectors %d and weight %15.5g',sum(not(index(:))),weight(i)));
   disp(sprintf('overall masked detectors %d',sum(not(cumm_index(:)))));      
end

% === put 'nulldata' with 0 error bar in final data set for pixel positions which were 'nulldata' in ALL data sets
data.S=nulldata*ones(size(data.S));
data.S(cumm_index,:)=cumm_S(cumm_index,:);
data.ERR=zeros(size(data.ERR));
data.ERR(cumm_index,:)=sqrt(cumm_ERR2(cumm_index,:));
   
% === save result in filename fileout
data.filename=spefileout;
save_spe(data,spefileout);
disp(sprintf('masked detectors %d and weight %15g',sum(not(index(:))),sum(weight(:))));
