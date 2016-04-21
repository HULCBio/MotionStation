function h2=ploterr(e,g,h)
%PLOTERR Plot network sum-squared error vs epochs.
%
%  This function is obselete.

nntobsf('barerr','Use BAR to make bar plots.')

%  PLOTERR(E,G)
%    E - Row vector of error values.
%    G - Error goal.
%  Returns (optionally) handle to error curve in plot.
%  
%  PLOTERR(E,G,H)
%    H - Handle returned by previous call to PLOTERR.
%  Deletes old error curve H, and plots new one.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 1,error('Not enough arguments'), end

epochs = length(e)-1;
t = sprintf('Sum-Squared Network Error for %g Epochs',epochs);

% BACKWARD COMPATIBILITY FOR NNT 1.0
% Convert PLOTERR(E,T) -> PLOTERR(E)
nargin2  = nargin;
if nargin2 == 2
  if isstr(g)
    t = g;
  nargin2 = 1;
  end
end

if nargin2 < 3
  newplot;
  delete(get(gca,'children'))
  if nargin2 == 2
    plot([0 999999],[g g],'r:',0,g*0.9,'.b')
  end
  xlabel('Epoch')
  ylabel('Sum-Squared Error')
  title(t)
  set(gca,'box','on')
else
  delete(h);
end

hold on
e = e + eps;
H = plot(0:epochs,e);
title(t)
hold off

set(gca,'xlim',[0 epochs+eps]);
set(gca,'ylim',[0 1]);
set(gca,'ylimmode','auto')
set(gca,'yscale','log');
drawnow

if nargout == 1
  h2 = H;
end
