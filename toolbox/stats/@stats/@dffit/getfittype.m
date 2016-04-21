function txt = getcategory(hFit)
%GETFITTYPE Return fit type, either parametric or smooth

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:46 $
%   Copyright 2003-2004 The MathWorks, Inc.

txt = hFit.fittype;
