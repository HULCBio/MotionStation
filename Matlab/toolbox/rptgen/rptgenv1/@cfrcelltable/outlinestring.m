function strout=outlinestring(c)
%OUTLINESTRING display short component description

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:09 $

if c.att.isArrayFromWorkspace
   vName=c.att.WorkspaceVariableName;
   if isempty(vName)
      vName='<no variable specified>';
   end
else
   if ischar(c.att.TableTitle)
      vName=c.att.TableTitle;
   else
      vName='<internal cell array>';
   end
end

strout=sprintf('Table - %s', xlate(vName));



