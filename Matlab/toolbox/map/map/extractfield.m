function A = extractfield(S, name)
%EXTRACTFIELD Extract the field values from a structure.
%
%   A = EXTRACTFIELD(S, NAME) returns the field values specified by the
%   fieldname NAME into the 1-by-N output array A. N is the total number of
%   elements in the field NAME of structure S, ie N = numel([S(:).(name)]).
%   NAME is a case sensitve string defining the field name of the structure
%   S. A will be a cell array if any field values in the fieldname contain
%   a string or if the field values are not uniform in type; otherwise A
%   will be the same type as the field values. The shape of the input field
%   is not preserved in A.
%   
%   Examples
%   -------
%       % Plot the X, Y coordinates of the road's shape
%       roads = shaperead('concord_roads.shp');
%       plot(extractfield(roads,'X'),extractfield(roads,'Y'));
%
%       % Extract the names of the roads
%       roads = shaperead('concord_roads.shp');
%       names = extractfield(roads,'STREETNAME');
%
%       % Extract a mix-type field into a cell array
%       S(1).Type = 0;
%       S(2).Type = logical(0);
%       mixedType = extractfield(S,'Type');
%
%   See also STRUCT, SHAPEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:57:23 $

checknargin(2,2,nargin,mfilename);

% Verify the input structure
if ~isstruct(S)
   eid = sprintf('%s:%s:invalidType', getcomp, mfilename);
   error(eid, '%s', 'Input argument ''S'' must be a struct.');
end

% Verify the input string 
if ~ischar(name)
   eid = sprintf('%s:%s:invalidType', getcomp, mfilename);
   error(eid, '%s', 'Input argument ''NAME'' must be a string.');
end

if isfield(S,name)

   % Determine if need to return a cell array
   if cellType(S,name)
      % The elements in the field are strings or mixed type
      A = {S(:).(name)};
      return;
   end

   try 
      % The field is numeric.
      % This will error if the fieldname's shape is neither row vector 
      %  nor uniform. 
      A = [S(:).(name)];
      % Do not preserve the shape
      if size(A,1) ~= 1
         A = reshape(A, [1 numel(A)]);
      end
   catch
      % The elements in the field are mixed size
      % Reshape into a row vector and append
      A = reshape(S(1).(name),[ 1 numel(S(1).(name)) ]);
      for i=2:length(S)
         values = reshape(S(i).(name),[ 1 numel(S(i).(name)) ]);
         A = [A values];
      end
   end

else
   eid = sprintf('%s:%s:invalidFieldname', getcomp, mfilename);
   error(eid, 'Fieldname ''%s'' does not exist.', name);
end

%----------------------------------------------------------------
function returnCell = cellType(S, name)
%CELLTYPE Return true if field values of NAME are mixed type,  or
% non-numeric.

% Determine if the field is non-numeric or mixed type
classType = class(S(1).(name));
for i=1:length(S)
   if issparse(S(i).(name))
      eid = sprintf('%s:%s:expectedNonSparse', getcomp, mfilename);
      %msg = sprintf('%s%s%s','Function ',upper(mfilename), ...
      %              ' expected a nonsparse storage class.'); 
      error(eid, '%s','Sparse storage class is not supported.');
   end
   if ~isnumeric(S(i).(name)) || ...
      ~isequal(class(S(i).(name)), classType)
      returnCell = true;
      return;
   end
end
returnCell = false;
