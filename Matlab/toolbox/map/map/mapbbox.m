function bbox = mapbbox(varargin)
%MAPBBOX Compute bounding box of a georeferenced image or data grid.
%
%   BBOX = MAPBBOX(R, HEIGHT, WIDTH) computes the 2-by-2 bounding box of
%   georeferenced image or regular gridded data set.  R is a 3-by-2 affine
%   referencing matrix.  HEIGHT and WIDTH are the image dimensions.  BBOX
%   bounds the outer edges of the image in map coordinates:
%
%                           [minX minY
%                            maxX maxY]
%
%   BBOX = MAPBBOX(R, SIZEA) accepts SIZEA = [HEIGHT, WIDTH, ...]
%   instead of HEIGHT and WIDTH.
%
%   BBOX = MAPBBOX(INFO) accepts a scalar struct array with the fields:
%
%              'RefMatrix'   A 3-by-2 referencing matrix
%              'Height'      A scalar number
%              'Width'       A scalar number
%
%   See also GEOTIFFINFO, MAKEREFMAT, MAPOUTLINE, PIXCENTERS, PIX2MAP.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:50:26 $ 

[R, h, w, unused] = parsePixMapInputs('MAPBBOX', [], varargin{:});

outline = [(0.5 + [0  0;...
                   0  w;...
                   h  w;...
                   h  0]), ones(4,1)] * R;

bbox = [min(outline); max(outline)];
