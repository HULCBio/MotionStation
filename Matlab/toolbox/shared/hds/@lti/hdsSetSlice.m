function sys = hdsSetSlice(sys,Section,subsys)
%HDSSETSLICE  Modifies array slice.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:52 $
sys(:,:,Section{:}) = subsys;