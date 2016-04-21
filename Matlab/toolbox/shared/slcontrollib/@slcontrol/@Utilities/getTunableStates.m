function TunableStates = getTunableStates(this, model)
% GETTUNABLESTATES Get list of all state names in the MODEL.  The names in the
% list will be unique.
%
% Will convert the SimMechanics ground block names in sizes vector to the
% correct block names.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:13 $

% State vector names from sizes call
[sys, x0, x0_str, ts, x0_ts] = feval(model, [], [], [], 'sizes');
domain = cell( size(x0_str) );
domain(:) = {''};

% SimMechanics suffix for ground blocks in sizes vector.
str = '/_mech_engine/Block#1';

% Find the Ground blocks
blks   = unique(x0_str);
match  = regexp( blks, str, 'once');
GroundBlks = blks( ~cellfun('isempty', match) );

% Replace Ground block names with SimMechanics block names
for ct1 = 1:length(GroundBlks)
  block   = GroundBlks{ct1};
  Manager = mech_stateVectorMgr( regexprep(block, str, '') );
  
  % State size check (Reported by sizes vector vs. state manager)
  idxs = find( strcmp( x0_str, block ) );
  if ( length(idxs) ~= length(Manager.X) )
    error('Wrong number of states in sizes vector for the state %s.\n', block);
  end
  
  Names  = cell(length(idxs),1);
  Domain = cell(length(idxs),1);
  count = 1;
  for ct2 = 1:length(Manager.BlockStates)
    BlockState = Manager.BlockStates(ct2);
    
    % Find states with "partial" state name matching
    PartialStateName = [ BlockState.BlockName, ':', BlockState.Primitive ];
    len = length( find( strncmp( PartialStateName, Manager.StateNames, ...
                                 length(PartialStateName) ) ) );
    
    % Block name and domain repeated LEN times.
    Names(count:count+len-1)  = {BlockState.BlockName};
    Domain(count:count+len-1) = {get_param(BlockState.BlockName, 'PhysicalDomain')};
    count = count + len;
  end
  
  x0_str(idxs) = Names;
  domain(idxs) = Domain;
end

% Create return structure
TunableStates = struct('Block', x0_str, 'Domain', domain);

% Make unique at the end, since sizes call may report the same state name for
% different SimMechanics blocks.
[dummy, idxs] = unique( {TunableStates.Block} );
TunableStates = TunableStates(idxs)';
