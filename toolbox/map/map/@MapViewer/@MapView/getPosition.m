function p = getPosition(this,units);

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:14:53 $

oldunits = get(this.Figure,'Units');
set(this.Figure,'Units',units);
p = get(this.Figure,'Position');
set(this.Figure,'Units',oldunits);
