function outstats = imfeature(varargin)
%IMFEATURE Compute feature measurements for image regions.
%   Note: This function is obsolete and may be removed in
%   future versions. Use REGIONPROPS instead.
%  
%   STATS = IMFEATURE(L,MEASUREMENTS) computes a set of
%   measurements for each labeled region in the label matrix
%   L. Positive integer elements of L correspond to different
%   regions. For example, the set of elements of L equal to 1
%   corresponds to region 1; the set of elements of L equal to 2
%   corresponds to region 2; and so on. STATS is a structure
%   array of length max(L(:)). The fields of the structure array
%   denote different measurements for each region, as specified
%   by MEASUREMENTS.
%
%   MEASUREMENTS can be a comma-separated list of strings, a cell
%   array containing strings, the string 'all', or the string
%   'basic'. The set of valid measurement strings includes:
%
%     'Area'              'ConvexHull'    'EulerNumber'
%     'Centroid'          'ConvexImage'   'Extrema'
%     'BoundingBox'       'ConvexArea'    'EquivDiameter'
%     'MajorAxisLength'   'Image'         'Solidity'
%     'MinorAxisLength'   'FilledImage'   'Extent'
%     'Orientation'       'FilledArea'    'PixelList'
%     'Eccentricity'
%
%   Measurement strings are case insensitive and can be
%   abbreviated.
%
%   If MEASUREMENTS is the string 'all', then all of the above
%   measurements are computed. If MEASUREMENTS is not specified
%   or if it is the string 'basic', then these measurements are 
%   computed: 'Area', 'Centroid', and 'BoundingBox'.
%
%   STATS = IMFEATURE(L,MEASUREMENTS,N) specifies the type of
%   connectivity used in computing the 'FilledImage',
%   'FilledArea', and 'EulerNumber' measurements. N can have a
%   value of either 4 or 8, where 4 specifies 4-connected objects
%   and 8 specifies 8-connected objects; if the argument is
%   omitted, it defaults to 8.
%
%   Class Support
%   -------------
%   The input label matrix L can be of class double or of any
%   integer class.
%
%   See also BWLABEL, ISMEMBER.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.6 $  $Date: 2003/12/13 02:43:11 $

wid = sprintf('Images:%s:obsoleteFunction',mfilename);
str1= sprintf('%s is obsolete and may be removed in the future.',mfilename);
str2 = 'See product release notes for more information.';
warning(wid,'%s\n%s',str1,str2);

officialStats = {'Area'
                 'Centroid'
                 'BoundingBox'
                 'MajorAxisLength'
                 'MinorAxisLength'
                 'Eccentricity'
                 'Orientation'
                 'ConvexHull'
                 'ConvexImage'
                 'ConvexArea'
                 'Image'
                 'FilledImage'
                 'FilledArea'
                 'EulerNumber'
                 'Extrema'
                 'EquivDiameter'
                 'Solidity'
                 'Extent'
                 'PixelList'};
tempStats = {'PerimeterCornerPixelList'};
allStats = [officialStats ; tempStats];

[L, requestedStats, n] = ParseInputs(officialStats, ...
        varargin{:});

if (isempty(L))
    numObjs = 0;
else
    numObjs = round(max(double(L(:))));
end

% Initialize the stats structure array.
numStats = length(allStats);
empties = cell(numStats, numObjs);
stats = cell2struct(empties, allStats, 1);

% Initialize the computedStats structure array.
zz = cell(numStats, 1);
for k = 1:numStats
    zz{k} = 0;
end
computedStats = cell2struct(zz, allStats, 1);

for k = 1:length(requestedStats)
    switch requestedStats{k}
        
    case 'Area'
        [stats, computedStats] = ComputeArea(L, stats, computedStats);
        
    case 'FilledImage'
        [stats, computedStats] = ComputeFilledImage(L,stats,computedStats,n);
        
    case 'FilledArea'
        [stats, computedStats] = ComputeFilledArea(L,stats,computedStats,n);
        
    case 'ConvexArea'
        [stats, computedStats] = ComputeConvexArea(L, stats, computedStats);
        
    case 'Centroid'
        [stats, computedStats] = ComputeCentroid(L, stats, computedStats);
        
    case 'EulerNumber'
        [stats, computedStats] = ComputeEulerNumber(L,stats,computedStats,n);
        
    case 'EquivDiameter'
        [stats, computedStats] = ComputeEquivDiameter(L, stats, computedStats);
        
    case 'Extrema'
        [stats, computedStats] = ComputeExtrema(L, stats, computedStats);
        
    case 'BoundingBox'
        [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);
        
    case {'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Eccentricity'}
        [stats, computedStats] = ComputeEllipseParams(L, stats, computedStats);
        
    case 'Solidity'
        [stats, computedStats] = ComputeSolidity(L, stats, computedStats);
        
    case 'Extent'
        [stats, computedStats] = ComputeExtent(L, stats, computedStats);
        
    case 'ConvexImage'
        [stats, computedStats] = ComputeConvexImage(L, stats, computedStats);
        
    case 'ConvexHull'
        [stats, computedStats] = ComputeConvexHull(L, stats, computedStats);
        
    case 'Image'
        [stats, computedStats] = ComputeImage(L, stats, computedStats);

    case 'PixelList'
        [stats, computedStats] = ComputePixelList(L, stats, computedStats);
        
    end
end

% Initialize the output stats structure array.
numStats = length(requestedStats);
empties = cell(numStats, numObjs);
outstats = cell2struct(empties, requestedStats, 1);

% Initialize the subsref structure.
s(1).type = '()';
s(1).subs = {};
s(2).type = '.';
s(2).subs = '';

% Copy only the requested stats into the output.
for k = 1:numObjs
    for p = 1:length(requestedStats)
        s(1).subs = {k};
        s(2).subs = {requestedStats{p}};
        
        % In normal MATLAB syntax, the line below is the same as:
        %    outstats(k).fieldname = stats(k).fieldname
        % where fieldname is the string contained in
        % requestedStats{p}.  If you don't give subsasgn an
        % output argument it changes its first input argument
        % in-place.
        subsasgn(outstats, s, subsref(stats, s));
    end
end
    
%%%
%%% ComputeArea
%%%
function [stats, computedStats] = ComputeArea(L, stats, computedStats)
%   The area is defined to be the number of pixels belonging to
%   the region.

if ~computedStats.Area
    computedStats.Area = 1;

    [stats, computedStats] = ComputePixelList(L, stats, computedStats);

    for k = 1:length(stats)
        stats(k).Area = size(stats(k).PixelList, 1);
    end
end

%%%
%%% ComputeEquivDiameter
%%%
function [stats, computedStats] = ComputeEquivDiameter(L, stats, computedStats)
%   Computes the diameter of the circle that has the same area as
%   the region.
%   Ref: Russ, The Image Processing Handbook, 2nd ed, 1994, page
%   511.

if ~computedStats.EquivDiameter
    computedStats.EquivDiameter = 1;
    
    [stats, computedStats] = ComputeArea(L, stats, computedStats);

    factor = 2/sqrt(pi);
    for k = 1:length(stats)
        stats(k).EquivDiameter = factor * sqrt(stats(k).Area);
    end
end

%%%
%%% ComputeFilledImage
%%%
function [stats, computedStats] = ComputeFilledImage(L,stats,computedStats,n)
%   Uses bwfill with the 'holes' option to fill holes in the
%   region.  The last argument, n, specifies the foreground
%   connectivity and may be either 4 or 8.

if ~computedStats.FilledImage
    computedStats.FilledImage = 1;
    
    [stats, computedStats] = ComputeImage(L, stats, computedStats);
    
    for k = 1:length(stats)
        stats(k).FilledImage = bwfill(stats(k).Image,'holes',n);
    end
end

%%%
%%% ComputeConvexArea
%%%
function [stats, computedStats] = ComputeConvexArea(L, stats, computedStats)
%   Computes the number of "on" pixels in ConvexImage.

if ~computedStats.ConvexArea
    computedStats.ConvexArea = 1;
    
    [stats, computedStats] = ComputeConvexImage(L, stats, computedStats);
    
    for k = 1:length(stats)
        stats(k).ConvexArea = sum(stats(k).ConvexImage(:));
    end
end

%%%
%%% ComputeFilledArea
%%%
function [stats, computedStats] = ComputeFilledArea(L,stats,computedStats,n)
%   Computes the number of "on" pixels in FilledImage.

if ~computedStats.FilledArea
    computedStats.FilledArea = 1;
    
    [stats, computedStats] = ComputeFilledImage(L,stats,computedStats,n);

    for k = 1:length(stats)
        stats(k).FilledArea = sum(stats(k).FilledImage(:));
    end
end

%%%
%%% ComputeConvexImage
%%%
function [stats, computedStats] = ComputeConvexImage(L, stats, computedStats)
%   Uses ROIPOLYOLD to fill in the convex hull.

if ~computedStats.ConvexImage
    computedStats.ConvexImage = 1;
    
    [stats, computedStats] = ComputeConvexHull(L, stats, computedStats);
    [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);
    
    for k = 1:length(stats)
        M = stats(k).BoundingBox(4);
        N = stats(k).BoundingBox(3);
        hull = stats(k).ConvexHull;
        if (isempty(hull))
            stats(k).ConvexImage = false(M,N);
        else
            firstRow = stats(k).BoundingBox(2) + 0.5;
            firstCol = stats(k).BoundingBox(1) + 0.5;
            r = hull(:,2) - firstRow + 1;
            c = hull(:,1) - firstCol + 1;
            
            ws = warning('off','Images:roipolyold:obsoleteFunction');
            stats(k).ConvexImage = roipolyold(M, N, c, r);
            warning(ws);
        end
    end
end

%%%
%%% ComputeCentroid
%%%
function [stats, computedStats] = ComputeCentroid(L, stats, computedStats)
%   [mean(r) mean(c)]

if ~computedStats.Centroid
    computedStats.Centroid = 1;
    
    [stats, computedStats] = ComputePixelList(L, stats, computedStats);
    
    for k = 1:length(stats)
        if (isempty(stats(k).PixelList))
            % The reason for the empty special case is that the call
            % to mean below returns a scalar NaN and we need a 1-by-2
            % NaN.
            stats(k).Centroid = [NaN NaN];
        else
            stats(k).Centroid = mean(stats(k).PixelList,1);
        end
    end
end

%%%
%%% ComputeEulerNumber
%%%
function [stats, computedStats] = ComputeEulerNumber(L,stats,computedStats,n)
%   Calls BWEULER on 'Image'; last argument specifies foreground
%   connectivity and may be 4 or 8.

if ~computedStats.EulerNumber
    computedStats.EulerNumber = 1;
    
    [stats, computedStats] = ComputeImage(L, stats, computedStats);
    
    for k = 1:length(stats)
        stats(k).EulerNumber = bweuler(stats(k).Image,n);
    end
end

%%%
%%% ComputeExtrema
%%%
function [stats, computedStats] = ComputeExtrema(L, stats, computedStats)
%   A 8-by-2 array; each row contains the x and y spatial
%   coordinates for these extrema:  leftmost-top, rightmost-top,
%   topmost-right, bottommost-right, rightmost-bottom, leftmost-bottom,
%   bottommost-left, topmost-left. 
%   reference: Haralick and Shapiro, Computer and Robot Vision
%   vol I, Addison-Wesley 1992, pp. 62-64.

if ~computedStats.Extrema
    computedStats.Extrema = 1;
    
    [stats, computedStats] = ComputePixelList(L, stats, computedStats);
    
    for k = 1:length(stats)
        pixelList = stats(k).PixelList;
        if (isempty(pixelList))
            stats(k).Extrema = zeros(8,2) + 0.5;
        else
            r = pixelList(:,2);
            c = pixelList(:,1);
            
            minR = min(r);
            maxR = max(r);
            minC = min(c);
            maxC = max(c);
            
            minRSet = find(r==minR);
            maxRSet = find(r==maxR);
            minCSet = find(c==minC);
            maxCSet = find(c==maxC);

            % Points 1 and 2 are on the top row.
            r1 = minR;
            r2 = minR;
            % Find the minimum and maximum column coordinates for
            % top-row pixels.
            tmp = c(minRSet);
            c1 = min(tmp);
            c2 = max(tmp);
            
            % Points 3 and 4 are on the right column.
            % Find the minimum and maximum row coordinates for
            % right-column pixels.
            tmp = r(maxCSet);
            r3 = min(tmp);
            r4 = max(tmp);
            c3 = maxC;
            c4 = maxC;

            % Points 5 and 6 are on the bottom row.
            r5 = maxR;
            r6 = maxR;
            % Find the minimum and maximum column coordinates for
            % bottom-row pixels.
            tmp = c(maxRSet);
            c5 = max(tmp);
            c6 = min(tmp);
            
            % Points 7 and 8 are on the left column.
            % Find the minimum and maximum row coordinates for
            % left-column pixels.
            tmp = r(minCSet);
            r7 = max(tmp);
            r8 = min(tmp);
            c7 = minC;
            c8 = minC;
            
            stats(k).Extrema = [c1-0.5 r1-0.5
                c2+0.5 r2-0.5
                c3+0.5 r3-0.5
                c4+0.5 r4+0.5
                c5+0.5 r5+0.5
                c6-0.5 r6+0.5
                c7-0.5 r7+0.5
                c8-0.5 r8-0.5];
        end
    end
    
end
        
%%%
%%% ComputeBoundingBox
%%%
function [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats)
%   [minC minR width height]; minC and minR end in .5.

if ~computedStats.BoundingBox
    computedStats.BoundingBox = 1;
    
    [stats, computedStats] = ComputePixelList(L, stats, computedStats);
    
    for k = 1:length(stats)
        list = stats(k).PixelList;
        if (isempty(list))
            stats(k).BoundingBox = [0.5 0.5 0 0];
        else
            rows = list(:,2);
            cols = list(:,1);
            minR = min(rows) - 0.5;
            maxR = max(rows) + 0.5;
            minC = min(cols) - 0.5;
            maxC = max(cols) + 0.5;
            stats(k).BoundingBox = [minC minR (maxC-minC) (maxR-minR)];
        end
    end
end

%%%
%%% ComputeEllipseParams
%%%
function [stats, computedStats] = ComputeEllipseParams(L, stats, ...
        computedStats)
%   Find the ellipse that has the same 2nd-order moments as the
%   region.  Compute the axes lengths, orientation, and
%   eccentricity of the ellipse.
%   Ref: Haralick and Shapiro, Computer and Robot Vision
%   vol I, Addison-Wesley 1992, Appendix A.


if ~(computedStats.MajorAxisLength && computedStats.MinorAxisLength && ...
            computedStats.Orientation && computedStats.Eccentricity)
    computedStats.MajorAxisLength = 1;
    computedStats.MinorAxisLength = 1;
    computedStats.Eccentricity = 1;
    computedStats.Orientation = 1;
    
    [stats, computedStats] = ComputePixelList(L, stats, computedStats);
    [stats, computedStats] = ComputeCentroid(L, stats, computedStats);
    
    for k = 1:length(stats)
        list = stats(k).PixelList;
        if (isempty(list))
            stats(k).MajorAxisLength = 0;
            stats(k).MinorAxisLength = 0;
            stats(k).Eccentricity = 0;
            stats(k).Orientation = 0;
            
        else
            % Assign X and Y variables so that we're measuring orientation
            % counterclockwise from the horizontal axis.
            
            xbar = stats(k).Centroid(1);
            ybar = stats(k).Centroid(2);
            
            x = list(:,1) - xbar;
            y = -(list(:,2) - ybar);
            
            N = length(x);
            uxx = sum(x.^2)/N + 1/12;
            uyy = sum(y.^2)/N + 1/12;
            uxy = sum(x.*y)/N;
            
            common = sqrt((uxx - uyy)^2 + 4*uxy^2);
            stats(k).MajorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy + common);
            stats(k).MinorAxisLength = 2*sqrt(2)*sqrt(uxx + uyy - common);
            stats(k).Eccentricity = 2*sqrt((stats(k).MajorAxisLength/2)^2 - ...
                    (stats(k).MinorAxisLength/2)^2) / ...
                    stats(k).MajorAxisLength;
            
            if (uyy > uxx)
                stats(k).Orientation = (180/pi)*atan2(uyy - uxx + ...
                        sqrt((uyy - uxx)^2 + 4*uxy^2), 2*uxy);
            else
                stats(k).Orientation = (180/pi)*atan2(2*uxy, ...
                        uxx - uyy + sqrt((uxx - uyy)^2 + 4*uxy^2));
            end
        end
    end
    
end
    
%%%
%%% ComputeSolidity
%%%
function [stats, computedStats] = ComputeSolidity(L, stats, computedStats)
%   Area / ConvexArea

if ~computedStats.Solidity
    computedStats.Solidity = 1;
    
    [stats, computedStats] = ComputeArea(L, stats, computedStats);
    [stats, computedStats] = ComputeConvexArea(L, stats, computedStats);
    
    for k = 1:length(stats)
        if (stats(k).ConvexArea == 0)
            stats(k).Solidity = NaN;
        else
            stats(k).Solidity = stats(k).Area / stats(k).ConvexArea;
        end
    end
end

%%%
%%% ComputeExtent
%%%
function [stats, computedStats] = ComputeExtent(L, stats, computedStats)
%   Area / (BoundingBox(3) * BoundingBox(4))

if ~computedStats.Extent
    computedStats.Extent = 1;
    
    [stats, computedStats] = ComputeArea(L, stats, computedStats);
    [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);
    
    for k = 1:length(stats)
        if (stats(k).Area == 0)
            stats(k).Extent = NaN;
        else
            stats(k).Extent = stats(k).Area / prod(stats(k).BoundingBox(3:4));
        end
    end
end

%%%
%%% ComputeImage
%%%
function [stats, computedStats] = ComputeImage(L, stats, computedStats)
%   Binary image containing "on" pixels corresponding to pixels
%   belonging to the region.  The size of the image corresponds
%   to the size of the bounding box for each region.

if ~computedStats.Image
    computedStats.Image = 1;

    [stats, computedStats] = ComputePixelList(L, stats, computedStats);
    [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);

    for k = 1:length(stats)
        M = stats(k).BoundingBox(4);
        N = stats(k).BoundingBox(3);
        firstRow = stats(k).BoundingBox(2) + 0.5;
        firstCol = stats(k).BoundingBox(1) + 0.5;
        
        stats(k).Image = uint8(zeros(M,N));
        
        r = stats(k).PixelList(:,2);
        c = stats(k).PixelList(:,1);
        r = r - firstRow + 1;
        c = c - firstCol + 1;
        
        idx = M * (c - 1) + r;
        stats(k).Image(idx) = 1;
        stats(k).Image = logical(stats(k).Image);
    end
end

%%%
%%% ComputePixelList
%%%
function [stats, computedStats] = ComputePixelList(L, stats, computedStats)
%   A P-by-2 matrix, where P is the number of pixels belonging to
%   the region.  Each row contains the row and column
%   coordinates of a pixel.

if ~computedStats.PixelList
    computedStats.PixelList = 1;
    
    % Form a sparse matrix containing one column per region.  In
    % column P, the location of nonzero values correspond to the
    % linear indices of pixels in L that have value P.  For
    % example, S(100,5) is nonzero if and only L(100) equals 5.
    idx = find(L);
    elementValues = L(idx);
    S = sparse(idx, double(elementValues), 1);

    % Loop over each column of the sparse matrix.  Finding the
    % row indices of the nonzero entries in S(:,P) is equivalent
    % to finding the linear indices of pixels in L that equal P.
    % Convert the linear indices to row-column indices and store
    % the results in the pixel list.
    M = size(L,1);
    for k = 1:length(stats)
        idx = find(S(:,k)) - 1;
        c = floor(idx/M) + 1;
        r = rem(idx,M) + 1;
        stats(k).PixelList = [c(:) r(:)];
    end
end

%%%
%%% ComputePerimeterCornerPixelList
%%%
function [stats, computedStats] = ComputePerimeterCornerPixelList(L, ...
        stats, computedStats)
%   Find the pixels on the perimeter of the region; make a list
%   of the coordinates of their corners; sort and remove
%   duplicates.

if ~computedStats.PerimeterCornerPixelList
    computedStats.PerimeterCornerPixelList = 1;

    [stats, computedStats] = ComputeImage(L, stats, computedStats);
    [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);

    for k = 1:length(stats)
        perimImage = bwmorph(stats(k).Image, 'perim8');
        firstRow = stats(k).BoundingBox(2) + 0.5;
        firstCol = stats(k).BoundingBox(1) + 0.5;
        [r,c] = find(perimImage);
        % Force rectangular empties.
        r = r(:) + firstRow - 1;
        c = c(:) + firstCol - 1;
        r1 = r - 0.5;
        r2 = r + 0.5;
        c1 = c - 0.5;
        c2 = c + 0.5;
        rr = [r1 ; r1 ; r2 ; r2];
        cc = [c1 ; c2 ; c1 ; c2];
        
        stats(k).PerimeterCornerPixelList = [cc rr];
    end
    
end

%%%
%%% ComputeConvexHull
%%%
function [stats, computedStats] = ComputeConvexHull(L, stats, computedStats)
%   A P-by-2 array representing the convex hull of the region.
%   The first column contains row coordinates; the second column
%   contains column coordinates.  The resulting polygon goes
%   through pixel corners, not pixel centers.

if ~computedStats.ConvexHull
    computedStats.ConvexHull = 1;

    [stats, computedStats] = ComputePerimeterCornerPixelList(L, stats, ...
            computedStats);
    [stats, computedStats] = ComputeBoundingBox(L, stats, computedStats);

    for k = 1:length(stats)
        list = stats(k).PerimeterCornerPixelList;
        if (isempty(list))
            stats(k).ConvexHull = zeros(0,2);
        else
            rr = list(:,2);
            cc = list(:,1);
            hullIdx = convhull(rr, cc);
            stats(k).ConvexHull = list(hullIdx,:);
        end
    end
end

%%%
%%% ParseInputs
%%%
function [L,reqStats,n] = ParseInputs(officialStats, varargin)

L = [];
reqStats = [];
n = 8;

if (nargin < 1)
    eid = 'Images:imfeature:tooFewInputs';
    msg = 'Too few input arguments.';
    error(eid, '%s', msg);
end

if (nargin >= 2)
    % Check for trailing connectivity argument; strip it off if present.
    if (isequal(varargin{end},4) || isequal(varargin{end},8))
        n = varargin{end};
        varargin(end) = [];
    end
end
   
L = varargin{1};
if (~isnumeric(L))
    eid = 'Images:imfeature:expectedNumeric';
    msg = 'Invalid input.';
    error(eid, '%s', msg);
    return;
end

list = varargin(2:end);
if (~isempty(list) && ~iscell(list{1}) && strcmp(lower(list{1}), 'all'))
    reqStats = officialStats;
    
elseif (isempty(list) || (~iscell(list{1}) && strcmp(lower(list{1}),'basic')))
    % Default list
    reqStats = {'Area'
                'Centroid'
                'BoundingBox'};
else
    
    if (iscell(list{1}))
        list = list{1};
    end
    list = list(:);

    officialStatsL = lower(officialStats);

    reqStatsIdx = [];
    for k = 1:length(list)
        if (~ischar(list{k}))
            eid = 'Images:imfeature:invalidInput';
            msg = 'Invalid input argument.';
            error(eid, '%s', msg);
        end
        
        idx = strmatch(lower(list{k}), officialStatsL);
        if (isempty(idx))
            eid = 'Images:imfeature:unknownMeasurement';
            msg = sprintf('Unknown measurement: "%s".', list{k});
            error(eid, '%s', msg);
        
        elseif (length(idx) > 1)
            eid = 'Images:imfeature:ambiguousMeasurement';
            msg = sprintf('Ambiguous measurement: "%s".', list{k});
            error(eid, '%s', msg);
            
        else
            reqStatsIdx = [reqStatsIdx; idx];
        end
    end
    
    reqStats = officialStats(reqStatsIdx);
end
