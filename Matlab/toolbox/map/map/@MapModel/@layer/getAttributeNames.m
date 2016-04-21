function attrNames = getAttributeNames(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:22 $

% Assume only one component at this time.
attrNames = this.Components(1).getAttributeNames;