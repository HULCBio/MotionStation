function fig = nndemof2(s1,s2,s3,s4,s5)
% NNDEMOF2 Neural Network Design utility function.

% Standard demo figure for Neural Network Toolbox GUI.
%
%  NNDEMOF2(S1,S2,S3)
%    S1 - Name of window (default = 'NNDEMOF').
%    S2 - Identifer in window (default = 'TOOLBOX').
%    S3 - Title (default = 'Demonstration').
%    S4 - Chapter name.
%    S5 - Other name.
%  Returns handle to figure.
%
%  NNDEMOF2 stores the following handles:
%    H(1) = Axis covering entire figure in pixel coordinates.
%    H(2) = First line of text at bottom of figure.
%  Where H is the user data of the demo figure.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% DEFAULTS

if nargin < 1,s1 = 'NNDEMOF';end
if nargin < 2,s2 = 'DESIGN';end
if nargin < 3,s3 = 'Demonstration';end
if nargin < 4,s4 = '';end
if nargin < 5,s5 = '';end

% BACKGROUND

fig = nnbg(s1,[0 0 500 400]);

% UNLOCK AND GET HANDLES

set(fig,'nextplot','add')
H = get(fig,'userdata');
h1 = H(1);

% TITLES

text(25,380,'Neural Network', ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontangle','italic', ...
  'fontweight','bold');
text(135,380,s2, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontweight','bold');
text(415,380,s3,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontweight','bold',...
  'HorizontalAlignment','right');

% TOP LINE

nndrwlin([0 415],[365 365],4,nndkblue);

% SIDE LINE

nndrwlin([380 380],[340 22],4,nndkblue);

% TEXT

h2 = text(390,315,'',...
  'color',nnblack, ...
  'fontname','helvetica', ...
  'fontsize',10);
text1 = h2;

for i=1:30
  text2 = text(390,315-6*i,'',...
    'color',nnblack, ...
    'fontname','helvetica', ...
    'fontsize',10);
  set(text1,'userdata',text2);
  text1 = text2;
end
set(text1,'userdata','end');

% AUTHOR & BOTTOM LINE

text(410,54,s4, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
text(410,38,s5, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
nndrwlin([410 501],[24 24],4,nndkblue);

% SAVE HANDLES AND LOCK FIGURE

set(fig,'userdata',[h1 h2])
set(fig,'color',nndkgray,'color',nnltgray)
set(fig,'nextplot','new')
%hidegui
