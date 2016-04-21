function [] = cdmademohelp
% CDMADEMOHELP  Invoke CDMA Reference Blockset demo help.
%
%   CDMADEMOHELP finds the arguments for the HELPVIEW function
%   and invokes help for the current demo.
%
%   Typical usage:  
%      cdmademohelp; % in a Model Info block in a demo

%   It assumes that the documentation source file contains a Type 19
%   marker whose text is the name of the system, except for slashes.
%
% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 16:35:09 $

d = docroot;
if isempty(d)
   error(['Help system is unavailable.  Try using the ',...
          'Web-based Help Desk at http://www.mathworks.com']);
else
   pathname=fullfile(d,'mapfiles','cdma.map');
   topic=gcs;
   topic(findstr(topic,'/'))=[]; % get rid of slashes in case of subsystems
   helpview(pathname,topic);
end
return

% [EOF] cdmademohelp.m
