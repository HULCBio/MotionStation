function pr = cyclpoly(n, k, fd_flag)
%CYCLPOLY Produce generator polynomials for a cyclic code.
%   POL = CYCLPOLY(N, K) finds one cyclic code generator polynomial for a given
%   codeword length N and message length K.  POL represents the polynomial
%   by listing its coefficients in order of ascending exponents.
%
%   POL = CYCLPOLY(N, K, OPT) finds cyclic code generator polynomial(s) for
%   a given code word length N and message length K. The flag OPT
%   means:
%   OPT = 'min'  find one generator polynomial with the smallest possible weight.
%   OPT = 'max'  find one generator polynomial with the greatest possible weight.
%   OPT = 'all'  find all generator polynomials for the given codeword length
%                    and message length.
%   OPT = L      find all generator polynomials with weight L.
%
%   If OPT = 'all' or L, and more than one generator polynomial satisfies
%   the constraints, then each row of POL represents a different polynomial.
%   If no generator polynomial satisfies the constraints, then POL is empty.
%
%   A divisor of X^N-1 generates a cyclic code of codeword length N.
%
%   See also CYCLGEN, ENCODE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

% with message length k and code word length n, the degree of the cyclic
% generator polynomial length is m = n-k.
m = n - k;

if m < 0
    error('Message length cannot be shorter than code word length.');
elseif m == 0
    pr = 1;
elseif m == 1
    pr = [1 1];
elseif m >= 2
    pr = [];

    nn = 2^(m-1) - 1;
    pp = [1, zeros(1, n-1), 1];
    if nargin < 3
        % find one result and return
        for i = 1 : nn
            % try all possibilities
            test_bed = [1, fliplr(de2bi(i, m-1)), 1];
            [q, r] = gfdeconv(pp, test_bed);
            if max(r) == 0
                pr = [pr; test_bed];
                return;
            end;
        end;

    elseif isstr(fd_flag)
        fd_flag = lower(fd_flag);

        if fd_flag(1:2) == 'mi'
            % minimum term
            for j = 3 : m + 1
                for i = 1 : nn
                    % try all possibilities
                    test_bed = [1, fliplr(de2bi(i, m-1)), 1];
                    if sum(test_bed) == j
                        [q, r] = gfdeconv(pp, test_bed);
                        if max(r) == 0
                            pr = test_bed;
                            return;
                        end;
                    end;
                end;
            end

        elseif fd_flag(1:2) == 'ma'
            % maximum term
            for j = m+1 : -1 : 3
                for i = 1 : nn
                    % try all possibilities
                    test_bed = [1, de2bi(i, m-1), 1];
                    if sum(test_bed) == j
                        [q, r] = gfdeconv(pp, test_bed);
                        if max(r) == 0
                            pr = test_bed;
                            return
                        end;
                    end;
                end;
            end

        else
            for i = 1 : nn
                % exhaustive search
                test_bed = [1, fliplr(de2bi(i, m-1)), 1];
                [q, r] = gfdeconv(pp, test_bed);
                if max(r) == 0
                    pr = [pr; test_bed];
                end;
            end;
            %sort based on the minimum number of terms
            if ~isempty(pr)
                [x, i] = sort(sum(pr'));
                pr = pr(i, :);
            end;
        end;

    else
        % fd_flag is a number

        for i = 1 : nn
            % try all possibilities
            test_bed = [1, fliplr(de2bi(i, m-1)), 1];
            if sum(test_bed) == fd_flag
                [q, r] = gfdeconv(pp, test_bed);
                if max(r) == 0
                    pr = [pr; test_bed];
                end;
            end;
        end;
    end;
end;

if isempty(pr)
    disp('No generator polynomial satisfies the given constraints.');
end;

%--end of CYCLPOLY--


