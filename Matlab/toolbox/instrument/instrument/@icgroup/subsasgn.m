function Obj = subsasgn(Obj, Struct, Value)
%SUBSASGN Subscripted assignment into device group objects.
%
%   SUBSASGN Subscripted assignment into device group objects. 
%
%   OBJ(I) = B assigns the values of B into the elements of OBJ specifed by
%   the subscript vector I. B must have the same number of elements as I
%   or be a scalar.
% 
%   OBJ(I).PROPERTY = B assigns the value B to the property, PROPERTY, of
%   device group object OBJ.
%
%   Supported syntax for device group objects:
%
%   Dot Notation:                  Equivalent Set Notation:
%   =============                  ========================
%   obj.Name='sydney';             set(obj, 'Name', 'sydney');
%   obj(1).Name='sydney';          set(obj(1), 'Name', 'sydney');
%   obj(1:4).Name='sydney';        set(obj(1:4), 'Name', 'sydney');
%   obj(1)=obj(2);               
%   obj(2)=[];
%
%   See also ICGROUP/SET, ICGROUP/PROPINFO, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:21 $

% Error checking when input argument, Obj, is empty.
if isempty(Obj)
   % Ex. s(1) = serial('COM1');
   if isequal(Struct.type, '()') && isequal(Struct.subs{1}, 1:length(Value))
      Obj = Value;
      return;
   elseif length(Value) ~= length(Struct.subs{1})
      % Ex. s(1:2) = serial('COM1');
      error('icgroup:subsasgn:index_assign_element_count_mismatch', ...
           ['In an assignment A(I)=B, the number of elements in B and I must be the same.']);
   elseif Struct.subs{1}(1) <= 0
      error('icgroup:subsasgn:badsubscript', 'Subscript indices must either be real positive integers or logicals.')
   else
      % Ex. s(2) = serial('COM1'); where s is originally empty.
      error('icgroup:subsasgn:badsubscript', 'Gaps are not allowed in device group object array indexing.');
   end
end

% Initialize variables.
oldObj = Obj;
prop1  = '';
index1 = {};

% Define possible error messages
error1   = 'Inconsistently placed ''()'' in subscript expression.';
error2   = 'Cell contents reference from a non-cell array object.';
error3   = 'Inconsistently placed ''.'' in subscript expression.';
errorId  = 'icgroup:subsasgn:invalidSubscriptExpression';
error4   = 'In an assignment A(I)=B, the number of elements in B and I must be the same.';
errorId4 = 'icgroup:subsasgn:index_assign_element_count_mismatch';

% Types of indexing allowed.
% g(1)
% g(1).UserData
% g(1).UserData(1,:)
% g.UserData
% g.UserData(1,:)
% d(1).Input
% d(1).Input(1).Name
% d(1).Input(1).Name(1:3)
% d.Input(1).Name
% d.Input(1).Name(1:3)

% Initialize variables for finding the object and property.
remainingStruct = [];
foundProperty   = false;
needToContinue  = true;
errflag         = false;
i               = 0;

% Want to loop until there is an object and a property. There may be
% more structure elemenets - for indexing into the property, e.g. 
% g(1).UserData(1,:) = [1 2 3];
while (needToContinue == true)
    % If there was an error and need to continue checking the 
    % subsasgn structure, throw the error message.
    if (errflag)
        rethrow(lasterror);
    end
    
    % Increment the counter.
    i = i+1;
    
    switch Struct(i).type
    case '.'
        % e.g. d.Input;
        prop1           = Struct(i).subs;
        foundProperty   = true;
        remainingStruct = Struct(i+1:end);
    case '()'
        index1 = Struct(i).subs;
        index1 = localConvertIndices(Obj, index1);
        [Obj, errflag] = localIndexOf(Obj, index1);
        % Don't throw error here, in case the expression is
        % x = [obj obj]; x(3) = obj; If the expression is not
        % valid, e.g. x(4).UserData, the error will be thrown
        % the next time through the while loop.
    case '{}'
        error(errorId, error2);
    otherwise
        error(errorId, ['Unknown type: ' Struct(i).type,'.']);
    end
    
    % Determine if the loop needs to continue.
    if i == length(Struct)
        needToContinue = false;
    elseif (foundProperty == true) 
        needToContinue = false;
    end
end

% Set the specified value.
if ~isempty(prop1)
   % Ex. obj.Tag = 'agilent'
   % Ex. obj(2).Tag = 'agilent'
   
   % Set the property.
   try 
      if isempty(remainingStruct) 
         set(Obj, prop1, Value);
      else
         tempObj   = get(Obj, prop1);
         tempValue = subsasgn(tempObj, remainingStruct, Value);
         set(Obj, prop1, tempValue);
      end
     
      % Reset the object so that it's value isn't corrupted.
      Obj = oldObj;
   catch
      localCheckError;
      rethrow(lasterror);
   end
else
   % Reset the object. 
   Obj = oldObj; 
    
   % Ex. obj(2) = obj(1);
   if ~(isa(Value, 'icgroup') || isempty(Value))
      error('icgroup:subsasgn:invalidConcat', 'Only objects of the same type may be concatenated.');
   end
   
   % Ex. s(1) = [] and s is 1-by-1.
   if ((length(Obj) == 1) && isempty(Value))
       error('icgroup:subsasgn:invalidAssignment', 'Use CLEAR to remove the object from the workspace.');
   end
   
   % Error if index is a non-number.
   for i=1:length(index1)
       if ~isnumeric(index1{i}) && (~(ischar(index1{i}) && (strcmp(index1{i}, ':'))))
           error('icgroup:subsasgn:badsubscript', ['Unable to find subsindex function for class ' class(index1{i}) '.']);
       end
   end

   % Error if a gap will be placed in array or if the value being assigned has an
   % incorrect size.
   for i = 1:length(index1)
       % If index is specified as ':', then the length of the value
       % must be either one or the length of size.
       if strcmp(index1{i}, ':')
           if i < 3 
               if length(Value) == 1 || isempty(Value)
                   % If the length is one or is empty, do nothing.
               elseif ~(length(Value) == size(Obj, 1) || length(Value) == size(Obj, 2))
                   % If the length is greater than one, it must equal the
                   % length of the dimension.
                   error(errorId4, error4);
               end
           end
       elseif ~isempty(index1{i}) && max(index1{i}) > size(Obj, i)
           % Determine if any of the indices specified exceeds the length
           % of the object array. 
           currentIndex = index1{i};
           temp  = currentIndex(find(currentIndex>length(Obj)));           
           
           % Don't allow gaps into array.
           if ~isempty(temp)
               % Ex. x = [g g g];
               %     x([3 5]) = [g1 g1];
               temp2 = min(temp):max(temp);
               if ~isequal(temp, temp2) 
                   error('icgroup:subsasgn:badsubscript', 'Gaps are not allowed in device group object array indexing.');
               end
           end
           
           % Verify that the index doesn't add a gap.
           if min(temp) > length(Obj)+1
               % Ex. x = [g g g];
               %     x([5 6]) = [g1 g1];
               error('icgroup:subsasgn:badsubscript', 'Gaps are not allowed in device group object array indexing.');
           end
           
           % If the length of the object being assigned is not one, it must
           % match the length of the index array.
           if ~isempty(Value) && length(Value) > 1 
               if length(currentIndex) ~= length(Value)
                   error(errorId4, error4);
               end
           end
       end
   end
   
   % Assign the value.
   [Obj, errflag] = localReplaceElement(Obj, index1, Value);
   if errflag
      localCheckError;
      rethrow(lasterror);
   end	
end

% *************************************************************************
function index = localConvertIndices(obj, index)

% Initialize values.
errflag = false;

% Index1 will be entire object if not specified.
if isempty(index)
   index = 1:length(obj);
end

% Convert index1 to a cell if necessary.
if ~iscell(index)
   index = {index};
end

% If indexing with logicals, extract out the correct values.
if islogical(index{1})
    % Determine which elements to extract from obj.
    indices = find(index{1} == true);

    % If there are no true elements within the length of obj, return.
    if isempty(indices)
        index = {};
        return;
    end
    
    % Construct new array of doubles.
    index = {indices};
end

% *********************************************************************
% Replace the specified element.
function [obj, errflag] = localReplaceElement(obj, index, Value)

% Initialize variables.
errflag = 0;

try
   % Get the current state of the object.
   jobject = igetfield(obj, 'jobject');
   type    = igetfield(obj, 'type');
   
   % Ensure that the arrays are cell arrays.
   if ~iscell(type)
      type = {type};
   end
   
   % Replace the specified index with Value.
   if isempty(Value)
      jobject(index{:})      = [];
      type(index{:})         = [];
   elseif length(Value) == 1
       jobject(index{:})     = igetfield(Value, 'jobject');
 	   type(index{:})        = {igetfield(Value, 'type')};
   else
       % Ex. y(:) = x(2:-1:1); where y and x are 1-by-2 instrument arrays.
       jobject(index{:})     = igetfield(Value, 'jobject');
  	   type(index{:})        = igetfield(Value, 'type');
   end
   
   if length(type) == 1 && iscell(type)
       type = type{:};
   end
   
   if length(type) ~= numel(type)
       error('icgroup:subsasgn:nonMatrixConcat', 'Only a row or column vector of device group objects can be created.')
   end

   % Assign the new state back to the original object.
   obj = isetfield(obj, 'jobject', jobject);
   obj = isetfield(obj, 'type', type);
catch
   errflag = 1;
   return
end

% *********************************************************************
% Index into an instrument array.
function [result, errflag] = localIndexOf(obj, index1)

% Initialize variables.
errflag = 0;

try
   % Get the field information of the entire object.
   jobj = igetfield(obj, 'jobject');
   type = igetfield(obj, 'type');
   
   % Create result with only the indexed elements.
   result = obj;
   result = isetfield(result, 'jobject', jobj(index1{:}));
   result = isetfield(result, 'type', type(index1{:}));
catch
   lasterr('Index exceeds matrix dimensions.', 'icgroup:subsasgn:badsubscript');
   errflag = 1;
   return;
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
