% function val = goptvl(opt,tag,defval,nfval)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function val = goptvl(opt,tag,defval,nfval)

val = nfval;
if any(opt==tag(1))
    loc = find(opt==tag(1));
    if length(opt)>loc
        val = str2double(opt(loc+1));
        if isnan(val)
            val = defval;
        end
    else
        val = defval;
    end
end