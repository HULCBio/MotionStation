function result = subsref(obj, Struct)
%SUBSREF Subscripted reference into IVI Configuration Store objects.
%
%   SUBSREF Subscripted reference into IVI Configuration Store objects.
%
%   OBJ(I) is an array formed from the elements of OBJ specifed by the
%   subscript vector I.  
%
%   OBJ.PROPERTY returns the property value of PROPERTY for IVI
%   Configuration Store object OBJ.
%
%   Supported syntax for IVI Configuration Store objects:
%
%   Dot Notation:                  Equivalent Get Notation:
%   =============                  ========================
%   obj.Name                       get(obj, 'Name')
%   obj(1).Name                    get(obj(1), 'Name')
%   obj(1:4).Name                  get(obj(1:4), 'Name')
%   obj(1)                         
%
%   See also IVICONFIGURATIONSTORE/GET.
%

%   MP 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:24 $


% Initialize variables.
prop1 = '';
index1 = {};

% Define possible error messages
error1 = 'Inconsistently placed ''()'' in subscript expression.';
error2 = 'Cell contents reference from a non-cell array object.';
error3 = 'Inconsistently placed ''.'' in subscript expression.';
errorId = 'iviconfigurationstore:subsref:invalidSubscriptExpression';

% Parse the input.

% The first Struct can either be:
% obj(1); 
% obj.SampleRate;
switch Struct(1).type
case '.'
   prop1 = Struct(1).subs;
case '()'
   index1 = Struct(1).subs;
case '{}'
   error(errorId, error2);
otherwise
   error(errorId, ['Unknown type: ' Struct(1).type,'.']);
end

% Index1 will be entire object if not specified.
if isempty(index1)
   index1 = 1:length(obj);
end

% Convert index1 to a cell if necessary.
isColon = false;
if ~iscell(index1)
   index1 = {index1};
end

% If indexing with logicals, extract out the correct values.
if islogical(index1{1})
    % Determine which elements to extract from obj.
    indices = find(index1{1} == true);
    
    % If there are no true elements within the length of obj, return.
    if isempty(indices)
        result = [];
        return;
    end
    
    % Construct new array of doubles.
    index1 = {indices};
end

% Error if index is a non-number.
for i=1:length(index1)
   if ~isnumeric(index1{i}) && (~(ischar(index1{i}) && (strcmp(index1{i}, ':'))))
       if ischar(index1{i})
           index1{i} = double(index1{1});
       else
           error('iviconfigurationstore:subsref:UndefinedFunction', ['Function ''subsindex'' is not defined for values of class ''' class(index1{i}) '''.']);
       end
   end
end

if any(cellfun('isempty', index1))
    for i = 1:length(index1)
        if ~isempty(index1{i}) && index1{i} > size(obj, i)
            error('iviconfigurationstore:subsref:exceedsdims', 'Index exceeds matrix dimensions.');
        end
    end
    result = [];
    return;
elseif length(index1{1}) ~= (numel(index1{1}))
    error(errorId, 'Only a row or column vector of IVI Configuration Store objects can be created.');
elseif length(index1) == 1 
    if strcmp(index1{:}, ':')
        isColon = true;
        index1 = {1:length(obj)};
    end
else
    for i=1:length(index1)
        if (strcmp(index1{i}, ':'))
            index1{i} = 1:size(obj,i);
        end
    end
end

% Return the specified value.
if ~isempty(prop1)
   % Ex. obj.Name 
   % Ex. obj(2).Name
   
   % Extract the object.
   [indexObj, errflag] = localIndexOf(obj, index1);
   if errflag
      localCheckError;
      rethrow(lasterror);
   end
   
   % Get the property value.
   try
      result = get(indexObj, prop1);
   catch
      localCheckError;
      rethrow(lasterror);
   end
else
   % Ex. obj(2);
   
   % Extract the object.
   [result, errflag] = localIndexOf(obj, index1);   
   if errflag
      localCheckError;
      rethrow(lasterror);
   end
end

% Handle the next element of the subsref structure if it exists.
if length(Struct) > 1
    Struct(1) = [];
    try
        result = subsref(result, Struct);
    catch
        rethrow(lasterror);
    end
end

% *********************************************************************
% Index into an instrument array.
function [result, errflag] = localIndexOf(obj, index1)

% Initialize variables.
errflag = false;
try
    result = obj(index1{:});
catch
    result = [];
    errflag = true;
end

% *************************************************************************
% Remove any extra carriage returns.
function localCheckError

% Initialize variables.
[errmsg, id] = lasterr;

% Remove the trailing carriage returns.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg, id);
