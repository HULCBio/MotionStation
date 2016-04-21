function nodes = load(this, filename)
% LOAD Loads project objects from the file FILENAME.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:05:31 $

nodes = [];

if isempty(filename)
  % Open 'Load...' dialog
  nodes = loadfrom(this);
else
  % Load data
  ws = warning('off'); lw = lastwarn;
  try
    s = load(filename, '-mat');
  catch
    [dummy, errmsg] = strtok( lasterr, sprintf('\n') );
    uiwait( errordlg( errmsg, 'Load Error', 'modal' ) )
    return
  end
  warning(ws); lastwarn(lw)
  
  % Add the project
  if isfield(s, 'Projects') && isa(s.Projects, 'explorer.projectnode')
    nodes = s.Projects;
  else
    errmsg = sprintf('MAT file %s does not contain valid projects.', filename);
    uiwait( errordlg(errmsg, 'Load Error', 'modal') )
    return
  end
end
