function [argname, argval] = vrpreparesetargs(num, args, argdesc)
%VRPREPARESETARGS Pre-process arguments for SET.
%   VRPREPARESETARGS pre-processes arguments for SET and similar functions,
%   returning cell arrays of property names and property vaues.
%
%   Not to be called directly.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2003/04/12 23:21:22 $ $Author: batserve $


argname = {};
argval = cell(num, 0);

% loop through all property/value pairs
while ~isempty(args)
  
  % property name is a string - take the value as it is
  if ischar(args{1})
    if length(args)<2
      error('VR:invalidinarg', 'There must be a %s value for each %s name.', argdesc, argdesc);
    end
    newname = args(1);
    newval = args(2);
    args = args(3:end);

  % property name is a cell array of strings - check size, then take the value
  elseif iscellstr(args{1})
    if (length(args) < 2) || (numel(args{1}) ~= size(args{2},2))
      error('VR:invalidinarg', 'There must be a %s value for each %s name.', argdesc, argdesc);
    end
    newname = args{1};
    newval = args{2};
    args = args(3:end);

  % property is a structure - filed names are property names, field values are property values
  elseif isstruct(args{1})
    newname = fieldnames(args{1})';
    newval = struct2cell(args{1})';
    args = args(2:end);

  % everything else is an error
  else
    error('VR:invalidinarg', '%s name must be a string or a cell array of strings.', [upper(argdesc(1)) argdesc(2:end)] );
  end

  % add property name, scalar-expand property value across worlds if needed
  argname = [argname newname];
  if size(newval, 1) == num
    argval = [argval newval];
  elseif size(newval, 1) == 1
    argval = [argval newval(ones(1, num), :)];
  else
    error('VR:invalidinarg', 'Cell array of values must have 1 or %d rows.', num);
  end

end
