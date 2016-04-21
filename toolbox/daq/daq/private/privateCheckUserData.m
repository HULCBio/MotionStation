function out = privateCheckUserData(engine, recreate)
%PRIVATECHECKUSERDATA Determine if UserData is equal.
%
%    OUT = PRIVATECHECKUSERDATA(ENGINE, RECREATE) compares the
%    UserData properties of the object which already exists in 
%    the data acquisition engine, ENGINE and the object that is
%    being loaded, RECREATE.  If the two object's have identical
%    UserData properties, OUT = 0.  If the two object's have
%    different UserData properties, OUT = 1.
%

%    PRIVATECHECKUSERDATA is a helper function for 
%    private\privateExistParent which is a helper function for 
%    loadobj.
%
%    MP 9-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:42:15 $


% Initialize variables.
out = 0;

% Call the appropriate subfunction if the input arguments are data acquisition
% objects, cell arrays or structures otherwise compare the two input arguments.
if (isa(engine, 'daqdevice') || isa(engine, 'daqchild')) &&...
      (isa(recreate, 'daqdevice') || isa(recreate, 'daqchild'))
   out = localDAQCheck(engine,recreate);
elseif iscell(engine) && iscell(recreate)
   out = localCellCheck(engine,recreate);
elseif isstruct(engine) && isstruct(recreate)
   out = localStructCheck(engine,recreate);
else
   out = ~isequal(engine,recreate);
end

if out ~= 0
   return;
end

% *********************************************************************
% Compares when they are both data acquisition objects.
function out = localDAQCheck(engine,recreate)

% Initialize variables.
out = 0;

% If the data acquisition objects are valid, get their property values
% and compare.
if isvalid(engine) && isvalid(recreate)
   engine_prop = get(engine);
   recreate_prop = get(recreate);
   if ~isequal(engine_prop, recreate_prop)
      out = 1;  
      return;
   end
else
   if ~isvalid(engine)
      out = 2;
      return;
   end
end

% *********************************************************************
% Compares when they are both cell arrays.
function out = localCellCheck(engine,recreate)

% Initialize variables.
out = 0;

% Determine if the cell array sizes are the same.
if ~isequal(size(engine), size(recreate))
   out = 1;
   return;
end

% Compare each cell array element.  If the cell array element is a cell array,
% structure or data acquisition object call the appropriate subfunction 
% otherwise compare the two cell array elements.  
for i = 1:size(engine,1)
   for j = 1:size(engine,2)
      if (isa(engine{i,j}, 'daqdevice') || isa(engine{i,j}, 'daqchild')) &&...
            (isa(recreate{i,j}, 'daqdevice') || isa(recreate{i,j}, 'daqchild'))
         out = localDAQCheck(engine{i,j},recreate{i,j});
      elseif iscell(engine{i,j}) && iscell(recreate{i,j})
         out = localCellCheck(engine{i,j},recreate{i,j});
      elseif isstruct(engine{i,j}) && isstruct(recreate{i,j})
         out = localStructCheck(engine{i,j}, recreate{i,j});
      elseif ~isequal(engine{i,j}, recreate{i,j})
         out = 1;
         return;
      end
   end
end

% *********************************************************************
% Compares when they are both structures.
function out = localStructCheck(engine,recreate)

% Initialize variables.
out = 0;

% Get the fields of each structure.
fields_engine = fieldnames(engine);
fields_recreate = fieldnames(recreate);

% Compare the fields of each structure.
if ~isequal(fields_engine, fields_recreate)
   out = 1;
   return;
end

% Compare each structure field.  If the field value is a cell array, structure
% or data acquisition object, call the appropriate subfunction otherwise compare
% the two fields.

% Extract the field values.
value_engine = struct2cell(engine);
value_recreate = struct2cell(recreate);

for i = 1:length(fields_engine)
   value1 = value_engine{i};
   value2 = value_recreate{i};
   if (isa(value1, 'daqdevice') || isa(value1, 'daqchild')) &&...
         (isa(value2, 'daqdevice') || isa(value2, 'daqchild'))
      out = localDAQCheck(value1,value2);
   elseif iscell(value1) && iscell(value2)
      out = localCellCheck(value1,value2);
   elseif isstruct(value1) && isstruct(value2)
      out = localStructCheck(value1, value2);
   elseif ~isequal(value1,value2)
      out = 1;
      return;
   end
end



         
            