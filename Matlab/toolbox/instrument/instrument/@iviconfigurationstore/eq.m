function iseq = eq(arg1, arg2)
%EQ Overload of == for IVI Configuration Store objects.

%   PE 9-30-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 19:59:31 $

% Warn appropriately if one of the input arguments is empty.
if isempty(arg1)
    if (length(arg2) == 1)
       iseq = [];
   else
       error('iviconfigurationstore:eq:dimagree', 'Matrix dimensions must agree.');
   end
   return;
elseif isempty(arg2)
   if (length(arg1) == 1)
       iseq = [];
   else
       error('iviconfigurationstore:eq:dimagree', 'Matrix dimensions must agree.');
   end
   return;
end

sizeOfArg1 = size(arg1);
sizeOfArg2 = size(arg2);

if (numel(arg1)~=1) && (numel(arg2)~=1)
    if ~(all(sizeOfArg1 == sizeOfArg2))
        error('iviconfigurationstore:eq:dimagree', 'Matrix dimensions must agree.')
    end
end

if (numel(arg1) == 1)
    if (numel(arg2) == 1)
        iseq = (arg1.h == arg2.h);
    else
        for idx = 1:numel(arg2)
            iseq(idx) = (arg1.h == arg2(idx).h);
        end
    end
else
    if (numel(arg2) == 1)
        for idx = 1:numel(arg1)
            iseq(idx) = (arg1(idx).h == arg2.h);
        end
    else
        for idx = 1:numel(arg1)
            iseq(idx) = (arg1(idx).h == arg2(idx).h);
        end
    end
end
