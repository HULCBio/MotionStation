function tf=ishandle(t)
%ISHANDLE returns true for valid TLC context handles

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:03 $

if ~isempty(t.Handle)
   tf=~isempty(find(tlc('list')==t.Handle));
else
   tf=logical(0);
end


