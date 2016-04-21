function [msg, err, ccode, cerr] = decode(code, n, k, method, opt1, opt2, opt3, opt4)
%DECODE Block decoder.
%   MSG = DECODE(CODE, N, K, METHOD...) decodes CODE using an error-
%   control coding technique.  For information about METHOD and
%   other parameters, and about using a specific technique,
%   type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE       CODING TECHNIQUE
%     decode hamming         % Hamming
%     decode linear          % Linear block
%     decode cyclic          % Cyclic
%
%   See also ENCODE, CYCLPOLY, SYNDTABLE, GEN2PAR.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.27.4.3 $  $Date: 2004/04/12 23:00:37 $

% routine check
if (nargin == 2)
    error('Not enough input parameters')
elseif nargin == 3
    method = 'hamming';
elseif nargin > 3
    method = lower(method);
end;

if nargin < 1
    feval('help', 'decode');
    return;
elseif isstr(code)
    method = lower(deblank(code));
    if length(method) < 2
        error('Invalid method option for DECODE.')
    end
    if nargin == 1
        addition = 'See also ENCODE, CYCLPOLY, SYNDTABLE, GEN2PAR.';
        callhelp('decode.hlp',method(1:2),addition);
    else
        warning('comm:decode:inputVarNum', ...
                'Wrong number of input variables for DECODE.');
    end;
    return;
elseif ~isempty(findstr(method, 'rs'))
    % Reed-Solomon method.
    if ~isempty(findstr(method, 'pow'))
        type_flag = 'power';
    elseif ~isempty(findstr(method, 'dec'))
        type_flag = 'decimal';
    else
        type_flag = 'binary';
    end;
    if nargin > 4
        n = opt1;
    end;
    if nargout <= 1
        msg = rsdeco(code, n, k, type_flag);
    elseif nargout == 2
        [msg, err] = rsdeco(code, n, k, type_flag);
    elseif nargout == 3
        [msg, err, ccode] = rsdeco(code, n, k, type_flag);
    elseif nargout == 4
        [msg, err, ccode, cerr] = rsdeco(code, n, k, type_flag);
    else
        error('Too many output arguments.');
    end;
else
    % make msg to be a column vector when it is a vector.
    if min(size(code)) == 1
        code = code(:);
    end;

    [n_code, m_code] = size(code);

    if ~isempty(findstr(method, 'decimal'))
        type_flag = 1;      % decimal
        if m_code > 1
            method = method(1:find(method=='/')-1);
            error(['CODE for ',method,' code in decimal format must be a vector.'])
        else
            if ~isempty([find(code > 2^n-1); find(code < 0); find(floor(code)~=code)])
                error('CODE must contain only positive integers smaller than 2^N.')
            end;
        end;
        code = de2bi(code, n);
        [n_code, m_code] = size(code);
    else
        type_flag = 0;      % binary matrix
        if ~isempty([find(code > 1); find(code < 0); find(floor(code)~=code)]) & isempty(findstr(method, 'conv'))
            error('CODE must contain only binary numbers.')
        end;
        if m_code == 1
            type_flag = 2;  % binary vector
            [code, added] = vec2mat(code, n);
            if added
                warning('comm:decode:codeFormat', ...
                ['The input CODE does not have the same format as the ', ...
                 'output of ENCODE.  Check your computation procedures ', ...
                 'for possible errors.']);
            end;
            [n_code, m_code] = size(code);
        elseif m_code ~= n
            error('CODE must be either a vector or a matrix with N columns.');
        end;
    end;
    % at this stage CODE is a N-colomn matrix
    if ~isempty(findstr(method, 'bch'))
        % BCH code.
        if nargin <= 4
            t = 0;
        else
            t = opt1;
        end;
        if ~(t>0)
            [tmp1, tmp2, tmp3, tmp4, t] = bchpoly(n, k);
        end;
        if nargin <= 5
            [msg, err, ccode] = bchdeco(code, k, t);
        else
            [msg, err, ccode] = bchdeco(code, k, t, opt2);
        end;
    elseif ~isempty(findstr(method, 'convol'))
        if nargin < 5
            error('Not enough input parameters.')
        elseif nargin == 5
            [msg, err, ccode] = viterbi(code, opt1);
        elseif nargin == 6
            [msg, err, ccode] = viterbi(code, opt1, opt2);
        elseif nargin == 7
            [msg, err, ccode] = viterbi(code, opt1, opt2, opt3);
        else
            [msg, err, ccode] = viterbi(code, opt1, opt2, opt3, opt4);
        end;
    else
        % the msg calculation is the same, different trt and h calculation.
        % for hamming, block and cyclic code.
        if ~isempty(findstr(method, 'hamming'))
            % hamming code.
            m = n - k;
            if 2^m - 1 ~= n
                error('The specified codeword length and message length are not valid.')
            end;
            if nargin <= 4
                [h, gen] = hammgen(m);
            else
                [h, gen] = hammgen(m, opt1);
            end;
            % truth table.
            trt = syndtable(h);
        elseif ~isempty(findstr(method, 'linear'))
            % block code.
            if nargin < 5
                error('The generator matrix is a required input argument for linear block decoding.');
            end;
            [n_opt1, m_opt1] = size(opt1);
            if (m_opt1 ~= n) | (n_opt1 ~= k)
                error('The generator matrix must be a K-by-N matrix.');
            end;
            gen = opt1;
            h = gen2par(gen);
            if nargin < 6
                opt2 = syndtable(h);
            end;
            trt = opt2;
        elseif ~isempty(findstr(method, 'cyclic'))
            % cyclic code.
            if nargin < 4
                error('Not enough input arguments.')
            elseif nargin < 5
                opt1 = cyclpoly(n, k);
            end;
            [h, gen] = cyclgen(n, opt1);
            if nargin < 6
                opt2 = syndtable(h);
            end;
            trt = opt2;
        else
          error(['Invalid decoding method ''',method,'''']);
        end;

        %calculation:
        syndrome = rem(code * h', 2);

        % error location:
        err = bi2de(fliplr(syndrome));
        err_loc = trt(err + 1, :);

        % corrected code
        ccode = rem(err_loc + code, 2);

        % corrected message
        I = eye(k);
        if isequal(gen(:, 1:k) ,I)
           msg = ccode(:, 1:k);
        elseif isequal(gen(:, n-k+1:n), I)
           msg = ccode(:, n-k+1:n);
        else
           error('The generator matrix must be in the standard form.');
        end

        % check the error number for the corresponding msg.
        if nargout > 1
            err = sum(err_loc')';       % number of errors has been found.
            err_loc = rem(msg * gen, 2);    % bring back the code to check the error
            indx = find(sum(abs(err_loc - ccode)') > 0); % find the error location
            err(indx) = indx - indx - 1;             % assign the uncorrected one to be -1
            indx = find(sum(abs(err_loc - code)') ~= err');
            err(indx) = indx - indx - 1;             % assign the uncorrected one to be -1
        end;
        % finish the calculation for hamming code, cyclic code and linear block code.
    end;
    % convert back to the original structure.
    if nargout > 3
        cerr = err;
    end;
    if type_flag == 1
        msg = bi2de(msg);
        if nargout > 2
            ccode = bi2de(ccode);
        end;
    elseif type_flag == 2
        msg = msg';
        msg = msg(:);
        if nargout > 1
            err = err * ones(1, k);
            err = err';
            err=err(:);
        end;
        if nargout > 2
            ccode = ccode';
            ccode = ccode(:);
        end;
        if nargout > 3
            cerr = cerr * ones(1, n);
            cerr = cerr';
            cerr = cerr(:);
        end;
    end;
end;

