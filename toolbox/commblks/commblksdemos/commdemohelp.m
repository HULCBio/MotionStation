function [] = commdemohelp
% COMMDEMOHELP  Invoke Communications Blockset demo help.
%
%   COMMDEMOHELP finds the arguments for the HELPVIEW function
%   and invokes help for the current demo.
%
%   Typical usage:  
%      commdemohelp; % in a Model Info block in a demo

%   It assumes that the documentation source file contains a Type 19
%   marker whose text is the name of the system, except for slashes.
%
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:01:36 $

d = docroot;
if isempty(d)
   error(['Help system is unavailable.  Try using the ',...
          'Web-based documentation set at http://www.mathworks.com']);
else
   topic=gcs;
   topic(findstr(topic,'/'))=[]; % get rid of slashes in case of subsystems
   % Look in consolidated map file for the Communications Blockset doc set. 
   pathname1=fullfile(d,'toolbox','commblks','helptargets.map');
   helpview(pathname1,topic); 
end
return

% [EOF] commdemohelp.m
