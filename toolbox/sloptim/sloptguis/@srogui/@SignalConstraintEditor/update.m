function update(this)
% Updates display

%   Author: Pascal Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.

% Update plot
drawconstr(this)
% Update limits
this.Axes.send('ViewChanged')

