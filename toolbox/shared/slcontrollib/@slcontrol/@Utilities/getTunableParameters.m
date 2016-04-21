function TunablePars = getTunableParameters(this, model)
% GETTUNABLEPARAMETERS Get the list of tunable parameters in the model and
% the blocks that refer to them.
%
% Returns a struct array with fields Name, Type, and ReferencedBy.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:12 $

% Base workspace parameters
bwRefs = get_param(model, 'ReferencedWSVars');
nbwp   = length(bwRefs);
if nbwp > 0
  bwRefsNames = {bwRefs.Name};
  bwParams    = struct( 'Name', bwRefsNames, 'Type', [], ...
                        'ReferencedBy', {cell(0,1)} );
  % Get parameter type
  S = evalin('base', 'whos');
  [dummy, ia, ib] = intersect( {S.name}, bwRefsNames );
  for ct = 1:length(ia)
    bwParams(ib(ct)).Type = S(ia(ct)).class;
  end
else
  bwParams = struct( 'Name', cell(0,1), 'Type', [], ...
                     'ReferencedBy', {cell(0,1)} );
end

% Model workspace parameters
s = whos( get_param(model, 'ModelWorkspace') );
mwParams = struct( 'Name', {s.name}, 'Type', {s.class}, ...
                   'ReferencedBy', {cell(0,1)} );

% Full parameter list
TunablePars = [ bwParams , mwParams ];

% References (only for base workspace for now)
for ct = 1:nbwp
  % Referring blocks
  blks = handle( bwRefs(ct).ReferencedBy );
  
  % Construct reference display
  nb = length(blks);
  refs = cell(nb,1);
  for ctb = 1:nb
    refs{ctb} = blks(ctb).getFullName;
  end
  TunablePars(ct).ReferencedBy = regexprep(refs, '\n\r?', ' ');
end

% Sort by name
[dummy, idxs] = sort( {TunablePars.Name} );
TunablePars = TunablePars(idxs);
