function [msg, err, ccode, err_c] = rsdeco(code, n, k, type_flag)
%RSDECO
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use RSDEC instead.

%RSDECO Reed-Solomon decoder.
%   MSG = RSDECO(CODE, N, K) decodes the binary message in MSG by using
%   the Reed-Solomon decoding technique with codeword length N, message
%   length K. A valid Reed-Solomon code should have its code word length
%   N = 2^M - 1, where M is an integer no less than 3. The message length
%   K should be smaller than the codeword length N. The input variable
%   CODE should have the same format as the output of RSENCO. Let L1=N*M
%   and Z be any positive integer. The input variable CODE can be
%   either of the two formats:
%       (1) a column vector with length L1*Z or
%       (2) a L1-by-Z matrix.
%   The output format of this function matches the style of the input.
%   When the input uses format (1), the output MSG is an L2 * Z column
%   vector  with L2 = L1 * K / N. When input uses format (2), the
%   output MSG is a L2-by-Z matrix with L2 given above. When the input
%   CODE is not an output format of RSENCO, the function will cause an
%   error. To speed up the calculation, the code word length N could be
%   the list of all elements in GF(2^M), a 2^M-by-M matrix.
%
%   MSG = RSDECO(CODE, N, K, TYPE_FLAG) specifies the format of CODE by
%   using TYPE_FLAG. The default TYPE_FLAG is 'binary'. The CODE can also
%   be 'decimal' or 'power'. If TYPE_FLAG = 'decimal', the elements in
%   CODE are integers in the range between 0 to N. If TYPE_FLAG = 'power'
%   the elements in CODE are represented using the power format in
%   GF(2^M), which are -Inf and integer 0 to N-2. Any negative number in
%   this form is equivalent to -Inf. With either TYPE_FLAG = 'decimal' or
%   TYPE_FLAG = 'power', the elements in CODE should match the code
%   type. When TYPE_FLAG equals 'power' or 'decimal', the input CODE
%   format could be either
%       (i) a column vector with length N*Z or
%       (ii) an N-by-Z matrix
%   Note the different dimension compared to the 'binary' case. The output
%   of this function MSG matches the input format and data type of the
%   input. When input is in case (i), the output MSG is a K*Z column
%   When input CODE is in format case (ii), the output MSG is a K-by-Z
%   matrix. The function will cause an error if the input data format
%   does not follow the rules.
%
%   [MSG, ERR] = RSDECO(...) outputs the number ERR, which specifies the
%   number of errors found in the decode of the MSG provided in the same
%   column in MSG.
%
%   [MSG, ERR, CCODE] = RSDECO(...) outputs the corrected CODE. The format
%   of CCODE will match exactly the CODE in the input.
%
%   [MSG, ERR, CCODE, ERR_C] = RSDECO(...) outputs the number ERR_C which
%   specifies the number of errors found in matching the CCODE column.
%
%   Note that Reed-Solomon code is specially designed for correcting
%   "burst errors" instead of "random errors."
%
%   The Reed-Solomon code in the following example has an error-correction
%   capability of two. If up to two 'burst errors' occur between the
%   green lines in the plot, then the decoder can correct the error(s).
%
%   % Number of bits in calculation
%   L = 1000;
%   M = 4;
%   % Codeword length
%   N = 2^M - 1;
%   % Message length
%   K = N - 4;
%   % Testing 1000 bits
%   MSG = randint(L, 1);
%   % Generate all members of GF(2^M).
%   TP = gftuple([-1 : N-1]',M);
%   % Encode.
%   [CODE, ADDED] = rsenco(MSG, TP, K);
%   % Add 3% noise.
%   NOI = rand(length(CODE)/M, 1) < .03;
%   % Make a burst error.
%   NOI = (NOI * ones(1, M))';
%   NOI = NOI(:);
%   % Add noise to the message.
%   CODE_NOI = rem(CODE + NOI, 2);
%   % Decode.
%   [DEC, ERR, CCODE, ERR_C] = rsdeco(CODE_NOI, TP, K);
%   % Adjust length to prepare for comparison.
%   MSG = [MSG; zeros(ADDED, 1)];
%   % Comparison
%   max(abs(DEC-MSG));
%   X = [1:length(NOI)];
%   Z = [1:M*N:length(NOI)];
%   Y=zeros(1,length(Z));Z=[Z;Z];
%   Y=[Y+min(ERR_C);Y+max(ERR_C)];
%   subplot(211);
%   % Placed vs. detected error
%   plot(X,NOI,'yo',X,ERR_C,'rx',Z,Y,'g-');
%   title('Error Detection Record');
%   xlabel(...
%     'o--placed error;x--detected error;vertical bar: RS-DECO section.');
%   axis([1, length(NOI), min(ERR_C), max(ERR_C)]);
%   X = [1:length(MSG)];                  % x-axis for MSG
%   Z = [1:M*K:length(MSG)];Y=zeros(1,length(Z));
%   Z=[Z;Z];Y=[Y;Y+max(MSG)];
%   subplot(212);
%   plot(X, MSG,'yo',X,DEC,'rx',Z,Y,'g-');
%   title('Message and Decoded Signal Comparison');
%   xlabel('o--original message; x--decoded result.');
%   axis([1, length(MSG), min(min(MSG)), max(max(MSG))]);
%
%   See also RSENCO, RSENCODE, RSDECODE, RSPOLY.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.19 $   $Date: 2002/03/27 00:20:01 $ 

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
else
    type_flag = lower(type_flag);
end;

% default format type is matrix type
fmt_type = 0;
if min(size(code)) == 1
    % vector type format
    fmt_type = 2;
elseif min(size(code)) < 1
    return;
end;

% distinguish all different cases for code
[n_code, m_code] = size(code);
if ~isempty(findstr(type_flag, 'binary'))
    % it is a binary case.
    if fmt_type
        fmt_type = 1;
        [code, added] = vec2mat(code, dim);
        if added
            disp('Warning: CODE format is not exactly an encode output format.');
            disp('         Please check your computation procedure for a possible error.');
        end;
    else
        if m_code ~= dim
            error('The first input matrix in RSDECO has the wrong number of columns.')
        end;
    end;
    code = bi2de(code);
end;

if fmt_type <= 1
    [code, added] = vec2mat(code, pow_dim, -Inf);
    if added
            disp('Warning: CODE format is not exactly an encode output format.');
            disp('         Please check your computation procedure for a possible error.');
    end;
else
    if m_code ~= n
        error('The first input matrix has the wrong number of columns.')
    end;
end;

% convert to power form.
if isempty(findstr(type_flag, 'power'))
    code = code - 1;
end;

% decode;
[msg, err, ccode] = rsdecode(code, k, tp);

if nargout > 3
    err_c = err;
end;

% make the code matrix match for the input format.
if ~isempty(findstr(type_flag, 'power'))
    if fmt_type
        msg = msg';
        msg = msg(:);
        if nargout > 1
            err = err * ones(1, k);
            err = err';
            err = err(:);
        end;
        if nargout > 2
            ccode = ccode';
            ccode = ccode(:)';
        end;
        if nargout > 3
            err_c = err_c * ones(1, pow_dim);
            err_c = err_c';
            err_c = err_c(:);
        end;
    end;
else
    msg = msg + 1;
    indx = find(~(msg > 0));
    msg(indx) = zeros(length(indx), 1);
    if nargout > 2
        ccode = ccode + 1;
        indx = find(~(ccode > 0));
        ccode(indx) = zeros(length(indx), 1);
    end;
    if ~isempty(findstr(type_flag, 'decimal'))
        % the decimal case
        if fmt_type
            msg = msg';
            msg = msg(:);
            if nargout > 1
                err = err * ones(1, k);
                err = err';
                err = err(:);
            end;
            if nargout > 2
                ccode = ccode';
                ccode = ccode(:)';
            end;
            if nargout > 3
                err_c = err_c * ones(1, pow_dim);
                err_c = err_c';
                err_c = err_c(:);
            end;
        end;
    else
        % the binary case
        msg = msg';
        msg = msg(:);
        msg = de2bi(msg, dim);
        if nargout > 1
            err = err * ones(1, k);
            err = err';
            err = err(:);
        end;
        if nargout > 2
            ccode = ccode';
            ccode = ccode(:)';
            ccode = de2bi(ccode, dim);
        end;
        if nargout > 3
            err_c = err_c * ones(1, pow_dim);
            err_c = err_c';
            err_c = err_c(:);
        end;
        if fmt_type
            msg = msg';
            msg = msg(:);
            if nargout > 1
                err = err * ones(1, dim);
                err = err';
                err = err(:);
            end;
            if nargout > 2
                ccode = ccode';
                ccode = ccode(:)';
            end;
            if nargout > 3
                err_c = err_c * ones(1, dim);
                err_c = err_c';
                err_c = err_c(:);
            end;
        end
    end
end;

%--end of rsdeco--
