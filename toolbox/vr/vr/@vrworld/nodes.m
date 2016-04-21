function x = nodes(w, fullswitch)
%NODES List VRML nodes in a virtual world.
%   NODES(W) lists all named nodes contained in the world
%   referenced by a VRWORLD handle W.
%
%   NODES(W, '-full') lists both nodes and their fields.
%
%   X = NODES(W) returns a cell array with names of all
%   named nodes contained in the world. The result is the same
%   as from X = GET(W, 'Nodes').

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.9.4.3 $ $Date: 2004/03/02 03:08:14 $ $Author: batserve $


% check arguments
if ~isa(w, 'vrworld')
  error('VR:invalidinarg', 'W must be of type VRWORLD.');
end

% check for invalid worlds
if ~all(isvalid(w(:)))
  error('VR:invalidworld', 'Invalid world.');
end

% look for commandline switches
fullswitch = nargin>1 && strcmpi(fullswitch,'-full');
if nargin>1 && ~fullswitch
  error('VR:invalidinarg', 'Unknown command switch.');
end

% output argument is given: work like GET(W, 'Nodes')
if nargout>0
  x = get(w, 'Nodes');

% no output, full listing: work like FIELDS(GET(W, 'Nodes'))
elseif fullswitch

  % listing of more than one world would be impractically long
  if numel(w)>1
    error('VR:invalidinarg', 'W must be a scalar when a full listing is requested.');
  end
  
  % empty array of worlds: nothing to print
  if numel(w)==0
    warning('VR:emptyoutput', 'Nothing to print.');
    return
  end

  fields(get(w, 'Nodes'));

% no output, brief listing: work like DISP(GET(W, 'Nodes'))
else

  % empty array of worlds: nothing to print
  if numel(w)==0
    warning('VR:emptyoutput', 'Nothing to print.');
    return
  end

  % vectorized operation
  if numel(w)>1
    for i=1:numel(w)
      fprintf('\n');
      disp(w(i));
      nodes(w(i));
    end
    return
  end

  % world has no visible nodes: nothing to print
  nodelist = get(w, 'Nodes');
  if isempty(nodelist)
    warning('VR:emptyoutput', 'Nothing to print.');
    return
  end
  
  disp(get(w, 'Nodes'));

end
