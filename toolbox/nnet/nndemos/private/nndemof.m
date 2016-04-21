function fig = nndemof(s1,s2,s3,s4,s5)
%NNDEMOF Neural Network Design utility function.

% Standard demo figure for Neural Network Toolbox GUI.
%
%  NNDEMOF(S1,S2,S3)
%    S1 - Name of window (default = 'NNDEMOF').
%    S2 - Identifer in window (default = 'TOOLBOX').
%    S3 - Title (default = 'Demonstration').
%    S4 - Author first name (default = 'Mark').
%    S5 - Author last name (default = 'Beale').
%  Returns handle to figure.
%
%  NNDEMOF stores the following handles:
%    H(1) = Axis covering entire figure in pixel coordinates.
%    H(2) = First line of text at bottom of figure.
%  Where H is the user data of the demo figure.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.
% $Revision: 1.7 $

% DEFAULTS

if nargin < 1,s1 = 'NNDEMOF';end
if nargin < 2,s2 = 'TOOLBOX';end
if nargin < 3,s3 = 'Demonstration';end
if nargin < 4,s4 = '';end
if nargin < 5,s5 = '';end

% BACKGROUND

fig = nnbg(s1,NaN);

% UNLOCK AND GET HANDLES

set(fig,'nextplot','add')
H = get(fig,'userdata');
h1 = H(1);

% TITLES

text(35,376,'Neural Network', ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontangle','italic', ...
  'fontweight','bold');
text(35,356,s2,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',20, ...
  'fontweight','bold');
text(415,356,s3,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',18, ...
  'HorizontalAlignment','right');

% TOP LINE

nndrwlin([0 415],[340 340],4,nndkblue);

% MIDDLE LINE

nndrwlin([0 415],[122 122],4,nndkblue);

% TEXT

h2 = text(35,108,'',...
  'color',nnblack, ...
  'fontname','helvetica', ...
  'fontsize',10);
text1 = h2;

for i=1:17
  text2 = text(35,108-6*i,'',...
    'color',nnblack, ...
    'fontname','helvetica', ...
    'fontsize',10);
  set(text1,'userdata',text2);
  text1 = text2;
end
set(text1,'userdata','end');

% AUTHOR & BOTTOM LINE

text(415,54,s4, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
text(415,38,s5, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
nndrwlin([415 501],[24 24],4,nndkblue);

% SAVE HANDLES AND LOCK FIGURE

set(fig,'userdata',[h1 h2])
set(fig,'color',nndkgray,'color',nnltgray)
set(fig,'nextplot','new')



