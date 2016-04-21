function centerfigonfig(hFig, hmsg)
% CENTERFIGONFIG Center hmsg figure on top of hfig figure.
%
% Inputs:
%   hFig - Handle to the Filter Design GUI figure. 
%   hmsg - Handle to the figure to be centered on hFig.

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:47:41 $ 

set(hFig,'units','pix');
figPos = get(hFig,'pos');
figCtr = [figPos(1)+figPos(3)/2 figPos(2)+figPos(4)/2];

set(hmsg,'units','pix');
msgPos = get(hmsg,'position');
msgCtr = [msgPos(1)+msgPos(3)/2 msgPos(2)+msgPos(4)/2];

movePos = figCtr - msgCtr;

new_msgPos = msgPos;
new_msgPos(1:2) = msgPos(1:2) + movePos;
set(hmsg,'Position',new_msgPos);

% [EOF] centerfigonfig.m
