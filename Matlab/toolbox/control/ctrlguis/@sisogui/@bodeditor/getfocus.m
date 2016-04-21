function Focus = getfocus(Editor)
%GETFOCUS  Computes scale-aware X focus.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $ $Date: 2002/04/04 15:19:32 $

Focus = Editor.FreqFocus;
if strcmp(Editor.Axes.XScale,'log')
   % Round to entire decade in current units
   % RE: This avoids irritating Y clipping when X focus is extended to
   %     nearest decade
   Focus = unitconv(Focus,'rad/sec',Editor.Axes.XUnits);  
   Focus = log10(Focus);
   Focus = 10.^[floor(Focus(1)),ceil(Focus(2))];
   Focus = unitconv(Focus,Editor.Axes.XUnits,'rad/sec');  
end
