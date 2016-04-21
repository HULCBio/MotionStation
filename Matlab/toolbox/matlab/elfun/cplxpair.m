function z = cplxpair(x,tol,dim)
%CPLXPAIR Sort numbers into complex conjugate pairs.
%   Y = CPLXPAIR(X) takes a vector of complex conjugate pairs and/or
%   real numbers.  CPLXPAIR rearranges the elements of X so that
%   complex numbers are collected into matched pairs of complex
%   conjugates.  The pairs are ordered by increasing real part.
%   Any purely real elements are placed after all the complex pairs.
%   Y = CPLXPAIR(X,TOL) uses a relative tolerance of TOL for
%   comparison purposes.  The default is TOL = 100*EPS.
%
%   For X an N-D array, CPLXPAIR(X) and CPLXPAIR(X,TOL) rearranges
%   the elements along the first non-singleton dimension of X.
%   CPLXPAIR(X,[],DIM) and CPLXPAIR(X,TOL,DIM) sorts X along 
%   dimension DIM.

%   L. Shure 1-27-88
%   Revised 4-30-96 D. Orofino
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.14.4.1 $  $Date: 2003/05/01 20:41:23 $

if isempty(x),
  z = x; return  % Quick exit if empty input
end
if nargin == 3,
  nshifts = 0;
  perm = [dim:max(ndims(x),dim) 1:dim-1];
  x = permute(x,perm);
else
  [x,nshifts] = shiftdim(x);
  perm = [];
end

% Supply defaults for tolerance:
if nargin<2 || isempty(tol), tol=100*eps; end

% Reshape x to a 2-D matrix:
xsiz   = size(x);         % original shape of input
x      = x(:,:);          % reshape to a 2-D matrix
z      = zeros(size(x));  % preallocate temp storage
errmsg = 'Complex numbers can''t be paired.';

for k = 1:size(x,2),
  % Get next column of x:
  xc = x(:,k);

  % Find purely-real entries:
  idx = find(abs(imag(xc)) <= tol*abs(xc));
  nr = length(idx);     % Number of purely-real entries
  if ~isempty(idx),
    % Store sorted real's at end of column:
    z(end-nr+1:end,k)  = sort(real(xc(idx)));
    xc(idx) = [];  % Remove values from current column
  end

  nc = length(xc); % Number of entries remaining in input column
  if nc>0,
    % Complex values in list:
    if rem(nc,2)==1
      % Odd number of entries remaining
      error('MATLAB:cplxpair:ComplexValuesPaired',errmsg);  
    end

    % Sort complex column-vector xc, based on its real part:
    [xtemp,idx] = sort(real(xc));
    xc = xc(idx);  % Sort complex numbers based on real part

    % Check if real parts occur in pairs:
    %   Compare to xc() so imag part is considered (in case real part is nearly 0).
    %   Arbitrary choice of using abs(xc(1:2:nc)) or abs(xc(2:2:nc)) for tolerance
    if any( abs(xtemp(1:2:nc)-xtemp(2:2:nc)) > tol.*abs(xc(1:2:nc)) ),
      error('MATLAB:cplxpair:ComplexValuesPaired', errmsg);
    end

    % Check real part pairs to see if imag parts are conjugates:
    nxt_row = 1;  % next row in z(:,k) for results
    while ~isempty(xc),
      % Find all real parts "identical" to real(xc(1)):
      idx = find( abs(real(xc) - real(xc(1))) <= tol.*abs(xc) );
      nn = length(idx); % # of values with identical real parts
      if nn<=1
        % Only 1 value found - certainly not a pair!
        error('MATLAB:cplxpair:ComplexValuesPaired', errmsg); 
      end

      % There could be multiple pairs with "identical" real parts.
      % Sort the imaginary parts of those values with identical real
      %   parts - these SHOULD be the next N entries, with N even.
      [xtemp,idx] = sort(imag(xc(idx)));
      xq = xc(idx);  % Get complex-values with identical real parts,
      % which are now sorted by imaginary component.
      % Verify conjugate-pairing of imaginary parts:
      if any( abs(xtemp + xtemp(nn:-1:1)) > tol.*abs(xq) ),
        error('MATLAB:cplxpair:ComplexValuesPaired', errmsg);
      end
      % Keep value with pos imag part, and compute conjugate for pair.
      % List value with most-neg imag first, then its conjugate.
      z(nxt_row : nxt_row+nn-1, k) = reshape([conj(xq(end:-1:nn/2+1)) ...
                                                   xq(end:-1:nn/2+1)].',nn,1);
      nxt_row = nxt_row+nn;  % Bump next-row pointer
      xc(idx) = [];          % Remove entries from xc
    end

  end % of complex-values check
end % of column loop

% Reshape Z to appropriate form
z = reshape(z,xsiz);
if ~isempty(perm),
  z = ipermute(z,perm);
end
if nshifts~=0,
  z = shiftdim(z,-nshifts);
end

% end of cplxpair.m
