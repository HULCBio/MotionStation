function hy = yextent(this,VisFilter)
%  YEXTENT  Gathers all handles contributing to Y limits.

%  Author: Pascal Gahinet
%  Revised: Kamesh Subbarao, 10-16-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:30 $

hy = this.Curves;
hy(~VisFilter) = handle(-1);  % discard invisible curves
