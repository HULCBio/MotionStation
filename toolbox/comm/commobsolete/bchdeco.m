function [msg, err, ccode] = bchdeco(code, k, t, ord);
%BCHDECO 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use BCHDEC instead.

%   MSG = BCHDECO(CODE, K, T) recovers a message signal MSG from a codeword
%   CODE using BCH code technique provided K is the message length and T is the
%   error-correction capability.
%
%   MSG = BCHDECO(CODE, K, T, PRIM_POLY) specifies the primitive polynomial in
%   producing the minimal polynomial of the BCH code.
%
%   [MSG, ERR] = BCHDECO(...) outputs the corrected error number. When the
%   number of errors is larger than t, the error correction capability, ERR
%   equals -1. 
%
%   [MSG, ERR, CCODE] = BCHDECO(...) outputs corrected codeword.
%
%   This example uses BCHDECO to process a three error correction code.
%   [pg, pm, cs, h, t] = bchpoly(15, 5);  % produce generator polynomial
%   msg = randint(100, 5);                % message signal
%   code = encode(msg, 15, 5, 'bch', pg); % encode
%   code = rem(code + randerr(100,15,[1 2 3]), 2);   % add errors.
%   [dec, err] = bchdeco(code, 5, t);     % decode
%
%   See also BCHENCO, BCHPOLY.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
%

% The algorithm used in this function is provided in Shu Lin's book.

%routine check
if nargin < 3
    error('Not enough input variables for BCHDECO');
end;

% assign initial parameter, further parameter check.
[n_code, m_code] = size(code);

% the dimension of the primitive polynomial in generating the BCH minimal polynomial
dim = 3;
pow_dim = 2^dim -1;
while pow_dim < m_code
    dim = dim + 1;
    pow_dim = 2^dim - 1;
end;

% In case of specified primitive polynomial
if nargin > 3
    ord = ord(:)';
    n_ord = length(ord);

    % it should be a vector.
    if n_ord ~= pow_dim - k + 1
        error(['The primitive polynomial ORD must have order ', num2str(dim)])
    end;

    % the primitive polynomial must be binary
    if ~isempty([find(floor(ord) ~= ord) find(ord < 0) find(ord > 1)])
        error('The primitive polynomial ORD has illegal coefficients');
    end;
%    [ord, rm] = gfdeconv([1, zeros(1, pow_dim-1), 1], ord);
    ord = gfprimdf(dim);
else
    % provide the default primitive polynomial
    ord = gfprimdf(dim);
end;

if (pow_dim ~= m_code)
    % the dimension of the code word and the parity-check matrix do not match
    error('The dimension of the code word and the parity-check matrix do not match');
end;

% the complete list of all element in GF(2^dim)
tp = gftuple([-1:pow_dim-1]', ord);

% there is no error at the very begining
err = zeros(n_code,1);

% compute each code word in the transfer
for n_i = 1 : n_code
  [msg(n_i,:), err(n_i), ccode(n_i, :)] = ...
      bchcore(code(n_i,:), pow_dim, dim, k, t, tp);
end;

%--end of bchdeco--
