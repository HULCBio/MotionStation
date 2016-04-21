function [w1,w2] = trainlvq2(w1,w2,p,t,tp)
%TRAINLVQ Train LVQ network.
%  
%  This function is obselete.
%  Use NNT2LVQ and TRAIN to update and train your network.

nntobsf('trainlvq','Use NNT2LVQ and TRAIN to update and train your network.')

%  [W1,W2] = TRAINLVQ(W1,W2,P,T,TP)
%    W1 - S1xR weight matrix for competitive layer.
%    B1 - S1x1 bias vector for competitive layer.
%    W2 - S2xS1 weight matrix for linear layer.
%    P  - RxQ matrix of input vectors.
%    T  - S2xQ matrix of target (single-value) vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W1  - New competitive layer weights.
%    W2  - Unchanged linear layer weights.
%  
%  [W1,B1,W2] = TRAINLVQ(W1,W2,P,C,TP)
%    C - 1xQ vector of target class numbers.
%  Returns weights and biases as above.
%  
%  Training parameters are:
%    TP(1) - Presentations between updating display, default = 25.
%    TP(2) - Maximum number of presentations, default = 100.
%    TP(3) - Learning rate, default = 0.01.
%    TP(4) - Bias time constant, default = 0.99;
%  Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:13:26 $

if nargin < 4, error('Not enough arguments.'); end

% TRAINING PARAMETERS
if nargin == 4, tp = []; end
tp = nndef(tp,[25 100 0.01 0.99]);
df = tp(1);
max_pres = tp(2);
lr = tp(3);
bias_time_constant = tp(4);
inv_bias_time_constant = 1-tp(4);

[r,q] = size(p);
[s,q] = size(t);
[s2,s1] = size(w2);

% BIASES
z1 = ones(s1,1)*(1/s1);
b1 = exp(1-log(z1));

% TARGETS --> INPUT VECTOR CLASSES
if s == 1
  pc = t;
  s = max(pc);
else
  pc = vec2ind(t);
end

% TARGETS -> LAYER 1 TARGETS
t1 = w2'*t;

% WEIGHTS -> NEURON CLASSES
w1c = vec2ind(w2);

q_ones = ones(q,1);

% PLOTTING
newplot;
message = sprintf('TRAINLVQ: %%g/%g epochs.\n',max_pres);
fprintf(message,0)
if q > 100
  ind = floor([0.01:.01:1]*q);
  plotvec(p(:,ind),pc(ind),'+')
else
  plotvec(p,pc,'+')
end
hold on
if r == 1
  W1 = zeros(s1,floor(max_pres/df)+1);
  Wind = 1;
  W1(:,Wind) = w1;
  h = plotvec(w1',w1c,'o');
  alabel('P','Cycles','LVQ: 0 Cycles')
else
  ax = axis;
  h = plotvec(w1',w1c,'o');
  axis(ax);
  alabel('P(1),W1(1)','P(2),W1(2)','LVQ: 0 cycles')
end
drawnow

for i=1:max_pres

  % PRESENTATION PHASE
  j = fix(rand*q)+1;
  P = p(:,j);
  T = t1(:,j);
  n1 = -dist(w1,P);
  a1a = compet(n1,b1);
  a1b = compet(n1 + T*1e5,b1);
  a1 = a1a | a1b;
  
  tind = find(T);
  z1(tind) = z1(tind)*bias_time_constant + a1a(tind)*inv_bias_time_constant;
  b1 = exp(1-log(z1));

  % LEARNING PHASE
  dw = learnlvq(w1,P,a1,T,lr);
  w1 = w1 + dw;

  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i)
    delete(h)
    if (r == 1)
    Wind = Wind + 1;
    W1(:,Wind) = w1;
      h1 = plot(W1(:,1:Wind),df*fliplr(0:(Wind-1)),'w');
    h2 = plotvec(w1',w1c,'o');
    h = [h1 h2'];
      set(gca,'ylim',[0 (Wind-1)*df])
    else
      h = plotvec(w1',w1c,'o');
      axis(ax);
    end
    title(sprintf('LVQ: %g cycles',i))
    drawnow
  end
end

% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i)
  delete(h)
  if r == 1
    plot(W1(:,1:Wind),df*fliplr(0:(Wind-1)),'w');
  plotvec(w1',w1c,'o');
    set(gca,'ylim',[0 (Wind-1)*df])
  else
    h = plotvec(w1',w1c,'o');
    axis(ax);
  end
  title(sprintf('LVQ: %g cycles',i))
  drawnow
end
