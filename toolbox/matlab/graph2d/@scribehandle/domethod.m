function domethod(A, method, varargin)
%SCRIBEHANDLE/DOMETHOD Domethod method for scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:13:03 $

ud = getscribeobjectdata(A.HGHandle);
MLObj = ud.ObjectStore;
MLObj = feval(method, MLObj, varargin{:});

% writeback
ud.ObjectStore = MLObj;
setscribeobjectdata(A.HGHandle,ud);
