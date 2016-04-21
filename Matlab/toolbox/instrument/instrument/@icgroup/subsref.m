function result = subsref(obj, Struct)
%SUBSREF Subscripted reference into device group objects.
%
%   SUBSREF Subscripted reference into device group objects.
%
%   OBJ(I) is an array formed from the elements of OBJ specifed by the
%   subscript vector I.  
%
%   OBJ.PROPERTY returns the property value of PROPERTY for device group 
%   object OBJ.
%
%   Supported syntax for device group objects:
%
%   Dot Notation:                  Equivalent Get Notation:
%   =============                  ========================
%   obj.Name                       get(obj,'Name')
%   obj(1).Name                    get(obj(1),'Name')
%   obj(1:4).Name                  get(obj(1:4), 'Name')
%   obj(1)                         
%
%   See also ICGROUP/GET, ICGROUP/PROPINFO, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:22 $


% Initialize variables.
prop1 = '';
index1 = {};

% Define possible error messages
error1 = 'Inconsistently placed ''()'' in subscript expression.';
error2 = 'Cell contents reference from a non-cell array object.';
error3 = 'Inconsistently placed ''.'' in subscript expression.';
errorId = 'icgroup:subsref:invalidSubscriptExpression';

% Parse the input.

% The first Struct can either be:
% obj(1); 
% obj.Status;
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
           error('icgroup:subsref:UndefinedFunction', ['Function ''subsindex'' is not defined for values of class ''' class(index1{i}) '''.']);
       end
   end
end

if any(cellfun('isempty', index1))
    for i = 1:length(index1)
        if ~isempty(index1{i}) && index1{i} > size(obj, i)
            error('icgroup:subsref:exceedsdims', 'Index exceeds matrix dimensions.');
        end
    end
    result = [];
    return;
elseif length(index1{1}) ~= (prod(size(index1{1})))
    error(errorId, 'Only a row or column vector of device group objects can be created.');
elseif length(index1) == 1 
    if strcmp(index1{:}, ':')
        isColon = true;
        index1 = {[1:length(obj)]};
    end
else
    for i=1:length(index1)
        if (strcmp(index1{i}, ':'))
            index1{i} = [1:size(obj,i)];
        end
    end
end

% Return the specified value.
if ~isempty(prop1)
   % Ex. obj.Status 
   % Ex. obj(2).Status
   
   % Extract the object.
   [indexObj, errflag] = localIndexOf(obj, index1, isColon);
   if errflag
      instrgate('privateFixError');
      rethrow(lasterror);
   end
   
   % Get the property value.
   try
      result = get(indexObj, prop1);
   catch
      instrgate('privateFixError');
      rethrow(lasterror);
   end
else
   % Ex. obj(2);
   
   % Extract the object.
   [result, errflag] = localIndexOf(obj, index1, isColon);   
   if errflag
      instrgate('privateFixError');
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
function [result, errflag] = localIndexOf(obj, index1, isColon)

% Initialize variables.
errflag = 0;

try
   % Get the field information of the entire object.
   jobj = igetfield(obj, 'jobject');
   type = igetfield(obj, 'type');
   
   if ~iscell(type)
       type = {type};
   end
   
   % Create the first object and then append the remaining objects.
   try
       t = type(index1{:});
   catch
       type = type';
       t    = type(index1{:});
   end
   if (length(t) == 1)    
       % This is needed so that the correct classname is assigned
       % to the object.
	   result = feval(t{1}, java(jobj(index1{:})));       
   else
       % The class will be instrument since there are more than 
       % one instrument objects.  
       result = obj;
   	   result = isetfield(result, 'jobject', jobj(index1{:}));
   	   result = isetfield(result, 'type', type(index1{:}));
   end
   
   if isColon && size(result,1) == 1
       result = result';
   end
catch
   result = [];
   errflag = 1;
   return;
end

