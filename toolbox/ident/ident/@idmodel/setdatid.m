function mod = setdatid(mod,id,ynorm)
%SETDATID Sets tha estimation data identity for a model

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2003/03/05 17:40:57 $

if nargin<3
    ynorm = [];
end
mod.Utility.advice.estimation.DataId = id;
mod.Utility.advice.estimation.DataNorm = ynorm;


 