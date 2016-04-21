function isneq=ne(arg1, arg2)
%NE Overload of ~= for data acquisition objects.
%

%    MP 12-22-98   
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.4 $  $Date: 2003/08/29 04:41:21 $

% Turn off warning backtraces.
s = warning('off', 'backtrace');
   
% Error if both the objects have a length greater than 1 and have
% different sizes.
if prod(size(arg1))~=1 && prod(size(arg2))~=1
	if size(arg1,1)~=size(arg2,1) || size(arg1,2)~=size(arg2,2)
		error('daq:ne:size', 'Matrix dimensions must agree.')
	end
end

% Warn appropriately if one of the input arguments is empty.
if isempty(arg1)
    isneq = logical([]);
	return;
elseif isempty(arg2)
    isneq = logical([]);
	return;
end
% Restore warning backtrace state.
warning(s);

% Determine if both objects are daqdevice objects.
if isa(arg1, 'daqdevice') && isa(arg2, 'daqdevice')

   % Return FALSE if one of the objects has an invalid handle.
   if ~any(isvalid(arg1)) || ~any(isvalid(arg2))
    	isneq = logical(1);
		return;
   end
      
   % If the objects are not of length 1, loop through each object and 
   % determine if they are equal.
   if prod(size(arg1))~=1 && prod(size(arg2))~=1
      % Initialize variables.      
      isneq = zeros(size(arg1));
      
      for i = 1:length(arg1)
         
         % Get the handles to the input arguments.
         handle1 = daqgetfield(arg1, 'handle');
         handle2 = daqgetfield(arg2, 'handle');

         % Get the CreationTime.
         creationTime1 = daqmex(handle1(i), 'get', 'CreationTime');
         creationTime2 = daqmex(handle2(i), 'get', 'CreationTime');
         
         % The object's are equal if the objects have the same handle and 
         % CreationTime.
         isneq(i) = ~(creationTime1 == creationTime2 &...
            double(handle1(i)) == double(handle2(i)));
      end
   elseif prod(size(arg1))==1,
      % If arg1 is of length one, then determine if each element of arg2
      % is equal to arg1.
      
      % Initialize variables.
      isneq = zeros(size(arg2));
      
      % Obtain arg1's handle and CreationTime.
      handle1 = daqgetfield(arg1, 'handle');   
      creationTime = get(arg1,'CreationTime');
      
      % Get all the handles for arg2.
      handle = daqgetfield(arg2, 'handle');
      
      % Loop through each element of arg2 and compare to arg1.
      for i = 1:length(arg2)
         % Get the CreationTime.
         creationTime2 = daqmex(handle(i), 'get', 'CreationTime');
         
         % The object's are equal if they have the same handle and CreationTime.
         isneq(i) = ~(creationTime == creationTime2 &...
            double(handle1)==double(handle(i)));
      end
   elseif prod(size(arg2))==1
      % If arg2 is of length one, then determine if each element of arg1
      % is equal to arg2.
      
      % Initialize variables.
      isneq = zeros(size(arg1));
      
      % Obtain arg2's handle and CreationTime.
      handle2 = daqgetfield(arg2, 'handle');
      creationTime = get(arg2,'CreationTime');
      
      % Get all the handles for arg1.
      handle = daqgetfield(arg1, 'handle');
      
      % Loop through each element of arg1 and compare to arg2.
      for i = 1:length(arg1)
         % Get the CreationTime.
         creationTime1 = daqmex(handle(i), 'get', 'CreationTime');
         
         % The object's are equal if they have the same handle and CreationTime.
         isneq(i) = ~(creationTime1 == creationTime &...
            double(handle2) == double(handle(i)));
      end
   end
elseif ~isempty(arg1) && ~isempty(arg2)
   % One of the object's are not a daqchild and therefore unequal.
   % Error if both the objects have a length greater than 1 and have
   % different sizes.
   if prod(size(arg1))~=1 && prod(size(arg2))~=1
      if size(arg1,1)~=size(arg2,1) || size(arg1,2)~=size(arg2,2)
         error('daq:ne:size', 'Matrix dimensions must agree.')
      end
   end
   % Return a logical zero. 
   isneq = logical(1);
end

