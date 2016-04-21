% function mknorm(fig)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function mknorm(fig)

    kids = get(fig,'children');
    for i=1:length(kids)
        if ~strcmp(get(kids(i),'Type'),'uimenu')
            set(kids(i),'units','normalized');
        end
    end