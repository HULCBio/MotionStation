function [prop1, index1, prop2, index2, errflag] = privateparsedevice(Obj,Struct)
%PRIVATEPARSEDEVICE Parse input for daqdevice objects.
%
%    [PROP1, INDEX1, PROP2, INDEX2, ERRFLAG] = PRIVATEPARSEDEVICE(OBJ,STRUCT) 
%    parses the input structure, STRUCT, into property names (PROP1 and PROP2)
%    and indices (INDEX1 and INDEX2).  If an error occurred, ERRFLAG = 1.  
%
%    For example, ai(1).Channel(2).ChannelName would parse into
%    INDEX1 = 1, PROP1 = 'Channel', INDEX2 = 2, PROP2 = ChannelName.
%
%    PRIVATEPARSEDEVICE is a helper function for @daqdevice\subsref and
%    @daqdevice\subsasgn.
%

%    MP 6-03-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:42:29 $


% Initialize variables
StructL = length(Struct);
prop1 = '';
prop2 = '';
index1 = {};
index2 = {};
errflag = 0;

% Define possible error messages
error1 = 'Inconsistently placed ''()'' in subscript expression.';
error2 = 'Cell contents reference from a non-cell array object.';
error3 = 'Inconsistently placed ''.'' in subscript expression.';

% Parse the input structure, Struct, into the index1, prop1, index2  
% and prop2 variables.  Syntax: obj(index1).prop1(index2).prop2.

% The first Struct can either be:
% obj(1); 
% obj.SampleRate;
switch Struct(1).type
case '.'
   prop1 = Struct(1).subs;
case '()'
   index1 = Struct(1).subs;
   if length(index1) > 1
      % Ex. obj(1,2) 
      [errflag, index1] = localCheckIndex(Obj, index1);
      if errflag
         return;
      end
   end
case '{}'
   lasterr(error2);
   errflag = 1;
   return;
otherwise
   lasterr(['Unknown type: ' Struct(1).type,'.']);
   errflag = 1;
   return;
end

if StructL > 1
   % Ex. obj.Channel.ChannelName;
   % Ex. obj(1).Channel;
   % Ex. obj.Channel(1);
   switch Struct(2).type
   case '.'
      if isempty(index1)
         % Ex. obj.Channel.ChannelName;
         prop2 = Struct(2).subs;
      else
         % Ex. obj(1).Channel;
         prop1 = Struct(2).subs;
      end
   case '()'
      % Ex. obj.Channel(1);
      index2 = Struct(2).subs;
   case '{}'
      lasterr(error2);
      errflag = 1;
      return;
   otherwise
      lasterr(['Unknown type: ' Struct(2).type,'.']);
      errflag = 1;
      return;
   end  
   
   if StructL > 2
      % Ex. ai.Channel(1).ChannelName
      % Ex. ai(1).Channel(1)
      switch Struct(3).type
      case '.'
         if isempty(prop2)
            prop2 = Struct(3).subs; 
         else
            errflag = 1;
            lasterr(error3);
            return;
         end
      case '()'
         index2 = Struct(3).subs;
      case '{}'
         lasterr(error2);
         errflag = 1;
         return;
      otherwise
         lasterr(['Unknown type: ' Struct(3).type,'.']);
         errflag = 1;
         return;
      end
      
      if StructL > 3
         % Ex. ai(1).Channel(1).ChannelName
         switch Struct(4).type
         case '.'
            prop2 = Struct(4).subs; 
         case '()'
            lasterr(error1);
            errflag = 1;
            return;
         case '{}'
            lasterr(error2);
            errflag = 1;
            return;
         otherwise
            lasterr(['Unknown type: ' Struct(4).type,'.']);
            errflag = 1;
            return;
         end
         if StructL > 4
            lasterr(['Inconsistenly placed ''' Struct(5).type ''' in subscript expression.']);
            errflag = 1;
            return;
         end
      end
   end
end

% ********************************************************************
% Check the multiple indices.
function [errflag, index] = localCheckIndex(obj, index)

% Initialize variables.
errflag = 0;
[m,n] = size(obj);
error1 = 'Index exceeds matrix dimensions.';

% Compare the first index to the number of rows.
if max(index{1}) > m || min(index{1}) < 1 
   if ~strcmp(index{1}, ':') 
      errflag = 1;
      lasterr(error1);
      return;
   end
end

% Compare the second index to the number of columns.
if max(index{2}) > n || min(index{2}) < 1 
   if ~strcmp(index{2}, ':')
      errflag = 1;
      lasterr(error1);
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
% Ex. obj(1,5) becomes obj(5,5) but only the first index is used.
if m == 1
   index{1} = index{2};
end

% For the remaining indices, it is only valid if the index is 1 or ':'.
% If it is empty, an empty matrix should be returned therefore the errflag 
% is set to 2.
for i = 3:length(index)
   if ~isempty(index{i}) && ~(strcmp(index{i}, ':') || all(index{i} == 1)) 
      errflag = 1;
      lasterr(error1);
      return;
   end
   if isempty(index{i})
      errflag = 2;
      return;
   end
end
