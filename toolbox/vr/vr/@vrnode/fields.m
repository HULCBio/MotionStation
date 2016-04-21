function x = fields(node)
%FIELDS List VRML fields belonging to this node.
%   FIELDS(NODE) displays a list of VRML fields of a node associated
%   with the given VRNODE object.
%
%   X = FIELDS(NODE) returns the same information in a structure.
%   The resulting structure contains a field for every VRML field
%   with the following subfields:
%      'Type'    - name of the type of the field, e.g. 'SFString'
%      'Access'  - name of the access type of the field, e.g. 'eventIn'
%      'Sync'    - field synchronization status, 'on' or 'off'
%
%   See also VRNODE/GET, VRNODE/SET, VRNODE/SYNC.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.9.4.4 $ $Date: 2004/03/15 22:35:26 $ $Author: batserve $



% check for invalid nodes
if ~all(isvalid(node(:)))
  error('VR:invalidnode', 'Invalid node.');
end

if nargout>0

  % FIELDS is just an alias for GET(W, 'FieldStruct')
  x = get(node, 'FieldStruct');

else

  % empty input array: nothing to print
  if isempty(node)
    warning('VR:emptyoutput', 'Nothing to print.');
    return;
  end

  % print fields header
  fprintf('\n\t\t%-20s %-15s %-15s %-10s\n', 'Field', 'Access', 'Type', 'Sync');
  fprintf('\t\t-----------------------------------------------------------\n');

  % loop through nodes
  for i=1:numel(node)

    % print node name only for multiple nodes
    if numel(node)>1
      disp(node(i));
    end

    % print node fields
    fstruct = get(node(i), 'FieldStruct');
    fnames = fieldnames(fstruct);
    for i=1:numel(fnames)
      fprintf('\t\t%-20s %-15s %-15s %-10s\n', ...
        fnames{i}, fstruct.(fnames{i}).Access, fstruct.(fnames{i}).Type, fstruct.(fnames{i}).Sync);
    end
    fprintf('\n');

  end

end
