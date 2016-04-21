function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:03 $

if c.att.isUseVariable
   varName=c.att.VariableName;
else
   varName='i';
end

if strcmp(c.att.LoopType,'$vector')
   numString=c.att.LoopVector;
   %we may need to put brackets around the string
   if isempty(findstr(numString,'[')) & ...
         isempty(findstr(numString,']'))
      numString=sprintf('[%s]',numString);
   end
else
   numString=sprintf('%s:%s:%s',...
      c.att.StartNumber,...
      c.att.IncrementNumber,...
      c.att.EndNumber);      
end

strout=['for ' varName ' = ' numString];
