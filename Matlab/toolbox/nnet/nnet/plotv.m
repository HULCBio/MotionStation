function plotv(m,t)
%PLOTV Plot vectors as lines from the origin.
%
%  Syntax
%
%    plotv(m,t)
%
%  Description
%
%    PLOTV(M,T) takes two inputs,
%      M - RxQ matrix of Q column vectors with R elements.
%      T - (optional) the line plotting type, default = '-'.
%    and plots the column vectors of M.
%  
%    R must be 2 or greater.  If R is greater than two,
%    only the first two rows of M are used for the plot.
%
%  Examples
%
%    plotv([-.4 0.7 .2; -0.5 .1 0.5],'-')

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:30:44 $

if nargin < 1,error('Wrong number of arguments.');end

[mr,mc] = size(m);
if mr < 2
  error('Matrix must have at least 2 rows.');
end

if nargin == 1
  t = '-';
end

xy0 = zeros(1,mc);
plot([xy0 ;m(1,:)],[xy0 ;m(2,:)],t);
