function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   OUTLINESTRING(cobj) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:02 $

tString=c.att.Title;
if isempty(tString)
   tString='<No Title>';
end

strout=sprintf('Title Page - %s', xlate(tString) );