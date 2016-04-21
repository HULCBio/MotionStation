function wt = gfweight(g, gh_flag)
%GFWEIGHT Calculate the minimum distance of a linear block code.
%   WT = GFWEIGHT(G) outputs the minimum distance of the given generator
%   matrix G.
%   WT = GFWEIGHT(G, GH_FLAG) outputs the minimum distance, where GH_FLAG is
%   used to specify the feature of the first input parameter.
%   When GH_FLAG == 'gen', G is a generator matrix.
%   When GH_FLAG == 'par', G is a parity-check matrix.
%   When GH_FLAG == n, which represents the code word length, G is a
%   generator polynomial for a cyclic or BCH code.
%
%   See also HAMMGEN, CYCLPOLY.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $ Date: $

if nargin < 1
    error('Not enough input parameters')
elseif nargin < 2
    gh_flag = 'gen';        % default as generator matrix
end;

if ~isstr(gh_flag)
    [h, g] = cyclgen(gh_flag, g);
    clear h;
elseif lower(gh_flag(1:2)) == 'pa'
    g = gen2par(g);
end;

[n, m]= size(g);
if n < 10
    x = [1 : 2^n - 1]';
    x = de2bi(x, n);
    x = rem(x * g, 2);
    wt = min(sum(x'));
else
    wt = n;
    for i = 1 : 2^n -1
        wt = min(wt, sum(rem(de2bi(i, n) * g, 2)));
    end;
end;
%--- end of gfweight--
