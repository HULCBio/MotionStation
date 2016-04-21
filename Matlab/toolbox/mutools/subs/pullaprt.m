% function out = pullaprt(message,in1,in2,in3)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = pullaprt(message,in1,in2,in3)

if strcmp(message,'find')
    strs = in1;
    cnt = 1;
    cmax = length(strs);
    delpair = [];
    while cnt+4<=cmax
        nxfchar = strs(cnt:cnt+4);
        if strcmp(nxfchar,'mname')
            delpair = [delpair;[cnt cnt+4 1]];
            cnt = cnt+5;
        elseif strcmp(nxfchar,'mdata')
            delpair = [delpair;[cnt cnt+4 2]];
            cnt = cnt+5;
        else
            cnt = cnt+1;
        end
    end
    out = delpair;
elseif strcmp(message,'fillin')
    strs = in1;
    delpair = in2;
    words = in3;
    numfil = size(delpair,1);
    out = [strs(1:delpair(1,1)-1) deblank(words(delpair(1,3),:))];
    for i=2:numfil
        out = [out strs(delpair(i-1,2)+1:delpair(i,1)-1) deblank(words(delpair(i,3),:))];
    end
    out = [out strs(delpair(numfil,2)+1:length(strs))];
end
