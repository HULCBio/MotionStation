function h=nndtext(t,x,y,a)
%NNDTEXT Neural Network Design utility function.

%  NNDTEXT(T,X,Y)
%    T - Text (string).
%   X - Horizontal coordinate.
%   Y - Vertical coordinate.
%   A - Horizontal alignment (default = 'center').
% Draws text T at location (X,Y) in bold and NNDKBLUE and
% erasemode of 'none'. Optionally returns handle to text.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.7 $

%==================================================================

% DEFAULTS
if nargin < 4, a = 'center'; end

% DRAW
H = text(t,x,y,...
  'color',nndkblue',...
  'fontweight','bold',...
  'horiz',a,...
  'erasemode','none');

% RETURN VALUE
if nargout, h = H; end
