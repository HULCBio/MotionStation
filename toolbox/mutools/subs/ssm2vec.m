% function vec = ssm2vec(mat)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function vec = ssm2vec(mat)

    [n,dum] = size(mat);
    vec = zeros(n*(n-1)/2,1);
    cnt = 1;
    for i=1:n-1
        vec(cnt:cnt+n-i-1) = mat(i,i+1:n)';
        cnt = cnt+n-i;
    end