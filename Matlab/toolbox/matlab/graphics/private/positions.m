function pj = positions( pj, handles )
%POSITIONS Determine the union of the PaperPositions of all objects passed in.
%   Sets GhostExtent and GhostTranslation fields of PrintJob object.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:49 $

%Assuming all have same paper orientation and type
%Make sure they all use Points.
savedUnits = getget(handles, 'paperunits');
setset(handles, 'paperunits','points')

unionPaperPos = LocalUnion( handles );
pSize = getget(handles(1),'papersize');
setset(handles, 'paperunits', savedUnits );

if strcmp( 'portrait', getget(handles(1),'paperorientation') )
    pj.GhostExtent = unionPaperPos([3 4]);
    pj.GhostTranslation = unionPaperPos([1 2]);
elseif strcmp( 'rotated', getget(handles(1),'paperorientation') )
    pj.GhostExtent = unionPaperPos([4 3]);
    pj.GhostTranslation = [ (unionPaperPos(1)-(pSize(1)-unionPaperPos(3))) unionPaperPos(2) ];
else
    pj.GhostExtent = unionPaperPos([4 3]);
    pj.GhostTranslation = [ unionPaperPos(1) (unionPaperPos(2) - (pSize(2)-unionPaperPos(4))) ];
end


function union = LocalUnion( handles )
%LocalUnion Get union of all PaperPositions

%Get cell array of positions
pp = getget( handles, 'paperposition' );

if length(handles) > 1
    %loop through and get extent
    union = [ inf inf -inf -inf ];
    for i = 1:length(pp)
        union(1) = min( union(1), pp{i}(1) );
        union(2) = min( union(2), pp{i}(2) );
        union(3) = max( union(3), pp{i}(1)+pp{i}(3) );
        union(4) = max( union(4), pp{i}(2)+pp{i}(4) );
    end
    
    %Found location of maximum upper right corner, get width and height
    union(3) = max( union(3) - union(1) );
    union(4) = max( union(4) - union(2) );
else
    %Just the one object with its own PaperPosition
    union = pp;
end
