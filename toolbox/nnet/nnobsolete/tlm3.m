function [w1,b1,w2,b2,w3,b3,i,tr] = tlm3(w1,b1,f1,w2,b2,f2,w3,b3,f3,p,t,tp)
%TLM3 Train 3-layer feed-forward network w/Levenberg-Marquardt.
%
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('tlm3','Use NNT2FF and TRAIN to update and train your network.')

%       [W1,B1,W2,B2,W3,B3,TE,TR] = TLM3(W1,B1,F1,W2,B2,F2,W3,B3,F3,P,T)
%         Wi - Weight matrix of ith layer.
%         Bi - Bias vector of ith layer.
%         F  - Transfer function (string) of ith layer.
%         P  - RxQ matrix of input vectors.
%         T  - S2xQ matrix of target vectors.
%         TP - Training parameters (optional).
%       Returns:
%         Wi - new weights.
%         Bi - new biases.
%         TE - the actual number of epochs trained.
%         TR - training record: [row of errors]
%
%       Training parameters are:
%         TP(1) - Epochs between updating display, default = 25.
%         TP(2) - Maximum number of epochs to train, default = 1000.
%         TP(3) - Sum-squared error goal, default = 0.02.
%         TP(4) - Minimum gradient, default = 0.0001.
%         TP(5) - Initial value for MU, default = 0.001.
%         TP(6) - Multiplier for increasing MU, default = 10.
%         TP(7) - Multiplier for decreasing MU, default = 0.1.
%         TP(8) - Maximum value for MU, default = 1e10.
%       Missing parameters and NaN's are replaced with defaults.
 
% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:13:08 $
 
if nargin < 11,error('Not enough arguments.'),end
 
% TRAINING PARAMETERS
if nargin == 11, tp = []; end
tp = nndef(tp,[25 1000 0.02 0.0001 0.001 10 0.1 1e10]);
df = tp(1);
me = tp(2);
eg = tp(3);
grad_min = tp(4);
mu_init = tp(5);
mu_inc = tp(6);
mu_dec = tp(7);
mu_max = tp(8);
df1 = feval(f1,'delta');
df2 = feval(f2,'delta');
df3 = feval(f3,'delta');
 
% DEFINE SIZES
[s1,r] = size(w1);
[s2,s1] = size(w2);
[s3,s2] = size(w3);
w1_ind = [1:(s1*r)];
b1_ind = [1:s1] + w1_ind(length(w1_ind));
w2_ind = [1:(s1*s2)] + b1_ind(length(b1_ind));
b2_ind = [1:s2] + w2_ind(length(w2_ind));
w3_ind = [1:(s2*s3)] + b2_ind(length(b2_ind));
b3_ind = [1:s3] + w3_ind(length(w3_ind));
ii = eye(b3_ind(length(b3_ind)));
dw1 = w1; db1 = b1;
dw2 = w2; db2 = b2;
dw3 = w3; db3 = b3;
ext_p = nncpyi(p,s3);
 
% PRESENTATION PHASE
[a1,a2,a3] = simuff(p,w1,b1,f1,w2,b2,f2,w3,b3,f3);
e = t-a3;
SSE = sumsqr(e);
 
% TRAINING RECORD
tr = zeros(1,me+1);
tr(1) = SSE;
 
% PLOTTING FLAG
plottype = (r==1) & (s2==1);
 
% PLOTTING
newplot;
message = sprintf('TRAINLM: %%g/%g epochs, mu = %%g, SSE = %%g.\n',me);
fprintf(message,0,mu_init,SSE)
if plottype
  h = plotfa(p,t,p,a3);
else
  h = ploterr(tr(1),eg);
end
 
mu = mu_init;
for i=1:me
 
  % CHECK PHASE
  if SSE < eg, i=i-1; break, end
 
  % FIND JACOBIAN
  ext_a1 = nncpyi(a1,s3);
  ext_a2 = nncpyi(a2,s3);
  d3 = feval(df3,a3);
  ext_d3 = -nncpyd(d3);
  ext_d2 = feval(df2,ext_a2,ext_d3,w3);
  ext_d1 = feval(df1,ext_a1,ext_d2,w2);
  j1 = learnlm(ext_p,ext_d1);
  j2 = learnlm(ext_a1,ext_d2);
  j3 = learnlm(ext_a2,ext_d3);
 
                j = [j1, ext_d1', j2, ext_d2', j3, ext_d3'];
 
  % CHECK MAGNITUDE OF GRADIENT
  je = j' * e(:);
  grad = norm(je);
  if grad < grad_min, i=i-1; break, end
 
  % INNER LOOP, INCREASE MU UNTIL THE ERRORS ARE REDUCED
  jj = j'*j;
 
  while (mu <= mu_max)
    dx = -(jj+ii*mu) \ je;
    dw1(:) = dx(w1_ind); db1 = dx(b1_ind);
    dw2(:) = dx(w2_ind); db2 = dx(b2_ind);
    dw3(:) = dx(w3_ind); db3 = dx(b3_ind);
    new_w1 = w1 + dw1; new_b1 = b1 + db1;
    new_w2 = w2 + dw2; new_b2 = b2 + db2;
    new_w3 = w3 + dw3; new_b3 = b3 + db3;
 
    % EVALUATE NEW NETWORK
    [a1,a2,a3] = ...
       simuff(p,new_w1,new_b1,f1,new_w2,new_b2,f2,new_w3,new_b3,f3);
    new_e = t-a3;
    new_SSE = sumsqr(new_e);
 
    if (new_SSE < SSE), break, end
    mu = mu * mu_inc;
  end
  if (mu > mu_max), i = i-1; break, end
  mu = mu * mu_dec;
 
  % UPDATE NETWORK
                w1 = new_w1; b1 = new_b1;
  w2 = new_w2; b2 = new_b2;
  w3 = new_w3; b3 = new_b3;
  e = new_e; SSE = new_SSE;
 
  % TRAINING RECORD
  tr(i+1) = SSE;
 
  % PLOTTING
  if rem(i,df) == 0
    fprintf(message,i,mu,SSE)
    if plottype
      delete(h); h = plot(p,a2,'m'); drawnow;
    else
      h = ploterr(tr(1:(i+1)),eg,h);
    end
  end
end
 
% TRAINING RECORD
tr = tr(1:(i+1));
 
% PLOTTING
if rem(i,df) ~= 0
  fprintf(message,i,mu,SSE)
  if plottype
    delete(h);
    plot(p,a2,'m');
    drawnow;
  else
    ploterr(tr,eg,h);
  end
end
 
% WARNINGS
if SSE > eg
  disp(' ')
  if (mu > mu_max)
    disp('TRAINLM: Error gradient is too small to continue learning.')
  else
    disp('TRAINLM: Network error did not reach the error goal.')
  end
  disp('  Further training may be necessary, or try different')
  disp('  initial weights and biases and/or more hidden neurons.')
  disp(' ')
end
