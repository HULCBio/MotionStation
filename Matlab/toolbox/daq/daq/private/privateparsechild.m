function [prop1, index, errflag] = privateparsechild(obj,Struct)
%PRIVATEPARSECHILD Parse input for daqchild objects.
%
%    [PROP1, INDEX] = PRIVATEPARSECHILD(STRUCT) parses the input
%    structure, STRUCT, into property names (PROP1) and the INDEX.
%   
%    For example, obj(2).ChannelName would parse into
%    INDEX = 2, PROP1 = 'ChannelName'.
%

%    PRIVATEPARSECHILD is a helper function for @daqchild\subsref and
%    @daqchild\subsasgn.

%    MP 6-03-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:42:28 $

% Initialize variables
StructL = length(Struct);
index = 1;
prop1 = '';
errflag = 0;

% Define possible error messages
error1 = 'Cell contents reference from a non-cell array object.';
error2 = 'Inconsistently placed ''()'' in subscript expression.';

% Parse the input structure, Struct, into the prop1 and index  
% variables.  Subsref syntax: obj(index).prop1 and obj.prop1
switch Struct(1).type
case '.'
   % chan.SensorRange/obj.prop1
   prop1 = Struct(1).subs;   
case '()'
   % chan(1:3)/obj(index)
   index = Struct(1).subs;
   if length(index) == 1 && isempty(index{1})
      errflag = 2;
      return;
   end 
   if length(index) > 1
      [errflag, index] = localCheckIndex(obj, index);
      if errflag
         return;
      end
   end
   % If the first Struct type is (), obtain the property name
   % if it was given - (chan(1:3).SensorRange/obj(index).prop1).
   if StructL > 1
      switch Struct(2).type
      case '.'
         prop1 = Struct(2).subs;
      case '()'
         lasterr(error2);
         errflag = 1;
         return;
      case '{}'
         lasterr(error1);
         errflag = 1;
         return;
      otherwise
         lasterr(['Unknown type: ' Struct(2).type,'.']);
         errflag = 1;
         return;
      end
   end
case '{}'
   lasterr(error1);
   errflag = 1;
   return;
otherwise
   lasterr(['Unknown type: ' Struct(1).type,'.']);
   errflag = 1;
   return;
end

% ********************************************************************
% Check the multiple indices.
function [errflag, index] = localCheckIndex(obj, index)

% Initialize variables.
errflag = 0;
[m,n] = size(obj);

% Compare the first index to the number of rows.
if max(index{1}) > m || min(index{1}) < 1 
   if ~strcmp(index{1}, ':') 
      errflag = 1;
      lasterr('Index exceeds matrix dimensions.');
      return;
   end
end

% Compare the second index to the number of columns.
if max(index{2}) > n || min(index{2}) < 1 
   if ~strcmp(index{2}, ':')
      errflag = 1;
      lasterr('Index exceeds matrix dimensions.');
      return;
   end
end

% If any of the indices are empty than need to return empty brackets.
if isempty(index{1}) || isempty(index{2})
   errflag = 2;
   return;
end

% If obj is a row vector, replace index{1} with index{2} so only one 
% element of index is used and it doesn't have to be checked.
if m == 1
   index{1} = index{2};
end

% For the remaining indices, it is only valid if the index is 1 or ':'.
% If it is empty, an empty matrix should be returned therefore the errflag 
% is set to 2.
for i = 3:length(index)
   if ~isempty(index{i}) && length(index{i}) ~= 1
      errflag = 1;
      lasterr('Index exceeds matrix dimensions.');
      return;
   end
   if ~isempty(index{i}) && ~(strcmp(index{i}, ':') || all(index{i} == 1)) 
      errflag = 1;
      lasterr('Index exceeds matrix dimensions.');
      return;
   end
end

for i = 3:length(index)
   if isempty(index{i})
      errflag = 2;
      return;
   end
end

