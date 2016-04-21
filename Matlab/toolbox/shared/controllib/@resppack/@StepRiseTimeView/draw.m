function draw(cv,cd,NormalRefresh)
%DRAW  Draws peak response characteristic.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:51 $

% Make sure dots are included in Y limit picking
% RE: dot always sits on 95% threshold line
for ct=1:prod(size(cv.Points))
   set(double(cv.Points(ct)),'XData',0,'YData',cd.Amplitude(ct))
end