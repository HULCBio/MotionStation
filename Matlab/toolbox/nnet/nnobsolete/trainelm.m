function [w1,b1,w2,b2,te,tr] = trainelm(w1,b1,w2,b2,p,t,tp)
%TRAINELM Train Elman recurrent network.
%  
%  This function is obselete.
%  Use NNT2ELM and TRAIN to update and train your network.

nntobsf('trainelm','Use NNT2ELM and TRAIN to update and train your network.')

%  [W1,B1,W2,B2,TE,TR] = TRAINELM(W1,B1,W2,B2,P,T,TP)
%    W1 - Weight matrix for first layer (from input & feedback).
%    B1 - Bias (column) vector for first layer.
%    W2 - Weight matrix for second layer (from first layer).
%    B2 - Bias (column) vector for second layer.
%    P  - Input (column) vectors arranged in time.
%    T  - Target (column) vectors arranged in time.
%    TP - Vector of training parameters (optional).
%  Returns:
%    W1,B1,W2,B2 - New weights and biases.
%    TE - Number of epochs trained.
%    TR - Record of errors throughout training.
%  
%  Training parameters are:
%    TP(1) - Number of epochs between display (default = 5).
%    TP(2) - Maximum number of epochs to train (default = 500).
%    TP(3) - Sum squared error goal (default = 0.01).
%    TP(4) - Initial adaptive learning rate (default = 0.001).
%    TP(5) - Ratio to increase learning rate (default = 1.05).
%    TP(6) - Ratio to decrease learning rate (default = 0.7).
%    TP(7) - Momentum constant (default = 0.95).
%    TP(8) - Error ratio (default = 1.04).
%  Missing parameters and NaN's are replaced with defaults.
%  
%  See also NNTRAIN, ELMAN, INITELM, SIMUELM.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 6,error('Wrong number of arguments.'),end

% TRAINING PARAMETERS
% ===================

if nargin == 6, tp = []; end
tp = nndef(tp,[5 500 0.01 0.001 1.05 0.5 0.95 1.04]);
df = tp(1);
me = tp(2);
eg = tp(3);
lr = tp(4);
lr_inc = tp(5);
lr_dec = tp(6);
mc = tp(7);
er = tp(8);

% INITIALIZE MATRIX SIZES
% =======================

[r,q] = size(p);
s1 = length(b1);
s2 = length(b2);

a1 = zeros(s1,q);
a2 = zeros(s2,q);

dw1 = w1*0; db1 = b1*0;
dw2 = w2*0; db2 = b2*0;

tr = zeros(1,me+1);

% SIMULATE NETWORK FOR Q TIMESTEPS

init_a1 = zeros(s1,1);
[a1,a2] = simuelm(p,w1,b1,w2,b2,init_a1);

% CALCULATE ERRORS

e = t - a2;
SSE = sumsqr(e);
tr(1) = SSE;

% CALCULATE DERIVATIVES

d2 = deltalin(a2,e);
d1 = deltatan(a1,d2,w2);

% PLOTTING
clf
h = ploterr(tr(1),eg);
message = sprintf('TRAINELM: %%g/%g epochs, lr = %%g, SSE = %%g.\n',me);
fprintf(message,0,lr,SSE)

% INITIALIZE MOMENTUM & TRAIN

current_mc = 0;
for i=1:me

  % ERROR CHECK
  
  if SSE < eg, i=i-1; break, end

  % CALCULATE WEIGHT CHANGES
  [dw1,db1] = learnbpm([p; init_a1 a1(:,1:(q-1))],d1,lr,current_mc,dw1,db1);
  [dw2,db2] = learnbpm(a1,d2,lr,current_mc,dw2,db2);
  current_mc = mc;

  % CALCULATE NEW WEIGHTS

  new_w1 = w1 + dw1; new_b1 = b1 + db1;
  new_w2 = w2 + dw2; new_b2 = b2 + db2;

  % SIMULATE NEW NETWORK FOR Q TIMESTEPS

  [new_a1,new_a2] = simuelm(p,new_w1,new_b1,new_w2,new_b2,init_a1);

  % CALCULATE ERRORS

  new_e = t - new_a2;
  new_SSE = sumsqr(new_e);

  % MOMENTUM & ADAPTIVE LEARNING RATE

  if new_SSE > SSE*er
    lr = lr * lr_dec;
    current_mc = 0;
  else
    if new_SSE < SSE, lr = lr * lr_inc; end

    % ACCEPT NEW NETWORK

    w1 = new_w1; b1 = new_b1; w2 = new_w2; b2 = new_b2;
    a1 = new_a1; a2 = new_a2; e = new_e; SSE = new_SSE;

    % CALCULATE NEW DERIVATIVES

    d2 = deltalin(a2,e);
    d1 = deltatan(a1,d2,w2);
  end
  
  % PLOTTING
  tr(i+1) = SSE;
  if rem(i,df) == 0
    fprintf(message,i,lr,SSE)
    delete(h);
    h = ploterr(tr(1:i+1),eg);
  end
end

% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i,lr,SSE)
  ploterr(tr(1:i+1),eg);
end

% TRAINING RECORD
te = i;
tr = tr(1:(i+1));

% WARNINGS
if SSE > eg
  disp(' ')
  disp('TRAINELM: Network error did not reach the error goal.')
  disp('  Further training may be necessary, or try different')
  disp('  initial weights and biases and/or more hidden neurons.')
  disp(' ')
end

