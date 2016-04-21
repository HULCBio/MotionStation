function c = unpoint(c)
%UNPOINT converts from a pointer to a component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:22 $

refStruct = subsref(c,substruct('.','ref'));
if ~isempty(refStruct.ID)
	c = unpoint(refStruct.ID);
end

