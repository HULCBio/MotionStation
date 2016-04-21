function [rnames,cnames] = getrcname(src)
%GETIONAMES  Returns input and output names.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:53 $
rnames = get(src.Model,'OutputName');
cnames = get(src.Model,'InputName');
