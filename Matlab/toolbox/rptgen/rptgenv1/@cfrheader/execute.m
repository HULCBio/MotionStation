function out=execute(c)
%EXECUTE create report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:14 $

out=sgmltag;
out.tag='BridgeHead';

if ~isempty(c.att.weight)
   out=att(out,'Renderas',c.att.weight);
end

myChildren=children(c);
if length(myChildren)>0
   out=[out;runcomponent(myChildren)];
else
   out=[out;c.att.headertext];
end
