function do = dcwdo(FBR,latlim,lonlim)

%DCWDO finds the DCW elements overlapping a region
%
%

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:23:33 $

do = ...
 find( ...
		(...
		(latlim(1) <= [FBR.YMIN] & latlim(2) >= [FBR.YMAX]) | ... % tile is completely within region
		(latlim(1) >= [FBR.YMIN] & latlim(2) <= [FBR.YMAX]) | ... % region is completely within tile
		(latlim(1) >  [FBR.YMIN] & latlim(1) <  [FBR.YMAX]) | ... % min of region is on tile
		(latlim(2) >  [FBR.YMIN] & latlim(2) <  [FBR.YMAX])   ... % max of region is on tile
		) ...
			&...
		(...
		(lonlim(1) <= [FBR.XMIN] & lonlim(2) >= [FBR.XMAX]) | ... % tile is completely within region
		(lonlim(1) >= [FBR.XMIN] & lonlim(2) <= [FBR.XMAX]) | ... % region is completely within tile
		(lonlim(1) >  [FBR.XMIN] & lonlim(1) <  [FBR.XMAX]) | ... % min of region is on tile
		(lonlim(2) >  [FBR.XMIN] & lonlim(2) <  [FBR.XMAX])   ... % max of region is on tile
		)...
	);

do = do(find( do >1 ) );	% record one is the universe face, which does not correspond to a tile
