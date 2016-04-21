function out=execute(c)
%EXECUTE generates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:16 $

myChildren = children(c);
if length(myChildren)>0
    out=runcomponent(children(c));
else
    out=c.att.TrueText;
end
