function [w1,b1,w2,b2,w3,b3,i,tr] = tbp3(w1,b1,f1,w2,b2,f2,w3,b3,f3,p,t,tp)
%TBP3 Train 3-layer feed-forward network w/backpropagation.
%          
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('tbp3','Use NNT2FF and TRAIN to update and train your network.')

%  [W1,B1,W2,B2,W3,B3,TE,TR] = TBP3(W1,B1,F1,W2,B2,F2,W3,B3,F3,P,T,TP)
%    Wi - SixR weight matrix of ith layer.
%    Bi - Six1 bias vector of ith layer.
%    F  - Transfer function (string) of ith layer.
%    P  - RxQ matrix of input vectors.
%    T  - S2xQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns:
%    Wi - new weights.
%    Bi - new biases.
%    TE - the actual number of epochs trained.
%    TR - training record: [row of errors]
%  
%  Training parameters are:
%    TP(1) - Epochs between updating display, default = 25.
%    TP(2) - Maximum number of epochs to train, default = 1000.
%    TP(3) - Sum-squared error goal, default = 0.02.
%    TP(4) - Learning rate, 0.01.
%  Missing parameters and NaN's are replaced with defaults.

%  Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.15 $

if nargin < 11,error('Not enough arguments.'),end

% TRAINING PARAMETERS
if nargin == 10, tp = []; end
tp = nndef(tp,[25 1000 0.02 0.01]);
df = tp(1);
me = tp(2);
eg = tp(3);
lr = tp(4);
df1 = feval(f1,'delta');
df2 = feval(f2,'delta');
df3 = feval(f3,'delta');

% PRESENTATION PHASE
a1 = feval(f1,w1*p,b1);
a2 = feval(f2,w2*a1,b2);
a3 = feval(f3,w3*a2,b3);
e = t-a3;
SSE = sumsqr(e);
tr = zeros(1,me);
tr(1) = SSE;

% PLOTTING FLAG
[r,q] = size(p);
[s3,q] = size(t);
plottype = max(r,s3) == 1;

% PLOTTING
newplot;
message = sprintf('TRAINBP: %%g/%g epochs, SSE = %%g.\n',me);
fprintf(message,0,SSE)
if plottype
  h = plotfa(p,t,p,a3);
else
  h = ploterr(tr(1),eg);
end

for i=1:me

  % CHECK PHASE
  if SSE < eg, i=i-1; break, end

  % BACKPROPAGATION PHASE
  d3 = feval(df3,a3,e);
  d2 = feval(df2,a2,d3,w3);
  d1 = feval(df1,a1,d2,w2);

  % LEARNING PHASE
  [dw1,db1] = learnbp(p,d1,lr);
  [dw2,db2] = learnbp(a1,d2,lr);
  [dw3,db3] = learnbp(a2,d3,lr);
  w1 = w1 + dw1; b1 = b1 + db1;
  w2 = w2 + dw2; b2 = b2 + db2;
  w3 = w3 + dw3; b3 = b3 + db3;

  % PRESENTATION PHASE
  a1 = feval(f1,w1*p,b1);
  a2 = feval(f2,w2*a1,b2);
  a3 = feval(f3,w3*a2,b3);
  e = t-a3;
  SSE = sumsqr(e);

  % TRAINING RECORD
  tr(i+1) = SSE;

  % PLOTTING
  if rem(i,df) == 0
  fprintf(message,i,SSE)
    if plottype
      delete(h);
      h = plot(p,a3);
      drawnow;
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
  if plottype
    delete(h);
    plot(p,a3);
    drawnow;
  else
    ploterr(tr,eg,h);
  end
end

% WARNINGS
if SSE > eg
  disp(' ')
  disp('TRAINBP: Network error did not reach the error goal.')
  disp('  Further training may be necessary, or try different')
  disp('  initial weights and biases and/or more hidden neurons.')
  disp(' ')
end

