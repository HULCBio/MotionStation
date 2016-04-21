function hy = yextent(this,VisFilter)
%YEXTENT  Gathers all handles contributing to Y limits.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:59 $

hy = this.Curves;
hy(~VisFilter) = handle(-1);  % discard invisible curves
