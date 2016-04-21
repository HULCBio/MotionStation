function [w,b,te,tr] = trainp(w,b,p,t,tp)
%TRAINP Train perceptron layer with perceptron rule.
%  
%  This function is obselete.
%  Use NNT2P and TRAIN to update and train your network.

nntobsf('trainp','Use NNT2P and TRAIN to update and train your network.')

%  [W,B,TE,TR] = TRAINP(W,B,P,T,ME)
%    W  - SxR weight matrix.
%    B  - Sx1 bias vector.
%    P  - RxQ matrix of input vectors.
%    T  - SxQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W  - New weight matrix.
%    B  - New bias vector.
%    TE - Trained epochs.
%    TR - Training record: errors in row vector.
%  
%  Training parameters are:
%    TP(1) - Epochs between updating display, default = 1.
%    TP(2) - Maximum number of epochs to train, default = 100.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  If TP(1) is negative, and a 1-input neuron is being trained
%    the input vectors and classification line are plotted
%    instead of the network error.
%  
%  See also NNTRAIN, PERCEPT, HARDLIM, INITP, LEARNP, SIMP.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 21:13:29 $

if nargin < 4, error('Not enough arguments.'), end

% TRAINING PARAMETERS
if nargin == 4
  tp = [1 100];
else
  tp = nndef(tp,[1 100]);
end
df = tp(1);
me = tp(2);

% PLOTTING FLAG
[r,q] = size(p);
[s,q] = size(t);
plottype = (df < 0) & (max(r,s) <= 3);
df = abs(df);

% PRESENTATION PHASE
a = hardlim(w*p,b);
e = t-a;
SSE = sum(sum(abs(e)));
tr = zeros(1,me+1);
tr(1) = SSE;

% PLOTTING
newplot;
message = sprintf('TRAINP: %%g/%g epochs, SSE = %%g.\n',me);
fprintf(message,0,SSE)
if plottype
  plotpv(p,t)
  h = plotpc(w,b);
else
  h = ploterr(tr(1),0);
end

for i=1:me

  % CHECK PHASE
  if SSE == 0, i=i-1; break, end

  % LEARNING PHASE
  [dw,db] = learnp(p,e);
  w = w + dw;
  b = b + db;

  % PRESENTATION PHASE
  a = hardlim(w*p,b);
  e = t-a;
  SSE = sum(sum(abs(e)));
  tr(i+1) = SSE;
  
  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i,SSE)
    if plottype
      h = plotpc(w,b,h);
    else
      h = ploterr(tr(1:(i+1)),0,h);
    end
  end
end

% RESULTS
te = i;
tr = tr(1:(i+1));

% PLOTS
if rem(i,df) ~= 0
  fprintf(message,i,SSE)
  if plottype
    plotpc(w,b,h);
  else
    ploterr(tr,0,h);
  end
end

% WARNINGS
if SSE > 0
  disp(' ')
  disp('TRAINP: Network error did not reach 0.')
  disp('  The problem may not be linearly separable or')
  disp('  more training may be required.')
  disp(' ')
end
