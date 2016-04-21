function privateShowHelp(topic,parent)
%PRIVATESHOWHELP Show help for softscope.
%
%  PRIVATESHOWHELP(TOPIC,PARENT) shows help for topic, TOPIC, in an html 
%  viewer. 
%
%  TOPIC
%    An arbitrary string that identifies a topic. helpview.m maps
%    the TOPIC id to the path of the HTML file that documents the topic.
%
%  PARENT
%    Handle to a parent window.  Used by the helpview.m
%    to determine the parent of the help dialog.  
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%
%   MP 1-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.4 $  $Date: 2004/01/16 19:58:46 $

import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.mwt.MWFrame;

tutorial = false;
if strcmp(topic, 'softscope_tut')
    tutorial = true;
    fileName = [docroot '\toolbox\daq\daq.map'];
else
    fileName = [docroot '\toolbox\daq\csh\softscope_csh.map'];
end

% Error if the file could not be found and indicate how the documentation
% location can be set.
if exist(fileName) == 0
    MWAlert.errorAlert(MWFrame, 'Error Showing Help',...
        ['Invalid documentation location. To set the documentation location',...
          sprintf('\n') 'go to the MATLAB Command Window and select File and then select ',...
          sprintf('\n') 'Preferences. In the Preferences dialog, select Help and enter the',...
          sprintf('\n') 'Documentation Location.'], MWAlert.BUTTONS_OK); 
end


% Show the help.
if tutorial == false
    if ( isempty(parent) )
        helpview(fileName, topic, 'CSHelpWindow');
    else
        helpview(fileName, topic, 'CSHelpWindow', parent);
    end
else
    helpview(fileName, topic);
end
