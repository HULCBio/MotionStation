function [code,added] = rsenco(msg, n, k, type_flag, pg)
%RSENCO
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use RSENC instead.

%RSENCO Reed-Solomon encoder.
%   CODE = RSENCO(MSG, N, K) encodes the binary message in MSG by using code
%   word length N, message length K Reed-Solomon coding technique. A valid
%   Reed-Solomon code should have its codeword length N equal to 2^M - 1, where
%   M is an integer no less than 3, and should have its message length K < N.
%   Let L1 = K*M, and Z be a positive integer. The input variable MSG can be
%   either
%       (1) a column vector with length L1*Z or
%       (2) a L-by-Z matrix.
%   When input MSG has format (1), the output CODE is a L2 column vector with L2
%   = ceil(L/K/M)*M*N. When input MSG has format (2), the output CODE is a
%   L2-by-Z matrix with L2 given as above. For speeding the calculation, the
%   code word length N can be the list of all elements in GF(2^M), a 2^M-by-M
%   matrix.
%
%   CODE = RSENCO(MSG, N, K, TYPE_FLAG) specifies the format of MSG by using
%   TYPE_FLAG. The default TYPE_FLAG is 'binary'. The MSG can also be 'decimal'
%   or 'power'. If TYPE_FLAG = 'decimal', the elements in  MSG are integers in
%   the range between 0 to N. If TYPE_FLAG = 'power' the elements in MSG are
%   represented using the power format in GF(2^M), which are -Inf and integer 0
%   to N-1. Any negative number in this form is equivalent to -Inf. In either
%   case, with TYPE_FLAG = 'decimal' or TYPE_FLAG = 'power', the elements in MSG
%   should match the code type.
%   In these two cases, MSG could be
%       (i) a length K*Z column vector or
%       (ii) an K-by-K matrix.
%   Note the different dimensions compared to the 'binary' case. When the input
%   MSG uses format case (i), the output CODE is an N*Z column  vector. When the
%   input MSG uses format (ii), the output CODE is a K-by-N matrix.
%
%   CODE = RSENCO(MSG, N, K, TYPE_FLAG, PG) specifies the generator polynomial
%   of the Reed-Solomon code.
%
%   [CODE, ADDED] = RSENCO(...) outputs the number ADDED in specifying how many
%   columns have been added to MSG based on whichever MSG format it is.
%
%   The output CODE type matches the input MSG type. The computation in this
%   function follows the order of the data type conversion: MSG:
%   binary-->decimal-->power; CODE: power-->decimal-->binary whenever it is
%   necessary.
%
%   Note that Reed-Solomon code is specially designed for correcting "burst
%   error" instead of "random error".
%
%   See also RSDECO, RSENCODE, RSDECODE, RSPOLY.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.14 $  $Date: 2002/03/27 00:20:10 $ 


% routine check
if nargin < 3
    error('Not enough input variables for RSENCO');
end;

% distinguish the two cases for N, the second input variable.
% dim, pow_dim, tp.
if length(n) < 2
    pow_dim = n;
    dim = 3;
    n = 2^dim - 1;
    while n < pow_dim
        dim = dim + 1;
        n = 2^dim - 1;
    end;
    tp = gftuple([-1 : pow_dim-1]', dim);
else
    tp = n;
    [pow_dim, dim] = size(tp);
    if pow_dim ~= 2^dim
        error('The second input variable for RSENCO is not valid.')
    end;
    pow_dim = pow_dim - 1;
end;

% default type_flag
if nargin < 4
    type_flag = 'binary';
elseif isempty([findstr(type_flag, 'power'),findstr(type_flag, 'decim')])
    type_flag = 'binary';
else
    type_flag = lower(type_flag);
end;

% default format type is matrix type
fmt_type = 0;
if min(size(msg)) == 1
    % vector type format
    fmt_type = 2;
elseif min(size(msg)) < 1
    return;
end;

% distinguish all different cases for msg
[n_msg, m_msg] = size(msg);
if ~isempty(findstr(type_flag, 'binary'))
    % it is a binary case.
    if fmt_type
        fmt_type = 1;
        [msg, added] = vec2mat(msg, dim);
        [n_msg, m_msg] = size(msg);
    else
        if m_msg ~= dim
            error('The first input matrix has invalid number of columns.');
        end;
    end;
    msg = bi2de(msg);
end;

if fmt_type <= 1
    [msg, added2] = vec2mat(msg, k, -Inf);
    if fmt_type == 1
        added = added + added2 * dim;
    else
        added = added2;
    end;
else
    if m_msg ~= k
        error('The first input matrix has invalid number of columns.');
    end;
end;

% convert to power form.
if isempty(findstr(type_flag, 'power'))
    msg = msg - 1;
end;

% calculate the Reed-Solomon polynomial
if nargin < 5
    pg = rspoly(pow_dim, k, tp);
end;

% encode;
code = rsencode(msg, pg, pow_dim, tp);

% make the code matrix match for the input format.
if ~isempty(findstr(type_flag, 'power'))
    if ~fmt_type
        code = code';
        code = code(:);
    end;
else
    code = code + 1;
    indx = find(~(code > 0));
    code(indx) = zeros(length(indx), 1);
    if ~isempty(findstr(type_flag, 'decim'))
        % the decimal case
        if fmt_type
            code = code';
            code = code(:);
        end;
    else
        code = code';
        code = code(:);
        code = de2bi(code, dim);
        if fmt_type
            code = code';
            code = code(:);
        end
    end
end;

%--end of rsenco--
