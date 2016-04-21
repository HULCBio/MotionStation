function w = traincold(w,p,tp)
%TRAINCold Train competitive network.
%  
%  This function is obselete.
% This function was called TRAINC in NNT version 2.0.
%  Use NNT2C and TRAIN to update and train your network.

nntobsf('trainc','Use NNT2C and TRAIN to update and train your network.')

%  W = TRAINCOLD(W,P,TP)
%    W  - SxR weight matrix.
%    P  - RxQ matrix of input vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W  - New weights.
%  
%  Training parameters are:
%    TP(1) - Presentations between updating display, default = 25.
%    TP(2) - Number of presentations, default = 100.
%    TP(3) - Learning rate, default = 0.01.
%    TP(4) - Bias time constant (Between 0 and 1), default = 0.999.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  See also NNTRAIN, COMPNET, INITC, SIMUC.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.15 $  $Date: 2002/04/14 21:16:39 $

if nargin < 2, error('Not enough arguments.'); end

% TRAINING PARAMETERS
if nargin == 2, tp = []; end
tp = nndef(tp,[25 100 0.01 0.999]);
df = tp(1);
max_pres = tp(2);
lr = tp(3);
bias_time_const = tp(4);

[r,q] = size(p);
[s,r] = size(w);
inv_bias_time_const = 1 - bias_time_const;
q_ones = ones(q,1);
z = ones(s,1)*(1/s);
b = exp(1 - log(z));

% PLOTTING
newplot;
message = sprintf('TRAINC: %%g/%g epochs.\n',max_pres);
fprintf(message,0)
if r == 1
  W = zeros(s,floor(max_pres/df)+1);
  Wind = 1;
  W(:,Wind) = w;
  if q > 100
  plot(p(ceil([0.01:.01:1])*q),zeros(1,100),'+r')
  else
    plot(p,zeros(1,q),'+r')
  end
  hold on
  h = plot(w,zeros(1,s),'ob');
else
  plot(p(1,:),p(2,:),'+r')
  hold on
  ax = axis;
  h = plot(w(:,1),w(:,2),'ob');
  axis(ax);
end
title('Competitive Learning: 0 cycles')
drawnow

for i=1:max_pres

  % PRESENTATION PHASE
  j = fix(rand*q)+1;
  P = p(:,j);
  a = simuc(P,w,b);

  % LEARNING PHASE
  dw = learnk(w,P,a,lr);
  w = w + dw;
  z = bias_time_const * z + inv_bias_time_const * a;
  b = exp(1 - log(z));

  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i)
    delete(h)
    if r == 1
    Wind = Wind + 1;
    W(:,Wind) = w;
      h = plot(W(:,1:Wind),df*fliplr(0:(Wind-1)),'w',w,w*0,'ow');
      set(gca,'ylim',[0 (Wind-1)*df])
    else
      h = plot(w(:,1),w(:,2),'ob');
      axis(ax);
    end
    title(sprintf('Competitive Learning: %g cycles',i))
    drawnow
  end
end

% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i)
  delete(h)
  if r == 1
    h = plot(W(:,1:Wind),df*fliplr(0:(Wind-1)),'w',w,w*0,'ow');
    set(gca,'ylim',[0 (Wind-1)*df])
  else
    h = plot(w(:,1),w(:,2),'ob');
    axis(ax);
  end
    title(sprintf('Competitive Learning: %g cycles',i))
  drawnow
end

