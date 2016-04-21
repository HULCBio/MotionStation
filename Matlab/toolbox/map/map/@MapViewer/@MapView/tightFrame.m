function tightFrame(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:15:04 $

% The toolbar and display panel need about 70 pixels, so the height needs
% 60 added to it.
s = this.getVisibleAxisSize('pixels');
figurePosition = getPosition(this.Figure,'pixels');
figurePosition(3) = max(s(1),this.MinWidth);
figurePosition(4) = max(s(2),this.MinHeight) + 70;
setPosition(this.Figure,figurePosition,'pixels');

function p = getPosition(h,units)
oldunits = get(h,'Units');
set(h,'Units',units);
p = get(h,'Position');
set(h,'Units',oldunits);

function setPosition(h,p,units)
oldunits = get(h,'Units');
set(h,'Units',units);
set(h,'Position',p);
set(h,'Units',oldunits);
