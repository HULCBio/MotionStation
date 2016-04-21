function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component
%STROUT=OUTLINESTRING(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:07 $


fName=c.att.FileName;
if isempty(fName)
   fName='<None Specified>';
end

strout=sprintf('File - %s', xlate(fName));