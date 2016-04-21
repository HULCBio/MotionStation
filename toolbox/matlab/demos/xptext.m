function xptext(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12)
%XPTEXT An EXPO helper function to create text in figure windows.
%   XTEXT(S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12) puts strings
%   into the text window in a fixed width font.

%   Mark W. Reichelt, 7-30-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.8 $  $Date: 2002/04/15 03:33:17 $

cla reset
set(gca,'Box','on','XTick',[],'YTick',[],'Visible','on');

for i = 1:nargin
  eval(['text(0.03,' num2str(1-0.1*i) ',s' num2str(i) ...
         ',''FontName'',''8x13'');']);
end
