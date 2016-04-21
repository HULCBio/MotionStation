function out = fixpt_mul_mask_data(XLookUpData,YLookUpData,doX,interpType);
% FIXPT_LOOK1_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:50 $

if nargin < 4
  interpType = 2; % Interp use end points
end

if interpType == 3 % Nearest

    lx = length(XLookUpData);
    xnew(1:2:(2*lx))  = XLookUpData;
    xnew(2:2:(end-1)) = XLookUpData(1:(end-1))+diff(XLookUpData)/2;
    ynew(1:2:(2*lx))  = YLookUpData;
    ynew(2:2:(end-1)) = YLookUpData(2:end);
    [XLookUpData,YLookUpData]=stairs(xnew,ynew);

elseif  interpType == 4 % Below

    [XLookUpData,YLookUpData]=stairs(XLookUpData,YLookUpData);

elseif  interpType == 5 % Above

    YLookUpData(end+1) = YLookUpData(end);
    XLookUpData(2:(end+1)) = XLookUpData;
    [XLookUpData,YLookUpData]=stairs(XLookUpData,YLookUpData);

end

xx= [];
yy= [];
if size(XLookUpData,1) > 1
    XLookUpData = XLookUpData.';
end
if size(YLookUpData,1) > 1
    YLookUpData = YLookUpData.';
end
if size(XLookUpData,1) & size(YLookUpData,1)
    if ~isreal(YLookUpData)
        YLookUpData = [ real(YLookUpData); imag(YLookUpData) ];
    end    
    [r,c]=size(YLookUpData);
    xNudge = 0.02;
    yNudge = 0.03;
    symbolMaxY = 0.25; %max(yy);
    minx=min(XLookUpData);
    maxx=max(XLookUpData);
    deltax = maxx - minx;
    if deltax == 0
        deltax = 1;
    end
    xi= (1-2*xNudge)*(XLookUpData - minx ) / deltax + xNudge;
    miny=min(min(YLookUpData));
    maxy=max(max(YLookUpData));
    deltay = maxy - miny;
    if deltay == 0
        deltay = 1;
    end
    for i=1:r
        yi = ( YLookUpData(i,:) - miny ) / deltay;
        yi = (1-symbolMaxY-3*yNudge)*yi + symbolMaxY + 2*yNudge;
        xx = [xx NaN xi ];
        yy = [yy NaN yi ];
    end
    xzero= (1-2*xNudge)*(-minx) / deltax + xNudge;
    yzero= (-miny) / deltay;
    yzero= (1-symbolMaxY-3*yNudge)*yzero + symbolMaxY + 2*yNudge;
    xx = [xx NaN xzero xzero ];
    yy = [yy NaN 1-yNudge (symbolMaxY+2*yNudge) ];
    if (yzero >= (symbolMaxY+2*yNudge)) & (yzero <= (1-yNudge))
        xx = [xx NaN xNudge 1-xNudge ];
        yy = [yy NaN yzero yzero ];
    end
end
    
if doX
    out = xx;
else
    out = yy;
end
