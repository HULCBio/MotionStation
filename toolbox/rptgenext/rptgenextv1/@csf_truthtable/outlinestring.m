function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   STR=OUTLINESTRING(C) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:47 $

strout = xlate('Truth Table');

