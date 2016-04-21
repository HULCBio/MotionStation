function paste(this,position)
%paste paste this Text object
%
%  paste(POSITION) moves object to POSITION and makes the line visible.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:05 $

set(this,'Position',position);
set(this,'Selected','off');
