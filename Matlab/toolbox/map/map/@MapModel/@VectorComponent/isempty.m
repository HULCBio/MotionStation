function isemp = isempty(this)
%ISEMPTY True if component has no features.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:04 $

isemp = numel(this.Features) == 0;