function fig = nntitlef(s1,s2,s3,s4,s5,s6)
%NNTITLEF Standard title figure for Neural Network Toolbox GUI.

%  NNTITLEF(S1,S2,S3,S4,S5,S6)
%    S1 - Name of window (default = 'NNTITLEF').
%    S2 - Identifier in window (default = 'TOOLBOX').
%    S3 - Subtitle (default = 'For Use with MATLAB').
%    S4 - First author (default = 'Mark Beale').
%    S5 - Second author (default = 'Howard Demuth').
%    S6 - Third author (default = '').
%
%  NNTITLEF stores the following handles:
%    H(1) = Axis covering entire figure in pixel coordinates.
%  Where H is the user data of the demo figure.

% First Version, 8-31-95.
% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.

% BACKGROUND

fig = nnbg(s1);
set(gcf,'nextplot','add')

% TITLE

text(80,370,'Neural Network', ...
  'color',nnblack,'fontname','times', ...
  'fontsize',36,'fontangle','italic','fontweight','bold');
text(80,330,s2,... 
  'color',nnblack,'fontname','times', ...
  'fontsize',42,'fontweight','bold');
  
% TOP LINE

nndrwlin([0 420],[305 305],4,nndkblue);

% CENTER BOX

nngraybx(80,76,340,227) % ,'names'

% SUBTITLE

text(405,290,s3,...
  'color',nnblack,'fontname','times', ...
  'fontsize',18, ...
  'HorizontalAlignment','right');

% REGISTERED TRADEMARK SYMBOL

if length(s3) >= 6
  if strcmp(s3(length(s3)+[-5:0]),'MATLAB')
    text(409,294,'R', ...
      'color',nnblack, ...
      'fontname','helvetica', ...
      'fontsize',5, ...
      'horizontal','center');
    angle = [0:20:360]*pi/180;
    plot(409+cos(angle)*3.0,294-sin(angle)*3.0,'color',nnblack)
  end
end
  
% LOWER RIGHT

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
  if strcmp(s5,''), pos = 44; else pos = 28; end
else
  pos = 10;
end

nndrwlin([360 501],[pos pos],4,nndkblue);

% LOCK FIGURE

set(fig,'color',nndkgray,'color',nnltgray)
set(fig,'nextplot','new')
