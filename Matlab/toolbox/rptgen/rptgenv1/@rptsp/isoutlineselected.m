function true=isoutlineselected(p,currselect)
%ISOUTLINESELECTED returns true if the current selection contains coutline

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:25 $

true=any(currselect==1);

