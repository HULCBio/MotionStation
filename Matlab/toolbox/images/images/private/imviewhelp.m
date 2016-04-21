function ivcshelpviewer(topic, errorname)
% IVCSHELPVIEWER is a helper file for the Image Viewer (imview.m)
% IVCSHELPVIEWER Displays help for ImageViewer TOPIC. If the map file cannot
% be found, an error is displayed using ERRORNAME

%   Copyright 2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

try
    helpview([docroot '/toolbox/images/images.map'],topic);
catch
    if ~isstudent
      message = sprintf('Unable to display help for %s\n', ...
                        errorname);
      errordlg(message)
    else
      errordlg({'Image Viewer Help is not available in the Student Version.',...
                'See the Image Processing Toolbox documentation at:',...
                'www.mathworks.com'});
    end
    
end
