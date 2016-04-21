function [w,b,te,tr] = trainwh(w,b,p,t,tp,wv,bv,es)
%TRAINWH Train linear layer with Widrow-Hoff rule.
%  
%  This function is obselete.
%  Use NNT2LIN and TRAIN to update and train your network.

nntobsf('trainwh','Use NNT2LIN and TRAIN to update and train your network.')

%  [W,B,TE,TR] = TRAINWH(W,B,P,T,TP)
%    W  - SxR weight matrix.
%    B  - Sx1 bias vector.
%    P  - RxQ matrix of input vectors.
%    T  - SxQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W  - new weight matrix
%    B  - new weights & biases.
%    TE - the actual number of epochs trained.
%    TR - training record: [row of errors]
%  
%  Training parameters are:
%    TP(1) - Epochs between updating display, default = 25.
%    TP(2) - Maximum number of epochs to train, default = 100.
%    TP(3) - Sum-squared error goal, default = 0.02.
%    TP(4) - Learning rate, default found with MAXLINLR.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  [W,B,TE,TR] = TRAINWH(W,B,P,T,TP,WV,BV,ES)
%    WV - Row vector of weight values.
%    BV - Row vector of bias values.
%    ES - Precomputed matrix of errors (optional).
%  If a single 1-input neuron is being trained, the display
%    shows the error surface for given weight and bias values
%    instead of the error curve.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 4,error('Not enough arguments.'),end

% TRAINING PARAMETERS
if nargin == 4, tp = []; end
tp = nndef(tp,[100 100 0.02 NaN]);
df = tp(1);
me = tp(2);
eg = tp(3);
if finite(tp(4))
  lr = tp(4);
else
  lr = maxlinlr(p,'biases');
end

% PLOTTING FLAG
[r,q] = size(p);
[s,q] = size(t);
plottype = (nargin >= 7) & (max(r,s) == 1);

% PRESENTATION PHASE
a = purelin(w*p,b);
e = t-a;
SSE = sumsqr(e);
tr = zeros(1,me+1);
tr(1) = SSE;

% PLOTTING
newplot;
message = sprintf('TRAINWH: %%g/%g epochs, SSE = %%g.\n',me);
fprintf(message,0,SSE)
if plottype
  if nargin == 7
    es = errsurf(p,t,wv,bv,'purelin');
  end
  plotes(wv,bv,es);
  h = plotep(w,b,SSE);
else
  h = ploterr(tr(1),eg);
end

for i=1:me

  % CHECK PHASE
  if SSE < eg, i=i-1; break, end

  % LEARNING PHASE
  [dw,db] = learnwh(p,e,lr);
  w = w + dw; b = b + db;

  % PRESENTATION PHASE
  a = purelin(w*p,b);
  e = t-a;
  SSE = sumsqr(e);
  tr(i+1) = SSE;

  % DISPLAY RESULTS
  if rem(i,df) == 0
    fprintf(message,i,SSE)
    if plottype
      h = plotep(w,b,SSE,h);
    else
      h = ploterr(tr(1:i),eg,h);
    end
  end
end

% RESULTS
te = i;
tr = tr(1:(te+1));

% PLOTS
if rem(i,df) ~= 0
  fprintf(message,i,SSE)
  if plottype
    plotep(w,b,SSE,h);
  else
    ploterr(tr,eg,h);
  end
end

% WARNINGS
if SSE > eg
  disp(' ')
  disp('TRAINWH: Network error did not reach error goal.')
  disp('  Such a solution may not exist or more training')
  disp('  may be required.')
  disp(' ')
end
