function fig = nntocf(s1,s2,s3,s4,s5,s6)
%NNTOCF Standard table of contents figure for Neural Network Toolbox GUI.

%  NNTOCF(S1,S2,S3,S4,S5,S6)
%    S1 - Name of window (default = 'NNDEMOF').
%    S2 - Identifer in window (default = 'TOOLBOX').
%    S3 - Title (default = 'Demonstration').
%    S4 - First author (default = 'Mark Beale').
%    S5 - Second author (default = 'Howard Demuth').
%    S6 - Third author (default = '').
%
%  NNTOCF stores the following handles:
%    H(1) = Axis covering entire figure in pixel coordinates.
%  Where H is the user data of the demo figure.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% DEFAULTS
if nargin < 1,s1 = 'NNTOCF';end
if nargin < 2,s2 = 'TOOLBOX';end
if nargin < 3,s3 = 'Table of Contents';end
if nargin < 4,s4 = '';end
if nargin < 5,s5 = '';end
if nargin < 6,s6 = '';end

% BACKGROUND
fig = nnbg(s1,[80 76 340 262]);

% UNLOCK FIGURE
set(gcf,'nextplot','add')

% TITLES
text(80,376,'Neural Network', ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontangle','italic', ...
  'fontweight','bold');
text(80,356,s2,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',20, ...
  'fontweight','bold');
text(420,356,s3,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',18, ...
  'HorizontalAlignment','right');

% TOP LINE & MENU BOX
nndrwlin([0 420],[340 340],4,nndkblue);
nngraybx(80,76,340,262)

% AUTHORS
text(360,60,s4, ...
  'color',nnblack,'fontname','times', ...
  'fontsize',12,'fontweight','bold');
text(360,42,s5, ...
  'color',nnblack,'fontname','times', ...
  'fontsize',12,'fontweight','bold');
text(360,24,s6, ...
  'color',nnblack,'fontname','times', ...
  'fontsize',12,'fontweight','bold');

% BOTTOM LINE
if strcmp(s6,'')
  if strcmp(s5,''), pos = 42; else pos = 28; end
else
  pos = 10;
end
nndrwlin([360 501],[pos pos],4,nndkblue);

% LOCK FIGURE
set(fig,'color',nndkgray,'color',nnltgray)
set(fig,'nextplot','new')
