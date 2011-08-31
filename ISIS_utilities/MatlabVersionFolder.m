function [folderName,versionDLLextention,dirname]=MatlabVersionFolder(varargin)
% The function provides the name of the sub-folder "folderName"
% located under the OS specific folder "dirname"
% This name corresponds to the unique matlab  version, and takes the form:
% _RXXXX[a,b], where XXXX is the Matlabs year of the issue and a or b --
% letter of the version
%
% The function aslo keeps track of the unique folders, where the DLL-s and
% mex files necessary for calling Matlab version should be placed.
% It returns the name of this folder and OS specific extention
% for mex-files
%
% To work with particulr version of Matlab a mex file (DLL or dynamic
% library under Linux) have to be linked with correspondent Matlab
% libraries.
% These libraries are usualy valid for number of specific Matlab
% subversions. To allow any supported Matlab version working with
% precompiled mex files, we placed the mex-files compiled for different
% versions in difrent filders. To deal with these folders we have adopted
% the following structure to keep folders specific for OS  and Matlab Version:
%
% _MATLAB_OS_NAME_1->
%                ->_MATLAB_Subversion_Name1
%                ->_MATLAB_Subversion_Name2
%                ->_MATLAB_Subversion_Name3
% _MATLAB_OS_NAME_2->
%                ->_MATLAB_Subversion_Name1
%                ->_MATLAB_Subversion_Name2
%
% etc. where Matlab OS name has the form ['_',computer] and computer --
% internal Matlab function
%
%
%
% Libisis:
% $Revision$ ($Date$)
%
% Construct the name of the folder, which corresponds to current Matlab
% version
version_string = version();
version_folder=regexp(version_string ,'(\w*','match');
folderName=version_folder{1};
folderName(1)='_';

% get the OS folder name.
if(nargin==0)
    dirname = ['_',computer];
else
    dirname = varargin{1};
end
version_number = matlab_version_num();
%version_number = sscanf(version_string(1:3),'%f');
if(version_number<7.04) % should be oldest supported here (7.3?)
    warning(['This version of mex-files has not been tasted with Matlab version %s \n',...
             'Trying to use the files tested with Matlab 7.4 (2007a) but they may not work'],...
            version_string);
    folderName='_R2007a';
end
if(version_number>7.12) % should be recent supported here
    warning(['This subversion of mex-files has not been tasted with Matlab version %s \n',...
             'Trying to use the files tested with Matlab 7.12 (2011a) but they may not work'],...
            version_string);
    folderName='_R2009a';
end

try
    versionDLLextention    = mexext;
catch
    versionDLLextention    = 'dll';
end

%% 32 bit windows; the following dependensis have been identified;
% if(strcmp(dirname,'_PCWIN'))
%     if(strcmp('_R2007b',folderName)) % version for Matlab 2007b is the same as 2007a, so separate folder is not present.
%         folderName='_R2007a';
%         return
%     end
%     if(strcmp('_R2008b',folderName))% version for Matlab 2008b is the same as 2008a, so separate folder is not present.
%         folderName='_R2008a';
%         return
%     end
%     if(strcmp('_R2009b',folderName))
%         folderName='_R2009a';
%         return
%     end
%% 32 and 64 bit windows; the following changes and dependensies have been identified;
if(strncmpi(dirname,'_PCWIN',6))
%
    if(strcmp('_R2007b',folderName)||strcmp('_R2007a',folderName))
        folderName='_R2007a';
        return
    end
    folderName='_R2009a';
elseif(strcmp(dirname,'_GLNX86'))
%%     
      folderName='_R2009a';   % only this one has been tested at the moment
%%       
elseif(strcmpi(dirname,'_GLNXA64'))
   
        if(strcmp('_R2007b',folderName)||strcmp('_R2007a',folderName))
            folderName='_R2007a';
            return
        else
            folderName='_R2009a';
        end
%%
else
%% probably it is another OS which is not currently supported by this script    
    folderName = '';

%     if(strcmp(computer,'MACI'))
%     end
%     if(strcmp(computer,'SOL64'))
%     end
%     if(strcmp(computer,'MACI64'))
%     end
end
