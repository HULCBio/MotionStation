function [genpoly,t] = rsgenpoly(N, K, varargin)
%RSGENPOLY  Generator polynomial of Reed-Solomon code.
%   GENPOLY = RSGENPOLY(N,K) returns the narrow-sense generator polynomial of a 
%   Reed-Solomon code with codeword length N and message length K.  The codeword 
%   length N must have the form 2^m-1 for some integer m between 3 and 16.  The 
%   output GENPOLY is a Galois row vector that represents the coefficients of 
%   the generator polynomial in order of descending powers.  The narrow-sense 
%   generator polynomial is (X-alpha)*(X-alpha^2)*...*(X-alpha^(N-K)), where 
%   alpha is a root of the default primitive polynomial for the field GF(N+1).
%   
%   GENPOLY = RSGENPOLY(N,K,PRIM_POLY) is the same as the syntax above, except 
%   that PRIM_POLY specifies the primitive polynomial for GF(N+1) that has alpha 
%   as a root.  PRIM_POLY is an integer whose binary representation indicates 
%   the coefficients of the primitive polynomial in order of descending powers. 
%   To use the default primitive polynomial, set PRIM_POLY to [].
%   
%   GENPOLY = RSGENPOLY(N,K,PRIM_POLY,B) returns the generator polynomial 
%   (X-alpha^B)*(X-alpha^(B+1))*...*(X-alpha^(B+N-K-1)), where B is an integer 
%   and alpha is a root of PRIM_POLY.
%   
%   [GENPOLY,T] = RSGENPOLY(...) returns T, the error-correction capability of 
%   the code.
%
%   Examples:
%      g  = rsgenpoly(7,3)       % Narrow-sense generator polynomial
%      g2 = rsgenpoly(7,3,13)    % Narrow-sense generator polynomial,
%                                %   with respect to primitive polynomial
%                                %   D^3+D^2+1
%      g3 = rsgenpoly(7,3,[],4)  % Use b=4
%   
%   See also GF, RSENC, RSDEC.
   
%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:05:42 $ 

% Initial checks
error(nargchk(2,4,nargin));

% Number of optional input arguments
nvarargin = nargin - 2;

% Error-correcting capability
t = floor((N-K)/2);   
t2 = N-K;
m = log2(N+1);
def_primpoly = 1;
b = 1;  % Default : narrow-sense

if any([~isscalar(N) | ~isscalar(K) | floor(N)~=N | floor(K)~=K])
    error('N and K must be positive scalar integers.');
end

if t2<1
    error('N must be larger than K.');
end

if m~=floor(m) | m<3 | m>16
  error('N must equal 2^m-1 for some integer m between 3 and 16.')
end

if ~isempty(varargin)

    prim_poly = varargin{1};
    
    % Check prim_poly
    if isempty(prim_poly)
        if ~isnumeric(prim_poly)
            error('To use the default PRIM_POLY, it must be marked by [].');
        end
    else
        if ~isscalar(prim_poly)
            error('PRIM_POLY must be a scalar integer.');
        end
        % ZZZ add isprimitive once it's available
        def_primpoly = 0;
    end

    if nvarargin==2
        b = varargin{2};
        if ~isscalar(b) | floor(b)~=b
            error('B must be an integer scalar.');
        end
    end
end

% Alpha is the primitive element of this GF(2^m) field
if def_primpoly == 1
    alpha = gf(2,m);
else
    alpha = gf(2,m,prim_poly);
end

genpoly = 1;
for k=mod(b+[0:t2-1],N)
   evalc('genpoly = conv(genpoly,[1 alpha.^k]);');
end
