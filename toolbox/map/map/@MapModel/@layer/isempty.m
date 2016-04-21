function isemp = isempty(this)
%ISEMPTY True for empty layer
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:17 $

isemp = numel(this.Components) == 0;
