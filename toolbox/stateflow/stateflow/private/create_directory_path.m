function [fullDirName,success,errorMessage] = create_directory_path(varargin)

%   Vijay Raghavan
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.10.2.3 $ $Date: 2004/04/15 00:56:28 $

if isunix
	fileSepChar = '/';
else
	fileSepChar = '\';
end

if(nargin<2)
    success = 0;
    errorMessage = 'Internal error: Too few arguments to create_directory_path';
    fullDirName = '';
    return;
end
   
parentDirName = varargin{1};
childDirName = varargin{2};

if(parentDirName(end)==fileSepChar)
   parentDirName = parentDirName(1:end-1);
end

for i=3:nargin
   parentDirName = [parentDirName,fileSepChar];
   fullDirName = [parentDirName,childDirName];
   if(~exist(fullDirName,'dir'))
      [success, errorMessage] = sf_mk_dir(parentDirName,childDirName);
      if(~success) 
          return;
      end
      
   end
	childDirName = varargin{i};
	parentDirName = fullDirName;
end

fullDirName = [parentDirName,fileSepChar,childDirName];
success = 1;
errorMessage = '';
if(~exist(fullDirName,'dir'))
   [success, errorMessage] = sf_mk_dir(parentDirName,childDirName);
end
