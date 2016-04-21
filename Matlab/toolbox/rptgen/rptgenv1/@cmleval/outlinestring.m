function strout=outlinestring(c)
%OUTLINESTRING display short component description

%returns the string to be appended to the end of the component's
%name in the setup file editor's "outline" listbox

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:32 $

info=getinfo(c);

if isempty(c.att.EvalString)
   strout=xlate(info.Name);
else
   strout=sprintf('Eval string -%s',c.att.EvalString{1});
end



