% function vecout = comple(vecin,n)
%   VECOUT is the complementary (to VECIN) set of
%   integers, with respect to the set 1:n. VECOUT
%   is returned as a row vector.   subroutine for
%   INDVCMP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = comple(in,n)
    if isempty(in)
        out = 1:n;
    else
        in = sort(in);
        lout = n - length(in);
        out = zeros(1,lout);
        if ~isempty(out)
            loc = 1;
            if in(1) ~= 1;
                out(loc:loc+in(1)-1-1) = 1:in(1)-1;
                loc = loc + in(1)-1;
            end
            for i=2:length(in)
                len = in(i) - in(i-1) - 1;
                out(loc:loc+len-1) = in(i-1)+1:in(i)-1;
                loc = loc + len;
            end
            out(loc:lout) = (in(length(in))+1):n;
        end
    end
%
%