function p = getMapCurrentPoint(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:52 $

p = get(this.Axis,'CurrentPoint');
p = [p(1) p(3)];