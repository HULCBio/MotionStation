function lr = maxlinlr(p,b)
%MAXLINLR Maximum learning rate for a linear layer.
%
%  Syntax
%
%    lr = maxlinlr(P)
%    lr = maxlinlr(P,'bias')
%
%  Description
%
%    MAXLINLR is used to calculate learning rates for NEWLIN.
%  
%    MAXLINLR(P) takes one argument,
%      P - RxQ matrix of input vectors.
%    and returns the maximum learning rate for a linear layer
%    without a bias that is to be trained only on the vectors in P.
%
%    MAXLINLR(P,'bias') return the maximum learning rate for
%    a linear layer with a bias.
%  
%  Examples
%
%    Here we define a batch of 4 2-element input vectors and
%    find the maximum learning rate for a linear layer with
%    a bias.
%
%      P = [1 2 -4 7; 0.1 3 10 6];
%      lr = maxlinlr(P,'bias')
%  
%  See also LEARNWH.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.12 $  $Date: 2002/04/14 21:36:11 $

if nargin < 1, error('Not enough input arguments.'); end

if nargin == 1
  lr = 0.9999/max(eig(p*p'));
else
  p2=[p; ones(1,size(p,2))];
  lr = 0.9999/max(eig(p2*p2'));
end
