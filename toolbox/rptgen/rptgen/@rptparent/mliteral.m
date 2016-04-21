function out=mliteral(obj,in)
%MLITERAL converts an input string to a matlab string

%converts ' to ''
%converts \ to \\

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:21 $

out=[];
for i=1:length(in)
   switch in(i)
   case '\'
      out=[out,'\\'];
   case '%'
      out=[out,'%%'];
   case ''''
      %WTF???!!!
   otherwise
      out=[out,in(i)];
   end
end %for

