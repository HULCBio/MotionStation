function adv = getadv(model)
%GETADV extracts the advice field from a model.
%
%   Intended for internal use.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/03/24 17:24:19 $
adv = [];
try
    adv = model.Utility.advice;
end
