function det = get_hor_format(par_array,file_name)
% function transforms data obtained as par data array into Horace srtucture;
%
% Usage:
%>> det = get_hor_format(par_array,file_name)
% Input: 
% par_array -- 6xNd array of angular detector parameters where Nd is number
%              of detectors
% file_name -- the name of the file whrer these data were read from 
%Output: 
% det       -- the structure, with detector parameters information, which
%              used in Horace data format
%Parameters definitons:
% Detector's array has to have the following columns:
%  par(1,:)   -- sample-to-detector distance
%  par(2,:)   -- 2-theta (polar angle)
%  par(3,:)   -- azimutal angle
%  par(4,:)   -- detector width
%  par(5,:)   -- detector height
%  par(6,:)   -- detector ID (number) 
% 
% The array is projected to Horace structure with fields:
% det.x2   <-  par(1,:) 
% det.phi  <-  par(2,:)  
% det.azim <- -par(3,:)   % Note sign change to get correct convention
% det.width<-  par(4,:)  
% det.height<- par(5,:)  
% det.group <- par(6,:) 
% [filepath,filename]=fileparts(file_name);
% det.filename<- filename;
% det.filepath<- filepath;


if ~exist('file_name','var')
    file_name = '';
end
[path,name,ext]=fileparts(file_name);
det.filename   =[name,ext];
if isempty(path)
    path='.';
end
det.filepath = [path,filesep];
 
size_par  = size(par_array);
if(size_par(1)~=6)
	error('GET_HOR_FORMAT:invalid_file_format',' proper par array has to have 6 column but this one has %d',size_par(1));
end

det.group = par_array(6,:);        
	
det.x2    = par_array(1,:);
det.phi   = par_array(2,:);
det.azim  =-par_array(3,:); % Note sign change to get correct convention
det.width = par_array(4,:);
det.height= par_array(5,:);