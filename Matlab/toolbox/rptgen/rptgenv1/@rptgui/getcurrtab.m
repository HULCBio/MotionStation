function tab=getcurrtab(g)
%GETCURRTAB returns index of current tab

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:58 $

tab=get(g.h.Main.tabpatch,'UserData');
if isempty(tab) | tab<1 | tab>3
   tab=1;
end
