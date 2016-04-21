function [w1,b1,w2,b2,k,tr] = solverb(p,t,tp)
%SOLVERB Design radial basis network.
%  
%  This function is obselete.
%  Use NEWRB to design your network.

nntobsf('solverb','Use NEWRB to design your network.')

%  [W1,B1,W2,B2,TE,TR] = SOLVERB(P,T,DP)
%    P - RxQ matrix of Q input vectors.
%    T - SxQ matrix of Q target vectors.
%    DP - Design parameters (optional).
%  Returns:
%    W1 - S1xR weight matrix for radial basis layer.
%    B1 - S1x1 bias vector for radial basis layer.
%    W2 - S2xS1 weight matrix for linear layer.
%    B2 - S2x1 bias vector for linear layer.
%    NR - the number of radial basis neurons used.
%    TR - training record: [row of errors]
%  
%  Design parameters are:
%    DP(1) - Iterations between updating display, default = 25.
%    DP(2) - Maximum number of neurons, default = # vectors in P.
%    DP(3) - Sum-squared error goal, default = 0.02.
%    DP(4) - Spread of radial basis functions, default = 1.0.
%  Missing parameters and NaN's are replaced with defaults.
%  
%  See also NNSOLVE, RADBASIS, SIMRB, SOLVERB.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 2, error('Not enough input arguments'),end

% TRAINING PARAMETERS
if nargin == 2, tp = []; end
[r,q] = size(p);
tp = nndef(tp,[25 q 0.02 1]);
df = tp(1);
eg = tp(3);
b = sqrt(-log(.5))/tp(4);
[s2,q] = size(t);
mn = min(q,tp(2));

% PLOTTING FLAG
plottype = max(r,s2) == 1;

% RADIAL BASIS LAYER OUTPUTS
P = radbas(dist(p',p)*b);
PP = sum(P.*P)';
d = t';
dd = sum(d.*d)';

% CALCULATE "ERRORS" ASSOCIATED WITH VECTORS
e = ((P' * d)' .^ 2) ./ (dd * PP');

% PICK VECTOR WITH MOST "ERROR"
pick = nnfmc(e);
used = [];
left = 1:q;
W = P(:,pick);
P(:,pick) = []; PP(pick,:) = [];
e(:,pick) = [];
used = [used left(pick)];
left(pick) = [];

% CALCULATE ACTUAL ERROR
w1 = p(:,used)';
a1 = radbas(dist(w1,p)*b);
[w2,b2] = solvelin(a1,t);
a2 = purelin(w2*a1,b2);
sse = sumsqr(t-a2);

% TRAINING RECORD
tr = zeros(1,mn);
tr(1) = sse;

% PLOTTING
newplot;
if plottype
  h = plotfa(p,t,p,a2);
else
  h = ploterr(tr(1),eg);
end

for k = 1:(mn-1)
 
  % CHECK ERROR
  if (sse < eg), break, end

  % CALCULATE "ERRORS" ASSOCIATED WITH VECTORS

  wj = W(:,k);

  %---- VECTOR CALCULATION

  a = wj' * P / (wj'*wj);
  P = P - wj * a;
  PP = sum(P.*P)';
%if any(any(PP == 0))
%  disp('PP has a 0')
%  keyboard
%end
  e = ((P' * d)' .^ 2) ./ (dd * PP');

  % PICK VECTOR WITH MOST "ERROR"
  pick = nnfmc(e);
  W = [W, P(:,pick)];
  P(:,pick) = []; PP(pick,:) = [];
  e(:,pick) = [];
  used = [used left(pick)];
  left(pick) = [];

  % CALCULATE ACTUAL ERROR
  w1 = p(:,used)';
  a1 = radbas(dist(w1,p)*b);
  [w2,b2] = solvelin(a1,t);
  a2 = purelin(w2*a1,b2);
  sse = sumsqr(t-a2);

  % TRAINING RECORD
  tr(k+1) = sse;

  % PLOTTING
  if rem(k,df) == 0
    if plottype
      delete(h);
      h = plot(p,a2,'m');
      drawnow;
    else
      h = ploterr(tr(1:(k+1)),eg,h);
    end
  end
end

[S1,R] = size(w1);
b1 = ones(S1,1)*b;

% TRAINING RECORD
tr = tr(1:(k+1));

% PLOTTING
if rem(k,df) ~= 0
  if plottype
    delete(h);
    plot(p,a2,'m');
    drawnow;
  else
    ploterr(tr,eg,h);
  end
end

% WARNINGS
if sse > eg
  disp(' ')
  disp('SOLVERB: Network error did not reach the error goal.')
  disp('  More neurons may be necessary, or try using a')
  disp('  wider or narrower spread constant.')
  disp(' ')
end
