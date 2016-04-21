function [w,b,te,tr] = trainpn(w,b,p,t,tp)
%TRAINPN Train perceptron with normalized perceptron rule.
%  
%  This function is obselete.
%  Use NNT2P and TRAIN to update and train your network.

nntobsf('trainpn','Use NNT2P and TRAIN to update and train your network.')

%  [W,B,TE,TR] = TRAINPN(W,B,P,T,ME)
%    W  - SxR weight matrix.
%    B  - Sx1 bias vector.
%    P  - RxQ matrix of input vectors.
%    T  - SxQ matrix of target vectors.
%    TP - Training parameters (optional).
%  Returns:
%    W  - a new weight matrix.
%    B  - a new bias vector.
%    TE - Trained epochs.
%    TR - Training record: errors in row vector.
%  
%  The training parameters are:
%    TP(1) = Epochs between updating display, default = 1.
%    TP(2) = Maximum number of epochs to train, default = 100.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  TRAINPN is more efficient than TRAINP when there
%    is large variance in the size of input vectors.
%  
%  See also NNTRAIN, PERCEPT, HARDLIM, INITP, SIMP, LEARNPN.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.13 $ $Date: 2002/04/14 21:13:32 $

% ERROR CHECKING
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
plottype = max(r,s) <= 3;

% PRESENTATION PHASE
a = hardlim(w*p,b);
e = t-a;
tr = zeros(1,me+1);
SSE = sum(sum(abs(e)));
tr(1) = SSE;

% PLOTTING
newplot;
message = sprintf('TRAINPN: %%g/%g epochs, SSE = %%g.\n',me);
fprintf(message,0,SSE)
if plottype
  plotpv(p,t)
  h = plotpc(w,b);
else
  h = ploterr(tr(1));
end

for i=1:me

  % CHECK PHASE
  if SSE == 0, i=i-1; break, end

  % LEARNING PHASE
  [dw,db] = learnpn(p,e);
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
      h = ploterr(tr(1:(i+1)),h);
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
    plotpc(w,b,h);
  else
    ploterr(tr,h);
  end
end

% WARNINGS
if SSE > 0
  disp(' ')
  disp('TRAINPN: Network error did not reach 0.')
  disp('  The problem may not be linearly separable or')
  disp('  more training may be required.')
  disp(' ')
end


