function true=eq(a,b)
%EQ returns true if both sgmltag have the same tag

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:32 $

true=strcmpi(a.tag,b.tag);