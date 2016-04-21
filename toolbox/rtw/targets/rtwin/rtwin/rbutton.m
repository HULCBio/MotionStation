function rbutton(h)
%RBUTTON Toggle radio buttons.
%
%   RBUTTON selects the current radio button and deselects the 
%   rest of the group. All the members of the group have the same Tag.
%   RBUTTON(H) selects a radio button with the handle H.
%   This function is called by device driver GUIs.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 18:53:20 $  $Author: batserve $

if nargin==0; h=gcbo; end;

h=h(1);
for i=findobj(get(h,'Parent'),'Tag',get(h,'Tag'))'
  set(i,'Value',get(i,'Min'));
end;

set(h,'Value',get(h,'Max'));

