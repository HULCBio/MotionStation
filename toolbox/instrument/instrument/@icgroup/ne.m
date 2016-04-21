function isneq=ne(arg1, arg2)
%NE Overload of ~= for device group objects.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 20:00:13 $

% Warn appropriately if one of the input arguments is empty.
if isempty(arg1)
    if (length(arg2) == 1)
       isneq = [];
   else
       error('icgroup:ne:dimagree', 'Matrix dimensions must agree.');
   end
   return;
elseif isempty(arg2)
   if (length(arg1) == 1)
       isneq = [];
   else
       error('icgroup:ne:dimagree', 'Matrix dimensions must agree.');
   end
   return;
end

% Determine if both objects are instrument objects.
try   
   % Initialize variables.
   jarg1 = igetfield(arg1, 'jobject');
   jarg2 = igetfield(arg2, 'jobject');

   % Error if both the objects have a length greater than 1 and have
   % different sizes.
   sizeOfArg1 = size(jarg1); 
   sizeOfArg2 = size(jarg2); 
   
   if (numel(jarg1)~=1) && (numel(jarg2)~=1)
      if ~(all(sizeOfArg1 == sizeOfArg2)) 
         error('icgroup:ne:dimagree', 'Matrix dimensions must agree.')
      end
   end
  
   isneq = (jarg1 ~= jarg2);
catch
    % Rethrow error from above.
    [msg, id] = lasterr;
    if strcmp(id, 'icgroup:ne:dimagree')
        rethrow(lasterror);
    end
    
   % One of the object's is not an instrument object and therefore unequal.
   % Error if both the objects have a length greater than 1 and have
   % different sizes.    
   if prod(size(arg1))~=1 && prod(size(arg2))~=1
       if size(arg1,1)~=size(arg2,1) || size(arg1,2)~=size(arg2,2)
          error('icgroup:ne:dimagree', 'Matrix dimensions must agree.')
      end
   end
   
   % Return a logical zero. 
   if length(arg1) ~= 1
       isneq = ones(size(arg1));
   else
       isneq = ones(size(arg2));
   end
end

isneq = logical(isneq);

