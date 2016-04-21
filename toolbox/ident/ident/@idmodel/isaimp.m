function res = isaimp(model)
% ISAIMP Tests if a model is an impulse response model, computed by
%        IMPULSE

%   $Revision: 1.3 $ $Date: 2001/01/16 15:22:38 $
%   Copyright 1986-2001 The MathWorks, Inc.

res = 0;
if isa(model,'idarx')
    ut = pvget(model,'Utility');
    res = isfield(ut,'impulse');
end


