function gahelpviewer(topic, errorname)
% GAHELPVIEWER is a helper file for the Genetic Algorithm and Direct Search Toolbox. 
% GAHELPVIEWER Displays help for a Genetic Algorithm and Direct Search TOPIC. 
% If the map file cannot be found, an error is displayed using ERRORNAME

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1 $

import java.io.*;

error = false;
mapfilename = [docroot '/toolbox/gads/gads.map'];
f = File(mapfilename);
if f.exists
    try
        helpview(mapfilename, topic);
    catch
        error = true;
    end
else
    error = true;
end
if error
	message = sprintf('Unable to display help for %s\n', ...
							errorname);
	errordlg(message);
end
