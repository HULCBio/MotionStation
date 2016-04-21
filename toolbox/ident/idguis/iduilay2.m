function figw=iduilay2(nobut)
%IDUILAY2 Computes window width based on the number of buttons.
%   figw = figure width
%   nobut = number of buttons

%   L. Ljung 10-10-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:39 $

layout
figw = 2*mEdgeToFrame+nobut*mStdButtonWidth+(nobut+1)*mFrameToText;