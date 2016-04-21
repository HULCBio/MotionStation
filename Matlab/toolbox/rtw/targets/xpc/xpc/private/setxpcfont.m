function setxpcfont(handle,uifont,axesfont)

% SETXPCFONT - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.4.2.2 $ $Date: 2004/04/08 21:04:38 $

if strcmp(getxpcenv('SystemFontSize'),'Small')
   fontoffset=0;
else
   fontoffset=-2;
end
set(handle,'DefaultUIcontrolFontSize',uifont+fontoffset);
set(handle,'DefaultAxesFontSize',axesfont+fontoffset);

