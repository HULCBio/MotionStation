function tf=isoutlineselected(p)
%ISOUTLINESELECTED returns true if input component is coutline
%   Returns true if one of the handles contained in P
%   is the handle to the outline component.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:46 $

parentH=get(p.h,'Parent');

if iscell(parentH)
   parentH=[parentH{:}];
end

parentType=get(parentH,'Type');
tf=any(~strcmp(parentType,'uimenu'));


