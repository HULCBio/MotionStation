function out=execute(c)
%OUTLINESTRING display short component description

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:31 $

out=[];
if c.att.isprefix
   out=[out,c.att.prefixstring];
end

if c.att.istime
   out=[out,' ',gettime(c)];
end

if c.att.isdate
   out=[out,' ',getdate(c)];
end
   