function cfsavefit(varnames,cfit)
%CFSAVEFIT

%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:40:01 $
%   Copyright 2001-2004 The MathWorks, Inc.

% CFSAVEFIT(VARNAMES,CFIT)

cf = handle(cfit);
for i = 1 : length(varnames)
    if ~isempty(varnames{i})
        switch i
        case 1
            out = cf.fit;
        case 2
            out = cf.goodness;
        case 3
            out = cf.output;
        otherwise
            error('Unknown part of fit asked for')
        end
        assignin('base',varnames{i},out);
    end
end
