function [code, added] = encode(msg, n, k, method, opt)
%ENCODE Block encoder.
%   CODE = ENCODE(MSG, N, K, METHOD, OPT) encodes MSG using an error-control
%   coding technique.  For information about the parameters and about using a
%   specific technique, type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE       CODING TECHNIQUE
%     encode hamming         % Hamming
%     encode linear          % Linear block
%     encode cyclic          % Cyclic
%
%   See also DECODE, CYCLPOLY, CYCLGEN, HAMMGEN.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.3 $   $Date: 2004/04/12 23:00:38 $ 

% routine check
error(nargchk(1,5,nargin));
if nargin == 2
    error('Not enough input arguments.')
elseif nargin > 3
    method = lower(method);
elseif nargin == 3
    method = 'hamming';
end;

added = 0;
if nargin < 1
    feval('help', 'encode');
    return;
elseif isstr(msg)
    method = lower(deblank(msg));
    if length(method) < 2
        error('Invalid method option for ENCODE.')
    end
    if nargin == 1
       addition = ['See also DECODE, CYCLPOLY, CYCLGEN, HAMMGEN.'];
        callhelp('encode.hlp',method(1:2),addition);
    else
        warning('comm:encode:inputVarNum', ...
                'Wrong number of input variables for ENCODE.');
    end;
    return;
elseif ~isempty(findstr(method, 'rs'))
    % Reed-Solomon method.
    if ~isempty(findstr(method, 'power'))
        type_flag = 'power';
    elseif ~isempty(findstr(method, 'decimal'))
        type_flag = 'decimal';
    else
        type_flag = 'binary';
    end;
    if nargin <= 4
        [code, added] = rsenco(msg, n, k, type_flag);
    else
        [code, added] = rsenco(msg, n, k, type_flag, opt);
    end;
else
    % make msg to be a column vector when it is a vector.
    if min(size(msg)) == 1
        msg = msg(:);
    end;

    added = 0;
    [n_msg, m_msg] = size(msg);

    if ~isempty(findstr(method, 'decimal'))
        type_flag = 1;      % decimal
        if m_msg > 1
            method = method(1:find(method=='/'));
            error(['For ',method,' code with decimal data, MSG must be a vector.'])
        else
            if ~isempty([find(msg > 2^k-1); find(msg < 0); find(floor(msg)~=msg)])
                error('For decimal data processing, MSG must contain only integers between 0 and 2^K-1.')
            end;
        end;
        msg = de2bi(msg, k);
        [n_msg, m_msg] = size(msg);
    else
        type_flag = 0;      % binary matrix
        if ~isempty([find(msg > 1); find(msg < 0); find(floor(msg)~=msg)])
            error('MSG does not match specified data format.  Either make MSG binary or append /decimal to the method string.')
        end;
        if m_msg == 1
            type_flag = 2;  % binary vector
            [msg, added] = vec2mat(msg, k);
            [n_msg, m_msg] = size(msg);
        elseif m_msg ~= k
            error('The matrix MSG in ENCODE must have K columns.');
        end;
    end;
    % at this stage MSG is a K-column matrix
    if ~isempty(findstr(method, 'bch'))
        % BCH code.
        if nargin <= 4
            code = bchenco(msg, n, k);
        else
            code = bchenco(msg, n, k, opt);
        end;
    elseif ~isempty(findstr(method, 'hamming'))
        % hamming code.
        m = n - k;
        if 2^m - 1 ~= n
            error('The specified codeword length and message length are not valid.')
        end;
        if nargin <= 4
            h = hammgen(m);
        else
            h = hammgen(m, opt);
        end;
        gen = gen2par(h);
        code = rem(msg * gen, 2);
    elseif ~isempty(findstr(method, 'linear'))
        % block code.
        if nargin < 5
            error('The generator matrix is a required input argument for linear block code.');
        end;
        [n_opt, m_opt] = size(opt);
        if (m_opt ~= n) | (n_opt ~= k)
            error('The generator matrix dimensions are not valid.');
        end;
        code = rem(msg * opt, 2);
    elseif ~isempty(findstr(method, 'cyclic'))
        % cyclic code.
        if nargin < 4
            error('Not enough input arguments.')
        elseif nargin < 5
            opt = cyclpoly(n, k);
        end;
        [h, gen] = cyclgen(n, opt);
        code = rem(msg * gen, 2);
    elseif ~isempty(findstr(method, 'convol'))
        code = convenco(msg, opt);
    else
      error(['Unknown coding method ''',method,'''']);
    end;

    % convert back to the original structure.
    if type_flag == 1
        code = bi2de(code);
    elseif type_flag == 2
        code = code';
        code = code(:);
    end;
end;

% [EOF] encode.m
