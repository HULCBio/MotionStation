function value = get(hndl,varargin)
%SCRIBEHANDLE/GET Get scribehandle property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:13:08 $

ud = getscribeobjectdata(hndl.HGHandle);
value = get(ud.ObjectStore,varargin{:});
