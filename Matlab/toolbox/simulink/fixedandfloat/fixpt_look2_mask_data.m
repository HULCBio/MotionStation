function out = fixpt_look2_mask_data(RowLookUpData,TableLookUpData,doX);
% FIXPT_LOOK2_MASK_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:53 $

xx= [];
yy= [];
[r,c]=size(TableLookUpData);
if r & size(RowLookUpData,1)
    if size(RowLookUpData,1) > 1
        RowLookUpData = RowLookUpData.';
    end
    if r ~= size(RowLookUpData,2)
        TableLookUpData = TableLookUpData.';
        [r,c]=size(TableLookUpData);
    end
    if ~isreal(TableLookUpData)
        TableLookUpData = [ real(TableLookUpData) imag(TableLookUpData) ];
        [r,c]=size(TableLookUpData);
    end
    xNudge = 0.02;
    yNudge = 0.03;
    symbolMaxY = 0.25; %max(yy);
    minx=min(RowLookUpData);
    maxx=max(RowLookUpData);
    deltax = maxx - minx;
    if deltax == 0
        deltax = 1;
    end
    xi= (1-2*xNudge)*(RowLookUpData - minx ) / deltax + xNudge;
    miny=min(min(TableLookUpData));
    maxy=max(max(TableLookUpData));
    deltay = maxy - miny;
    if deltay == 0
        deltay = 1;
    end
    for i=1:c;
        yi = ( (TableLookUpData(:,i).') - miny ) / deltay;
        yi = (1-symbolMaxY-3*yNudge)*(yi) + symbolMaxY + 2*yNudge;
        xx = [xx NaN xi ];
        yy = [yy NaN yi ];
    end
    xx = [xx NaN xNudge xNudge 1-xNudge ];
    yy = [yy NaN 1-yNudge (symbolMaxY+2*yNudge) (symbolMaxY+2*yNudge) ];
end
    
if doX
    out = xx;
else
    out = yy;
end
