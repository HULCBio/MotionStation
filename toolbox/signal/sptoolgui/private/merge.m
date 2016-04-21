function x = merge(x1,x2)
%MERGE  Interleave elements.
%   x = merge(x1,x2) returns length N+M vector where x1 is length
%   N and x2 is length M and x = [x1(1) x2(1) x1(2) x2(2) ... ] or
%   x = [x2(1) x1(1) x2(2) x1(2) ...] depending on if x1(1) < x2(1).
%   Note that abs(M-N) must be 1 or less.
%
%   Example:  x1 = findpeaks(y); x2 = findpeaks(-y);  x = merge(x1,x2);

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

    L1 = length(x1);
    L2 = length(x2);
    if L1 == L2
        if x1(1) < x2(1)
            x = [x1(:).'; x2(:).'];
        else
            x = [x2(:).'; x1(:).'];
        end
        x = x(:);
    elseif L1 < L2
        x = [0 x1(:).'; x2(:).'];
        x=x(2:end);
    elseif L1 > L2
        x = [x1(:).'; x2(:).' 0];
        x = x(1:end-1);
    end
    
