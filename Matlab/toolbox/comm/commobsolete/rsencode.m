function code = rsencode(msg, pg, n, tp);
%RSENCODE
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use RSENC instead.

%RSENCODE Reed-Solomon encoding using the exponential format.
%   CODE = RSENCODE(MSG, PG, N) encodes the message MSG using Reed-Solomon
%   coding technique. PG is the generator polynomial. N is the code word length.
%   The decode pair for this function is RSDECODE. N=2^M, M is a positive
%   integer no less than 3.
%
%   CODE = RSENCODE(MSG, PG, N, TP) provides a list of all elements in GF(2^M).
%
%   Note that the elements of MSG, PG and CODE are in GF(2^M). The power form is
%   used in the representation, i.e., [-Inf, 0, 1, 2, ...] represents [0, 1,
%   alpha, alpha^2, ...]. For a regular binary coding, use ENCODE.
%
%   See also RSDECODE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.11 $   $Date: 2002/03/27 00:20:13 $ 

%   The systematic encode of the Reed-Solomon code is the message
%   plus the parity-check part. The parity-check digits are the
%   coefficients of the remender pc(X) resulted from dividing the
%   message polynomial msg(X)*X^(2t) by the generator polynomial pg(X).
%   or pg(X) qt(X) + pc(X) = msg(X) * X^(2t)
%   Note that pg(X) is a monic polynomial

[n_msg, m_msg] = size(msg);

% in case of single message input
if min([n_msg, m_msg]) == 1;
    msg = msg(:)';
    m_msg = max(n_msg, m_msg);
    n_msg = 1;
end;

% when not enough parameters, need to find out dimension.
if nargin < 4
    tp = 3;
    pow_dim = 2^tp -1;
    while pow_dim < n
        tp = tp + 1;
        pow_dim = 2^tp - 1;
    end;
end;

% when the entire elements are not provided.
if sum(size(tp)==1)
    tp = gftuple([-1:n-1]',tp);
end;

    [n_tp, m_tp] = size(tp);
    tp_num = tp * 2.^[0 : m_tp-1]';
    tp_inv(tp_num+1) = 0:n_tp-1;

% variable assignment.
t2 = n - m_msg;
if t2 <= 0
    error('The code word length must be larger than the message length.');
end;

len_pg = length(pg);
pg = pg(:)';
pgg = fliplr(pg(1 : len_pg-1));    % make it to be descending ordered.
code = [-ones(n_msg, t2), msg];    % make room for code word.
ammend = -ones(1, t2);

for i = 1 : n_msg
    % process each row.
    a = [fliplr(msg(i, :)) ammend];

    % dividing a(X) by pg(X), note that pg(X) is a monic polynomial
    % we have put the calculation here for speeding, or can use gfdeconv.
    % a(X) has length n = m_msg + t2 (degree n-1)
    % pg(X) has length t2+1 (degree t2)
    % q(X) has length m_msg = n - t2 (degree m_msg - 1)
    % the remender has length t2, degree t2-1
    for j = 1 : m_msg
        if a(j) >= 0
            for k = 1 : t2
%                a(j + k) = gfadd(a(j + k), gfmul(a(j), pgg(k), tp), tp);
                if (a(j) < 0) | (pgg(k) < 0)
                    tmp = -1;
                else
                    tmp = rem(a(j) + pgg(k), n);
                end
                a(j + k) = gfplus(a(j + k), tmp, tp_num, tp_inv);
            end;
        end;
    end;
    code(i, 1:t2) = fliplr(a(m_msg+1:n));     % the remainder
end;

% -- end of rsencode --
