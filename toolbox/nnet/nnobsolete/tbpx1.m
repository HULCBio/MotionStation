function [w1,b1,i,tr] = tbpx1(w1,b1,f1,p,t,tp)
%TBPX1 Train 1-layer network w/fast backpropagation.
%  
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('tbpx1','Use NNT2FF and TRAIN to update and train your network.')

%  [W,B,TE,TR] = TBPX1(W,B,F,P,T,TP)
%    W  - SxR weight matrix.
%    B  - Sx1 bias vector.
%    F  - Transfer function (string).
%    P  - RxQ matrix of input vectors.
%    T  - SxQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W  - new weights.
%    B  - new biases.
%    TE - the actual number of epochs trained.
%    TR - training record: [row of errors]
%  
%  Training parameters are:
%    TP(1) - Epochs between updating display, default = 25.
%    TP(2) - Maximum number of epochs to train, default = 1000.
%    TP(3) - Sum-squared error goal, default = 0.02.
%    TP(4) - Learning rate, 0.01.
%    TP(5) - Learning rate increase, default = 1.05.
%    TP(6) - Learning rate decrease, default = 0.7.
%    TP(7) - Momentum constant, default = 0.9.
%    TP(8) - Maximum error ratio, default = 1.04.
%  Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 5,error('Not enough arguments.');end

% TRAINING PARAMETERS
if nargin == 5, tp = []; end
tp = nndef(tp,[25 1000 0.02 0.01 1.05 0.7 0.9 1.04]);
df = tp(1);
me = tp(2);
eg = tp(3);
lr = tp(4);
im = tp(5);
dm = tp(6);
mc = tp(7);
er = tp(8);
df1 = feval(f1,'delta');

dw1 = w1*0;
db1 = b1*0;
MC = 0;

% PRESENTATION PHASE
a1 = feval(f1,w1*p,b1);
e = t-a1;
SSE = sumsqr(e);

% TRAINING RECORD
tr = zeros(2,me+1);
tr(1:2,1) = [SSE; lr];

% PLOTTING FLAG
[r,q] = size(p);
[s1,q] = size(t);
plottype = (max(r,s1) == 1) & 0;

% PLOTTING
newplot;
message = sprintf('TRAINBPX: %%g/%g epochs, lr = %%g, SSE = %%g.\n',me);
fprintf(message,0,lr,SSE)
if plottype
  h = plotfa(p,t,p,a1);
else
  h = plottr(tr(1:2,1),eg);
end

% BACKPROPAGATION PHASE
d1 = feval(df1,a1,e);

for i=1:me

  % CHECK PHASE
  if SSE < eg, i=i-1; break, end

  % LEARNING PHASE
  [dw1,db1] = learnbpm(p,d1,lr,MC,dw1,db1);  
  MC = mc;
  new_w1 = w1 + dw1; new_b1 = b1 + db1;

  % PRESENTATION PHASE
  new_a1 = feval(f1,new_w1*p,new_b1);
  new_e = t-new_a1;
  new_SSE = sumsqr(new_e);

  % MOMENTUM & ADAPTIVE LEARNING RATE PHASE
  if new_SSE > SSE*er
    lr = lr * dm;
    MC = 0;
  else
    if new_SSE < SSE
      lr = lr * im;
      end
    w1 = new_w1; b1 = new_b1; a1 = new_a1;
    e = new_e; SSE = new_SSE;

    % BACKPROPAGATION PHASE
    d1 = feval(df1,a1,e);
  end

  % TRAINING RECORD
  tr(:,i+1) = [SSE; lr];

  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i,lr,SSE)
    if plottype
      delete(h);
      h = plot(p,a1);
    else
      h = plottr(tr(1:2,1:(i+1)),eg,h);
    end
  end
end

% TRAINING RECORD
tr = tr(1:2,1:(i+1));

% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i,lr,SSE)
  if plottype
    delete(h);
    plot(p,a1);
  else
    plottr(tr,eg,h);
  end
end

% WARNINGS
if SSE > eg
  disp(' ')
  disp('TRAINBPX: Network error did not reach the error goal.')
  disp('  Further training may be necessary, or try different')
  disp('  initial weights and biases and/or more layers.')
  disp(' ')
end

