function nnchkfs
% NNCHKFS Neural Network Design utility function.

% Check to see if a demo figure is too small because
% of a small screen resolution.
% If it is then shrink figure to small size.
%
% Set to 1 if you want to force figures to be always small.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

Always_Small = 0;
c = computer;
pos = get(gcf,'position');
if strcmp(c(1:2),'PC') | strcmp(c(1:3),'MAC')
  if (pos(3) < 500 | pos(4) < 400) | Always_Small
    nnshrink
  end
end
set(gcf,'visible','on');






