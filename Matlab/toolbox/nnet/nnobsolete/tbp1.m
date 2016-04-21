function [w1,b1,i,tr] = tbp1(w1,b1,f1,p,t,tp,wv,bv,es,v)
%TBP1 Train 1-layer feed-forward network w/backpropagation.
%          
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('tbp1','Use NNT2FF and TRAIN to update and train your network.')

%  [W,B,TE,TR] = TBP1(W,B,F,P,T,TP)
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
%  Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 5,error('Not enough arguments.'),end

% TRAINING PARAMETERS
if nargin == 5, tp = []; end
tp = nndef(tp,[25 1000 0.02 0.01]);
df = tp(1);
me = tp(2);
eg = tp(3);
lr = tp(4);
df1 = feval(f1,'delta');

% PRESENTATION PHASE
a1 = feval(f1,w1*p,b1);
e = t-a1;
SSE = sumsqr(e);

% TRAINING RECORD
tr = zeros(1,me+1);
tr(1) = SSE;

% PLOTTING FLAG
[r,q] = size(p);
[s,q] = size(t);
plottype = (nargin >= 8) + (max(r,s) == 1);

% PLOTTING
newplot;
message = sprintf('TRAINBP: %%g/%g epochs, SSE = %%g.\n',me);
fprintf(message,0,SSE)
if plottype == 1
  h = plotfa(p,t,p,a1);
elseif plottype == 2
  if nargin <= 8, es = errsurf(p,t,wv,bv,f1); end
  if nargin <= 9, v = [-37.5 30]; end
  plotes(wv,bv,es,v);
  h = plotep(w1,b1,SSE);
else
  h = ploterr(tr(1),eg);
end

% TRAINING

for i=1:me

  % CHECK PHASE
  if SSE < eg, i = i - 1; break, end

  % BACKPROPAGATION PHASE
  d1 = feval(df1,a1,e);

  % LEARNING PHASE
  [dw1,db1] = learnbp(p,d1,lr);
  w1 = w1 + dw1; b1 = b1 + db1;

  % PRESENTATION PHASE
  a1 = feval(f1,w1*p,b1);
  e = t-a1;
  SSE = sumsqr(e);

  % TRAINING RECORD
  tr(i+1) = SSE;

  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i,SSE)
    if plottype == 1
      delete(h);
      h = plot(p,a1);
    elseif plottype == 2
      h = plotep(w1,b1,SSE,h);
    else
      h = ploterr(tr(1:(i+1)),eg,h);
    end
  end
end

% TRAINING RECORD
tr = tr(1:(i+1));

% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i,SSE)
  if plottype == 1
    delete(h);
    plot(p,a1);
  elseif plottype == 2
    plotep(w1,b1,SSE,h);
  else
    ploterr(tr,eg,h);
  end
end

% WARNINGS
if SSE > eg
  disp(' ')
  disp('TRAINBP: Network error did not reach the error goal.')
  disp('  Further training may be necessary, or try different')
  disp('  initial weights and biases.')
  disp(' ')
end
