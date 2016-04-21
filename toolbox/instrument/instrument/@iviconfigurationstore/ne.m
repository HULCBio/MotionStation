function isneq = ne(arg1, arg2)
%NE Overload of ~= for IVI Configuration Store objects.

%   MP 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:39 $

% Warn appropriately if one of the input arguments is empty.
if isempty(arg1)
    if (length(arg2) == 1)
       isneq = [];
   else
       error('iviconfigurationstore:ne:dimagree', 'Matrix dimensions must agree.');
   end
   return;
elseif isempty(arg2)
   if (length(arg1) == 1)
       isneq = [];
   else
       error('iviconfigurationstore:ne:dimagree', 'Matrix dimensions must agree.');
   end
   return;
end

% Get size of objects.
sizeOfArg1 = size(arg1);
sizeOfArg2 = size(arg2);

% Error if both the objects have a length greater than 1 and have
% different sizes.
if (numel(arg1)~=1) && (numel(arg2)~=1)
    if ~(all(sizeOfArg1 == sizeOfArg2))
        error('iviconfigurationstore:ne:dimagree', 'Matrix dimensions must agree.')
    end
end

if (numel(arg1) == 1)
    if (numel(arg2) == 1)
        % Both have length of one.
        isneq = (arg1.h ~= arg2.h);
    else
        % First object has a length of one. Compare to each object
        % in the second argument.
        for idx = 1:numel(arg2)
            isneq(idx) = (arg1.h ~= arg2(idx).h);
        end
    end
else
    if (numel(arg2) == 1)
        % Second object has a length of one. Compare to each
        % object in the first argumetn.
        for idx = 1:numel(arg1)
            isneq(idx) = (arg1(idx).h ~= arg2.h);
        end
    else
        for idx = 1:numel(arg1)
            isneq(idx) = (arg1(idx).h ~= arg2(idx).h);
        end
    end
end
