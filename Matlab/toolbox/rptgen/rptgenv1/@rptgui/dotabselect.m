function g=dotabselect(g,tabnum,forceupdate)
%DOTABSELECT select tab by index

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:57 $

currtab=get(g.h.Main.tabpatch,'UserData');

if nargin<3
   forceupdate=logical(0);
   if nargin<2
      %if no tab number is specified, rotate through options
      if currtab<3
         tabnum=currtab+1;
      else
         tabnum=1;
      end
   end
end

if tabnum==currtab & ~forceupdate
else
   set(g.h.Main.tabpatch,'UserData',tabnum);
   g=updateui(g,'NewTab');
end
