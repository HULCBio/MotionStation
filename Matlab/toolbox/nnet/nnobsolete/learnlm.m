function j = learnlm(p,d)
%LEARNLM Levenberg-Marquardt learning rule.
%  
%  This function is obselete.
%  Use NNT2FF and TRAIN to update and train your network.

nntobsf('learnlm','Use NNT2FF and TRAIN to update and train your network.')

%  LEARNLM(P,D)
%    P  - RxQ matrix of input (column) vectors.
%    D  - SxQ matrix of delta (column) vectors.
%  Returns:
%    Partial jacobian matrix.
%  
%  See also NNLEARN, BACKPROP, INITFF, SIMFF, TRAINLM.

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:23 $

if nargin < 2, error('Wrong number of arguments.'),end

[R,Q]=size(p);
[S,Q]=size(d);
j = nncpy(d',R) .* nncpyi(p',S);
