function out = fixpt_fir_mask_data(mgainval,doX);
% FIXPT_FIR_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:29 $

if isnumeric(doX)
    xx= [];
    yy= [];
    if size(mgainval,1) == 1 & isreal(mgainval)
        xNudge = 0.02;
        yNudge = 0.03;
        symbolMaxY = 0.25; %max(yy);
        xi = (1:size(mgainval,2))/(size(mgainval,2)+1);
        miny=min(min(mgainval),0);
        maxy=max(max(mgainval),0);
        deltay = maxy - miny;
        if deltay == 0
            deltay = 1;
        end
        yi = ( (mgainval) - miny ) / ( deltay );
        yi = (1-symbolMaxY-3*yNudge)*(yi) + symbolMaxY + 2*yNudge;
        yzero= ( (0) - miny ) / ( deltay );
        yzero= (1-symbolMaxY-3*yNudge)*(yzero) + symbolMaxY + 2*yNudge;
        for i=1:size(mgainval,2)
            xx = [xx NaN xi(i) xi(i) ];
            yy = [yy NaN yzero yi(i) ];
        end
        xx = [xx NaN xi(1) xi(length(xi)) ];
        yy = [yy NaN yzero yzero ];
    end
        
    if doX
        out = xx;
    else
        out = yy;
    end
else
    if length(mgainval) == 0
        out = ['\nFIR\n'];
    elseif size(mgainval,1) > 1
        out = ['SIMO\nFIR\n'];
    elseif ~isreal(mgainval)
        out = ['Complex\nFIR\n'];
    else
        out = '';
    end
end
