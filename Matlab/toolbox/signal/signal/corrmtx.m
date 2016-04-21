function [X,R] = corrmtx(x,M,method)
%CORRMTX Autocorrelation matrix.
%   X = CORRMTX(S,M) given a length N vector S and an integer M, returns
%   a N+M by M+1 matrix X such that X'*X is a (biased) estimate of the 
%   M+1 by M+1 autocorrelation matrix of S.
%
%   X = CORRMTX(S,M,METHOD) returns a matrix X, that is constructed
%   according to METHOD. METHOD can be one of:
%       'autocorrelation' - This is convenient when a positive definite
%                           estimate is desired. However, it is biased
%                           and it windows the data. (Default)
%       'prewindowed'     - The data is windowed only at the beginning.
%                           X has dimension N by M+1.
%       'postwindowed'    - The data is windowed only at the end. X has
%                           dimension N by M+1.
%       'covariance'      - No windowing of the data is done. This
%                           improves the accuracy. The estimate is
%                           unbiased. X has dimension N-M by M+1.
%       'modified'        - This corresponds to the modified covariance
%                           method (a.k.a. forward-backward method). It
%                           can generate more accurate estimates than
%                           covariance in some cases. It is unbiased. X
%                           has dimension 2*(N-M) by M+1.
%
%   [X,R] = CORRMTX(...) returns in addition the M+1 by M+1 correlation
%   matrix R.  R is roughly equal to X'*X, however to ensure conjugate
%   symmetry R is calculated as (X'*X + (X'*X)')/2.
%
%   See also XCORR, CONVMTX, ARCOV, ARMCOV, ARYULE, PMUSIC, ROOTMUSIC.

%   Author(s): R. Losada   	   
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:17:41 $

error(nargchk(2,3,nargin));

if nargin == 2,
   method = 'autocorrelation';
else
   [method,msg] = get_method(method);
   error(msg);
end

if ~any(size(x) == 1),
   error('Input signal must be a vector.');
end

if any(size(M) > 1),
   error('M must be a scalar.');
elseif round(M)~=M,
   error('M must be an integer.');
end

x = x(:);
N = length(x);

% Form covariance method matrix; will be used by all
Xtemp = buffer(x,N-M,N-M-1,'nodelay');
X_unscaled = Xtemp(:,end:-1:1);
X = X_unscaled./sqrt(N-M);

% Add the upper part of the matrix for the prewindowed and autocorrelation methods
if strcmp(method,'prewindowed') | strcmp(method,'autocorrelation'),
   Xtemp_u = buffer(x(1:M),M,M-1);
   X_u = [Xtemp_u(:,end:-1:1) zeros(M,1)];
   X_unscaled = [X_u;X_unscaled];
   if strcmp(method,'prewindowed'),
      X = X_unscaled./sqrt(N);
   end
end

% Add the lower part of the matrix for the postwindowed and autocorrelation methods
if strcmp(method,'postwindowed') | strcmp(method,'autocorrelation'),
   Xtemp_l = buffer(x(N:-1:N-M+1),M,M-1);
   X_l = [zeros(M,1) Xtemp_l(end:-1:1,:)];
   X = [X_unscaled;X_l]./sqrt(N);
end

% Append the reversed and conjugated version of the covariance method matrix for the modified version
if strcmp(method,'modified'),
   Xtemp = conj(X(:,end:-1:1));
   X = [X;Xtemp]./sqrt(2);
end

if nargout == 2,
   R = X'*X;
   % Make sure it is hermitian-symmetric
   R = (R+R')./2;
end

%---------------------------------------------------------------------------------------
function [method,msg] = get_method(method)
%GET_METHOD  Match the user specified string to a known method.

method_opts = {'autocorrelation','covariance','modified','prewindowed','postwindowed'};
msg = '';

indx = strmatch(lower(method),method_opts);

if isempty(indx) | length(indx) > 1,
   msg = 'Ambiguous or invalid method specified.';
   return
end

method = method_opts{indx};

% [EOF] corrmtx.m
   