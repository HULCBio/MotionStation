function [x,y] = nngetclk(s)
%NNGETCLK Get coordinates by mouse click from user.
%
%  [X,Y] = NNGETCLK(S)
%    S - String to display in axis (default = '< CLICK ME >').
%  Returns:
%    X - Horizontal coordinate of mouse click.
%    Y - Vertical coordinate.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% DEFAULT

if nargin < 1, s = '< CLICK ME>'; end

% DISPLAY TEXT, GET CLICK, REMOVE TEXT

th = nncentxt(s); set(th,'color',nndkblue);
[x,y] = ginput(1);
delete(th)
