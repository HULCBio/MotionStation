function sys = hdsGetSlice(sys,Section)
%HDSGETSLICE  Extracts array slice.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:48 $
sys = sys(:,:,Section{:});