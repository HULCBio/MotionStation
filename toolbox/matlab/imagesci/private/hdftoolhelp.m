function hdftoolhelp(location)
% HDFTOOLHELP Displays help for HDFTOOL

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

try
  switch location
   case 'overview'
    helpview([docroot '/mapfiles/matlab_env.map'],'hdfviewer_help');
   case 'import'
    helpview([docroot '/mapfiles/matlab_env.map'],'hdfviewer_ov');
  end
catch

end
