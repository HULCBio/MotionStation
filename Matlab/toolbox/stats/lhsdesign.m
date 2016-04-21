function X = lhsdesign(n,p,varargin)
%LHSDESIGN Generate a latin hypercube sample.
%   X=LHSDESIGN(N,P) generates a latin hypercube sample X containing N
%   values on each of P variables.  For each column, the N values are
%   randomly distributed with one from each interval (0,1/N), (1/N,2/N),
%   ..., (1-1/N,1), and they are randomly permuted.
%
%   X=LHSDESIGN(...,'PARAM1',val1,'PARAM2',val2,...) specifies parameter
%   name/value pairs to control the sample generation.  Valid parameters
%   are the following:
%
%      Parameter    Value
%      'smooth'     'on' (the default) to produce points as above, or
%                   'off' to produces points at the midpoints of
%                   the above intervals:  .5/N, 1.5/N, ..., 1-.5/N.
%      'iterations' The maximum number of iterations to perform in an
%                   attempt to improve the design (default=5)
%      'criterion'  The criterion to use to measure design improvement,
%                   chosen from 'maximin' (the default) to maximize the
%                   minimum distance between points, 'correlation' to
%                   reduce correlation, or 'none' to do no iteration.
%
%   Latin hypercube designs are useful when you need a sample that is
%   random but that is guaranteed to be relatively uniformly distributed
%   over each dimension.
%
%   Example:  The following commands show that the output from lhsdesign
%             looks uniformly distributed in two dimensions, but too
%             uniform (non-random) in each single dimension.  Repeat the
%             same commands with x=rand(100,2) to see the difference.
%
%      x = lhsdesign(100,2);
%      subplot(2,2,1); plot(x(:,1), x(:,2), 'o');
%      subplot(2,2,2); hist(x(:,2));
%      subplot(2,2,3); hist(x(:,1));
%
%   See also LHSNORM, UNIFRND.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.3 $  $Date: 2003/11/01 04:26:47 $

% Check input arguments
if mod(length(varargin),2)~=0
   error('stats:lhsdesign:BadNumberInputs','Incorrect number of arguments.')
end
okargs = {'iterations' 'criterion' 'smooth'};
defaults = {NaN 'maximin' 'on'};
[eid,emsg,maxiter,crit,dosmooth] = statgetargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:lhsdesign:%s',eid),emsg)
end

if isempty(maxiter)
   maxiter = NaN;
elseif ~isnumeric(maxiter) | prod(size(maxiter))~=1 | maxiter<0
   error('stats:lhsdesign:ScalarRequired',...
         'Value of ''iterations'' parameter must be a scalar >= 0.');
end
if isnan(maxiter), maxiter = 5; end

okcrit = {'none' 'maximin' 'correlation'};
if isempty(crit)
   crit = 'maximin';
end
if ~ischar(crit)
   error('stats:lhsdesign:BadCriterion','Bad criterion name.');
end
i = strmatch(crit,okcrit);
if isempty(i)
   error('stats:lhsdesign:BadCriterion','Bad criterion name "%s".',crit);
elseif length(i)>1
   error('stats:lhsdesign:BadCriterion','Ambiguous criterion name "%s".',crit);
end
crit = okcrit{i};

if isempty(dosmooth)
   dosmooth = 'on';
elseif (~isequal(dosmooth,'on')) & (~isequal(dosmooth,'off'))
   error('stats:lhsdesign:BadSmooth',...
         'Value of ''smooth'' parameter must be ''on'' or ''off''.');
end

% Start with a plain lhs sample over a grid
X = getsample(n,p,dosmooth);

% Create designs, save best one
if isequal(crit,'none'), maxiter = 0; end
switch(crit)
 case 'maximin'
   bestscore = score(X,crit);
   for j=2:maxiter
      x = getsample(n,p,dosmooth);
      
      newscore = score(x,crit);
      if newscore > bestscore
         X = x;
         bestscore = newscore;
      end
   end
 case 'correlation'
   bestscore = score(X,crit);
   for iter=2:maxiter
      % Forward ranked Gram-Schmidt step:
      for j=2:p
         for k=1:j-1
            z = takeout(X(:,j),X(:,k));
            X(:,k) = (rank(z) - 0.5) / n;
         end
      end
      % Backward ranked Gram-Schmidt step:
      for j=p-1:-1:1
         for k=p:-1:j+1
            z = takeout(X(:,j),X(:,k));
            X(:,k) = (rank(z) - 0.5) / n;
         end
      end
   
      % Check for convergence
      newscore = score(X,crit);
      if newscore <= bestscore
         break;
      else
         bestscore = newscore;
      end
   end
end

% ---------------------
function x = getsample(n,p,dosmooth)
x = rand(n,p);
for i=1:p
   x(:,i) = rank(x(:,i));
end
   if isequal(dosmooth,'on')
      x = x - rand(size(x));
   else
      x = x - 0.5;
   end
   x = x / n;
   
% ---------------------
function s = score(x,crit)
% compute score function, larger is better

switch(crit)
 case 'correlation'
   % Minimize the sum of between-column squared correlations
   c = corrcoef(x);
   s = -sum(sum(triu(c,1).^2));

 case 'maximin'
   % Maximimize the minimum point-to-point difference
   % Get I and J indexing each pair of points
   [m,p] = size(x);
   pp = (m-1):-1:2;
   I = zeros(m*(m-1)/2,1);
   I(cumsum([1 pp])) = 1;
   I = cumsum(I);
   J = ones(m*(m-1)/2,1);
   J(cumsum(pp)+1) = 2-pp;
   J(1)=2;
   J = cumsum(J);

   % To save space, loop over dimensions
   d = zeros(size(I));
   for j=1:p
      d = d + (x(I,j)-x(J,j)).^2;
   end
   s = sqrt(min(d));
end

% ------------------------
function z=takeout(x,y)

% Remove from y its projection onto x, ignoring constant terms
xc = x - mean(x);
yc = y - mean(y);
b = (xc-mean(xc))\(yc-mean(yc));
z = y - b*xc;

% -----------------------
function r=rank(x)

% Similar to tiedrank, but no adjustment for ties here
[sx, rowidx] = sort(x);
r(rowidx) = 1:length(x);
r = r(:);
