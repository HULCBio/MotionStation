function q = unwrap(p,cutoff,dim)
%UNWRAP Unwrap phase angle.
%   UNWRAP(P) unwraps radian phases P by changing absolute 
%   jumps greater than pi to their 2*pi complement. It unwraps 
%   along the first non-singleton dimension of P. P can be a 
%   scalar, vector, matrix, or N-D array. 
%
%   UNWRAP(P,TOL) uses a jump tolerance of TOL rather
%   than the default TOL = pi.
%
%   UNWRAP(P,[],DIM) unwraps along dimension DIM using the
%   default tolerance. UNWRAP(P,TOL,DIM) uses a jump tolerance
%   of TOL.
%
%   See also ANGLE, ABS.

%   Original: J.N. Little, 4-1-87.
%   Revised:  C R. Denham, 4-29-90. 
%             D.L. Chen, 3-22-95.
%   Modified: P. Gahinet, 7-99
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.14.4.1 $  $Date: 2004/01/24 09:21:38 $

% Overview of the algorithm:
%    Reshape p to be a matrix of column vectors. Perform the 
%    unwrap calculation column-wise on this matrix. (Note that this is
%    equivalent to performing the calculation on dimension one.) 
%    Then reshape the output back.

ni = nargin;

% Treat row vector as a column vector (unless DIM is specified)
rflag = 0;
if ni<3 && (ndims(p)==2) && (size(p,1)==1), 
   rflag = 1; 
   p = p.';
end

% Initialize parameters.
nshifts = 0;
perm = 1:ndims(p);
switch ni
case 1
   [p,nshifts] = shiftdim(p);
   cutoff = pi;     % Original UNWRAP used pi*170/180.
case 2
   [p,nshifts] = shiftdim(p);
otherwise    % nargin == 3
   perm = [dim:max(ndims(p),dim) 1:dim-1];
   p = permute(p,perm);
   if isempty(cutoff),
      cutoff = pi; 
   end
end
   
% Reshape p to a matrix.
siz = size(p);
p = reshape(p, [siz(1) prod(siz(2:end))]);

% Unwrap each column of p
q = p;
for j=1:size(p,2)
   % Find NaN's and Inf's
   indf = find(isfinite(p(:,j)));
   % Unwrap finite data (skip non finite entries)
   q(indf,j) = LocalUnwrap(p(indf,j),cutoff);
end

% Reshape output
q = reshape(q,siz);
q = ipermute(q,perm);
q = shiftdim(q,-nshifts);
if rflag, 
   q = q.'; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Local Functions  %%%%%%%%%%%%%%%%%%%

function p = LocalUnwrap(p,cutoff)
%LocalUnwrap   Unwraps column vector of phase values.

m = length(p);

% Unwrap phase angles.  Algorithm minimizes the incremental phase variation 
% by constraining it to the range [-pi,pi]
dp = diff(p,1,1);                % Incremental phase variations
dps = mod(dp+pi,2*pi) - pi;      % Equivalent phase variations in [-pi,pi)
dps(dps==-pi & dp>0,:) = pi;     % Preserve variation sign for pi vs. -pi
dp_corr = dps - dp;              % Incremental phase corrections
dp_corr(abs(dp)<cutoff,:) = 0;   % Ignore correction when incr. variation is < CUTOFF

% Integrate corrections and add to P to produce smoothed phase values
p(2:m,:) = p(2:m,:) + cumsum(dp_corr,1);
