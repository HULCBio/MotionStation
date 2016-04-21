function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component
%   STRING=OUTLINESTRING(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:34 $

strout=sprintf( ...
      '%s Property - %s',c.att.ObjectType, ...
      getfield(c.att,[c.att.ObjectType 'Property']));
