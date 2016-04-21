function hy = yextent(this,VisFilter)
%YEXTENT  Gathers all handles contributing to Y limits.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:38 $

hy = this.Curves;
hy(~VisFilter) = handle(-1);  % discard invisible curves
