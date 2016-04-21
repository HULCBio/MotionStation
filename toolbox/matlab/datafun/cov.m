function xy = cov(x,varargin)
%COV Covariance matrix.
%   COV(X), if X is a vector, returns the variance.  For matrices,
%   where each row is an observation, and each column a variable,
%   COV(X) is the covariance matrix.  DIAG(COV(X)) is a vector of
%   variances for each column, and SQRT(DIAG(COV(X))) is a vector
%   of standard deviations. COV(X,Y), where X and Y are
%   vectors of equal length, is equivalent to COV([X(:) Y(:)]). 
%   
%   COV(X) or COV(X,Y) normalizes by (N-1) where N is the number of
%   observations.  This makes COV(X) the best unbiased estimate of the
%   covariance matrix if the observations are from a normal distribution.
%
%   COV(X,1) or COV(X,Y,1) normalizes by N and produces the second
%   moment matrix of the observations about their mean.  COV(X,Y,0) is
%   the same as COV(X,Y) and COV(X,0) is the same as COV(X).
%
%   The mean is removed from each column before calculating the
%   result.
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also CORRCOEF, STD, MEAN.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.16.4.3 $  $Date: 2004/03/09 16:16:12 $

if nargin==0 
  error('MATLAB:cov:NotEnoughInputs','Not enough input arguments.'); 
end
if nargin>3, error('MATLAB:cov:TooManyInputs', 'Too many input arguments.'); end
if ndims(x)>2, error('MATLAB:cov:InputDim', 'Inputs must be 2-D.'); end

nin = nargin;

% Check for cov(x,flag) or cov(x,y,flag)
if (nin==3) || ((nin==2) && (length(varargin{end})==1));
  flag = varargin{end};
  nin = nin - 1;
else
  flag = 0;
end

if nin == 2,
  x = x(:);
  y = varargin{1}(:);
  if length(x) ~= length(y), 
    error('MATLAB:cov:XYlengthMismatch', 'The lengths of x and y must match.');
  end
  x = [x y];
end

if length(x)==numel(x)
  x = x(:);
end

[m,n] = size(x);

if m==1,  % Handle special case
  xy = zeros(class(x));

else
  xc = x - repmat(sum(x)/m,m,1);  % Remove mean
  if flag
    xy = xc' * xc / m;
  else
    xy = xc' * xc / (m-1);
  end
  xy = 0.5*(xy+xy');
end

