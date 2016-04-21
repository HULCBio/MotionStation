function w = trainsm(w,m,p,tp)
%TRAINSM Train self-organizing map with Kohonen rule.
%  
%  This function is obselete.
%  Use NNT2SOM and TRAIN to update and train your network.

nntobsf('trainsm','Use NNT2SOM and TRAIN to update and train your network.')

%  TRAINSM(W,M,P,TP)
%    W  - SxR weight matrix.
%    M  - Neighborhood matrix.
%    P  - RxQ matrix of input vectors.
%    TP - Training parameters (optional).
%  Returns new weights.
%  
%  Training parameters are:
%    TP(1) - Presentations between updating display, default = 25.
%    TP(2) - Number of presentations, default = 100.
%    TP(3) - Initial learning rate, default = 1.
%  Missing parameters and NaN's are replaced with defaults.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:13:35 $

if nargin < 3, error('Not enough arguments.'); end

% TRAINING PARAMETERS
if nargin == 3, tp = []; end
tp = nndef(tp,[25 100 1]);
df = tp(1);
max_pres = tp(2);
init_lr = tp(3);
max_nb = max(max(m));

% SIZES
[R,Q] = size(p);
[S,R] = size(w);

% PLOTTING
message = sprintf('TRAINSM: %%g/%g epochs, neighborhood = %%g, lr = %%g.\n',max_pres);
fprintf(message,0,max_nb,init_lr)
if R > 1 & S < 100
  plotsm(w,m);
end

lr_x = (1/max_pres)^(1/sqrt(max_pres*1000));
base_lr = init_lr / (1+lr_x);
nb_x = (1/max_nb)^(10/max_pres);
z = ones(S,1)*(1/S);
for i=1:max_pres

  % TRAINING PARAMETER UPDATE
  nb = max(1,max_nb*nb_x^i);
  lr = base_lr*(5/(4+i) + lr_x^i);

  % PRESENTATION PHASE
  j = fix(rand*Q) + 1;
  P = p(:,j);
  a = simusm(P,w,m,nb);

  % LEARNING PHASE
  dw = learnis(w,P,a,lr);
  w = w + dw;
  
  % PLOTTING 
  if rem(i,df) == 0
    fprintf(message,i,nb,lr)
    if R > 1 & S < 100
    plotsm(w,m);
  end
  end
end

if rem(i,df) ~= 0
  fprintf(message,i,nb,lr)
end
