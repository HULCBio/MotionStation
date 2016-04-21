function strout=outlinestring(c)
%OUTLINESTRING display short component description

%returns the string to be appended to the end of the component's
%name in the setup file editor's "outline" listbox

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:56 $

strout=sprintf('elseif (%s)', c.att.ConditionalString );