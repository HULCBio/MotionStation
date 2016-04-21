function xylabelvis(Editor,Xvis,Yvis)
% Low-level utility for hiding X/Y labels.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:02:15 $
if nargin>1
   % Update label visibility state (private)
   Editor.XlabelVisible = Xvis;
   Editor.YlabelVisible = Yvis;
end   
% Visible axes
visax = getaxes(Editor.Axes);
visax = visax(strcmp(get(visax,'Visible'),'on'));
% Set label visibility
for ct=1:length(visax)
   set(get(visax(ct),'XLabel'),'Visible',Editor.XlabelVisible)
   set(get(visax(ct),'YLabel'),'Visible',Editor.YlabelVisible)
end