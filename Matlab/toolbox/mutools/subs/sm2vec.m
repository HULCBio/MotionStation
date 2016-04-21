% function vec = sm2vec(mat)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function vec = sm2vec(mat)

    [n,dum] = size(mat);
    vec = zeros(n*(n+1)/2,1);
    cnt = 1;
    for i=1:n
        vec(cnt:cnt+n-i) = mat(i,i:n)';
        cnt = cnt+n-i+1;
    end