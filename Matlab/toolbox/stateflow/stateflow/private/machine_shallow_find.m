function result = machine_shallow_find(machine,type)
%machine_shallow_find(object, 'type')
% Backwards-compatibility of findShallow on machine objects 
%  Forces R14 and upwards to behave the same as R13 and R12.1+
%
%	Tom Walsh
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 00:58:42 $

  
result = [];

if (isequal('Chart', type))
  % If we're looking for charts:
  % OLD LOCATION: All charts were directly below their machines
  % NEW LOCATION: Charts may be anywhere under their models
  % Solution:
  %   Since a machine lives *directly* under the model,
  %   and Charts can be anyplace under that, we can do a
  %   full search one level up from the machine
  result = find(up(machine), '-isa', 'Stateflow.Chart');
elseif  (isequal('Data', type) | isequal('Event', type) | isequal('Target', type))
  % We are looking for Events, Data or Targets
  % OLD LOCATION: directly below the machine
  % NEW LOCATION: directly below the model
  % Solution:
  %   Find is already redirected to the model.
  %   So, just substitute the right args, and call find on the machine
  fullname = ['Stateflow.' type];
  result = find(machine, '-isa', fullname, '-depth', 1);
end

% ELSE:
% No other types could be found using findShallow in R12.1+, so
% we return nothing in these cases to keep the same behavior

