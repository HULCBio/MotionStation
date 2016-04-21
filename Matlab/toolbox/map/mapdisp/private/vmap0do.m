function do = vmap0do(FBR,latlim,lonlim)

%VMAP0DO finds the VMAP0 elements overlapping a region
%
%

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:21:30 $

do = ...
 find( ...
		(...
		(latlim(1) <= [FBR.ymin] & latlim(2) >= [FBR.ymax]) | ... % tile is completely within region
		(latlim(1) >= [FBR.ymin] & latlim(2) <= [FBR.ymax]) | ... % region is completely within tile
		(latlim(1) >  [FBR.ymin] & latlim(1) <  [FBR.ymax]) | ... % min of region is on tile
		(latlim(2) >  [FBR.ymin] & latlim(2) <  [FBR.ymax])   ... % max of region is on tile
		) ...
			&...
		(...
		(lonlim(1) <= [FBR.xmin] & lonlim(2) >= [FBR.xmax]) | ... % tile is completely within region
		(lonlim(1) >= [FBR.xmin] & lonlim(2) <= [FBR.xmax]) | ... % region is completely within tile
		(lonlim(1) >  [FBR.xmin] & lonlim(1) <  [FBR.xmax]) | ... % min of region is on tile
		(lonlim(2) >  [FBR.xmin] & lonlim(2) <  [FBR.xmax])   ... % max of region is on tile
		)...
	);

do = do(find( do >1 ) );	% record one is the universe face, which does not correspond to a tile

