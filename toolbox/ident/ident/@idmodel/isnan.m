function tv = isnan(mod)
%IDMODEL/ISNAN
%
%   ISNAN(Model) returns 1 if Model contains any NaN parameter

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/07/28 12:29:51 $

tv = any(isnan(mod.ParameterVector));

