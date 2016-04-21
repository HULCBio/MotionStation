function edit(w)
%EDIT Edit the virtual world.
%   EDIT(W) opens VRML file associated with virtual world referenced by
%   the VRWORLD handle W in a VRML editor. The editor to use is chosen
%   based on the 'Editor' preference.
%
%   See also VRGETPREF, VRSETPREF.

%   Copyright 1998-2001 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.15 $ $Date: 2002/02/12 09:09:08 $ $Author: batserve $

% check arguments
if length(w)>1
  error('VR:invalidinarg', 'Argument cannot be an array.');
end

% get world file name and commandline template
if ~isempty(w)
  wfile = get(w, 'FileName');
else
  wfile = '';
end
cmdline = vrgetpref('Editor');

% use internal editor if preference empty
if isempty(cmdline)
  if ~isempty(wfile)
    edit(wfile)
  else
    edit
  end;
  return;
end

% check if the default editor is installed, install it if it isn't
if ~vrinstall('-check', 'editor')
  vrinstall('-install', 'editor');
end

% form the command line
cmdline = [strrep(strrep(cmdline, '%matlabroot', matlabroot), '%file', wfile) ' &'];

% go!
if ispc
  dos(cmdline);
else
  unix(cmdline);
end  
