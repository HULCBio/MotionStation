function bdclose(sys)
%BDCLOSE Close any or all Simulink system windows unconditionally.
%   BDCLOSE closes the current system window unconditionally and without
%   confirmation.  Any changes made to the system since it was last saved
%   are lost.
%
%   BDCLOSE('SYS') closes the specified system window.
%
%   BDCLOSE('all') closes all system windows.
%
%   Example:
%
%       bdclose('vdp')
%
%   closes the vdp system.
%
%   See also CLOSE_SYSTEM, OPEN_SYSTEM, NEW_SYSTEM, SAVE_SYSTEM.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.28.2.2 $


%
% no args, close the current system
%

if nargin == 0,
  sys = gcs;
  if ~isempty(sys),
    close_system(sys,0);
  end
  return;
elseif nargin > 1
  error('Only one argument expected');
end

allsys = {};
if ischar(sys)
  %
  % The input argument is a string. It is either the name of a
  % system or the specifier 'all'
  %
  if strcmpi(sys,'all')
    allsys = find_system('SearchDepth',0);
  else
    allsys = {sys};
  end
elseif iscell(sys)
  %
  % Check that the cell array is an array of strings
  %
  for i = 1:length(sys)
    thisys = sys{i};
    if ~ischar(thisys)
      error('Only system names may be specified within cell array arguments');
    end
  end
  allsys = sys;
elseif isa(sys,'double')
  if nnz(sys == 0)
    error('Invalid handle specified in array of handles');
  end
  allsys = sys;
else
  error('Invalid argument type');
end

if ~isempty(allsys)
  %
  % At this point, we want to stop any valid models which are
  % being closed form simuating
  %
  allmdls = [];
  try
    allmdls = find_system(allsys, 'SearchDepth', 0, 'Type', ...
			  'block_diagram');
  end
  
  if ~isempty(allmdls)
    %
    % Make sure that simulation is stopped for all block diagrams
    %
    allbds = find_system(allmdls, 'SearchDepth', 0, ...
			 'BlockDiagramType','model');
    vset_param(allbds, 'SimulationCommand','Stop');
    
  end
  
  try
    close_system(allsys,0);
  catch
    error('Invalid array of objects or handles specified')
  end
end
return;


%
%===============================================================================
% Function: vset_param
%===============================================================================
%
function vset_param(sys,p,v)
%VSET_PARAM Vectorized set_param.
%   VSET_PARAM is a vectorized version of SET_PARAM.  This is a temporary
%   workaround until SET_PARAM is vectorized.

for i=1:length(sys),
  if iscell(sys),
    slobj = sys{i};
  else
    slobj = sys(i);
  end

  set_param(slobj,p,v);
end















