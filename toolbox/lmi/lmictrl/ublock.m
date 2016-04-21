% block = ublock(dims,bound,type)
%
% Specification of the individual uncertainty blocks entering
% in the linear-fractional representation of uncertain linear
% systems.
%
% Input:
%  DIMS     dimensions of the block. DIMS = 3 means a 3x3
%           block, and DIMS = [1 2] means a 1x2 block
%  BOUND    quantitative information about the uncertainty:
%            * norm-bounded uncertainty:
%                BOUND is either a positive scalar for uniform
%                bounds, or a SISO system W for frequency-
%                weighted bounds:
%                      | Delta (jw) | <  | W(jw) |
%            * sector-bounded uncertainty:
%                set  BOUND = [a,b]  for uncertainty valued in
%                the sector {a,b}
%  TYPE     composite string defining the uncertainty properties:
%            * nature: 'lti'   -> linear time-invariant (Default)
%                      'ltv'   -> linear time-varying
%                      'nl'    -> arbitrary nonlinear
%                      'nlm'   -> nonlinear memoryless
%            * structure:  'f' -> full block            (Default)
%                          's' -> scalar block d*eye(DIMS)
%            * value:      'c' -> complex-valued        (Default)
%                          'r' -> real-valued
% Output:
%  BLOCK    column vector storing this information.
%
% Example:  To specify a 2x3 LTI uncertainty block of gain less
%           than 1, type
%                  block = ublock ([2 3],1,'ltifc')
%           or simply
%                  block = ublock ([2 3],1)
%
%
% See also  UINFO, UDIAG, SLFT, AFF2LFT.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function block = ublock(dims,bound,type)

if nargin<2,
  error('usage: block = ublock(dims,bound,type)');
elseif isstr(dims) | isstr(bound),
  error('DIMS and BOUNDS must be numerical data');
elseif nargin < 3,
  type=[];
elseif ~isstr(type),
  error('TYPE must be a string');
end

% dimensions

dims=dims(:);
if length(dims)==1,
  rdim=dims; cdim=dims;
elseif length(dims)==2,
  rdim=dims(1); cdim=dims(2);
else
  error('DIMS must be a scalar or a vector of length 2');
end


% type

type=[type '**']; % fill in

if ~isempty(findstr(type,'r')),
  comp=0;
else
  comp=1;
end

if ~isempty(findstr(type,'s')) | (rdim==1 & cdim==1),
  scal=1;
else
  scal=0;
end

if ~isempty(findstr(type,'nl')),
  lin=0; comp=0;
else
  lin=1;
end

if (lin & isempty(findstr(type,'tv'))) | ~isempty(findstr(type,'nlm')),
  time=0;  % lti or nlm
else
  time=1;
end




% detect inconsistencies
if scal & rdim~=cdim,
   error('Scalar blocks must be square');
end


% analyze third argument
lnb=length(bound(:));
if lnb==2,       % sector-bounded
  if rdim~=cdim,
    error('Sector-bounded blocks must be square');
  end
elseif lnb>2,    % frequency-weighted bound
  if length(find(bound(:)==-Inf))~=1,
    error('BOUND must be a scalar, a 1x2 vector, or a SISO system');
  end
  [ns,ni,no]=sinfo(bound);
  if ni~=1 | no~=1,
    error('Frequency-dependent bounds must be SISO filters');
  elseif max(real(spol(bound))) >=0,
    error('Frequency-dependent bounds must be stable transfer functions');
  elseif ~lin | time,
    error('Frequency-dependent bounds can only be used for LTI uncertainty');
  elseif sum(size(bound))==3,
    bound=[min(bound),max(bound)];
    if min(abs(bound))==Inf, error('Sector [-Inf,Inf] not allowed'); end
  end
end


% store data
%  1,2 -> dims
%  3,6 -> type
%  7,8 -> dims add. data
%  ... -> bound data

[m,n]=size(bound);
if min(m,n)==1, m=max(m,n); n=1; end
block=[rdim;cdim;lin;time;comp;scal;m;n;bound(:)];
