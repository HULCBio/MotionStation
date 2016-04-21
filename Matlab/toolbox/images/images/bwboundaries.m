function [B,L,N,A] = bwboundaries(varargin)
%BWBOUNDARIES Trace region boundaries in a binary image.
%   B = BWBOUNDARIES(BW) traces the exterior boundary of objects, 
%   as well as boundaries of holes inside these objects. It also descends 
%   into the outermost objects (parents) and traces their children (objects 
%   completely enclosed by the parents). BW must be a binary image where 
%   nonzero pixels belong to an object and 0-pixels constitute the 
%   background. B is a P-by-1 cell array, where P is the number of objects 
%   and holes. Each cell contains a Q-by-2 matrix, where Q is the number 
%   of boundary pixels for the corresponding region.  Each row of these 
%   Q-by-2 matrices contains the row and column coordinates of a boundary 
%   pixel.
%
%   B = BWBOUNDARIES(BW,CONN) specifies the connectivity to use when tracing
%   parent and child boundaries. CONN may be either 8 or 4. The default 
%   value for CONN is 8.
%
%   B = BWBOUNDARIES(BW,CONN,OPTIONS) provides an optional string
%   input. String 'noholes' speeds up the operation of the algorithm by 
%   having it search only for object (parent and child) boundaries. 
%   By default, or when 'holes' string is specified, the algorithm searches
%   for both object and hole boundaries.
%
%   [B,L] = BWBOUNDARIES(...) returns the label matrix, L, as the second 
%   output argument. Objects and holes are labeled. L is a 
%   two-dimensional array of nonnegative integers that represent
%   contiguous regions. The k-th region includes all elements in L that have
%   value k. The number of objects and holes represented by L is 
%   equal to max(L(:)). The zero-valued elements of L make up the background.  
%
%   [B,L,N,A] = BWBOUNDARIES(...) returns the number of objects found (N)
%   and an adjacency matrix A. The first N cells in B are object boundaries.
%   A represents the parent-child-hole dependencies. A is a square, sparse, 
%   logical matrix with side of length max(L(:)), whose rows and colums 
%   correspond to the position of boundaries stored in B. 
%   The boundaries enclosed by a B{m} as well as the boundary enclosing
%   B{m} can both be found using A as follows:
%
%      enclosing_boundary  = find(A(m,:));
%      enclosed_boundaries = find(A(:,m));
%
%   Class Support
%   -------------
%   BW can be logical or numeric and it must be real, 2-D, and nonsparse.
%   L, and N are double. A is sparse logical.
%
%   Example 1
%   ---------
%   Read in and threshold the rice.png image. Display the labeled
%   objects using the jet colormap, on a gray background, with region
%   boundaries outlined in white.
%
%      I = imread('rice.png');
%      BW = im2bw(I, graythresh(I));
%      [B,L] = bwboundaries(BW,'noholes');
%      imshow(label2rgb(L, @jet, [.5 .5 .5]))
%      hold on
%      for k = 1:length(B)
%          boundary = B{k};
%          plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
%      end
%
%   Example 2
%   ---------
%   Read in and display binary image blobs.png. Overlay the region 
%   boundaries on the image. Display text showing the region number
%   (based on the label matrix), next to every boundary. Additionally,
%   display the adjacency matrix using SPY.
%
%   HINT: After the image is displayed, use the zoom tool in order to read
%         individual labels.
%
%      BW = imread('blobs.png');
%      [B,L,N,A] = bwboundaries(BW);
%      imshow(BW); hold on;
%      colors=['b' 'g' 'r' 'c' 'm' 'y'];
%      for k=1:length(B),
%        boundary = B{k};
%        cidx = mod(k,length(colors))+1;
%        plot(boundary(:,2), boundary(:,1), colors(cidx),'LineWidth',2);
%        %randomize text position for better visibility
%        rndRow = ceil(length(boundary)/(mod(rand*k,7)+1));
%        col = boundary(rndRow,2); row = boundary(rndRow,1);
%        h = text(col+1, row-1, num2str(L(row,col)));
%        set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
%      end
%      figure; spy(A);
%
%   Example 3
%   ---------
%   Display object boundaries in red and hole boundaries in green.
%
%      BW = imread('blobs.png');
%      [B,L,N] = bwboundaries(BW);
%      imshow(BW); hold on;
%      for k=1:length(B),
%        boundary = B{k};
%        if(k > N)
%          plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
%        else
%          plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
%        end
%      end
%      
%   Example 4
%   ---------
%   Display parent boundaries in red (any empty row of adjacency
%   matrix belongs to a parent) and their holes in green.
%
%      BW = imread('blobs.png');
%      [B,L,N,A] = bwboundaries(BW);
%      imshow(BW); hold on;
%      for k=1:length(B),
%        if(~sum(A(k,:)))
%          boundary = B{k};
%          plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
%          for l=find(A(:,k))'
%            boundary = B{l};
%            plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
%          end
%        end
%      end
%
%   See also BWTRACEBOUNDARY, BWLABEL, BWLABELN.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/05/03 17:50:06 $

[BW, conn, findholes] = parseInputs(varargin{:});

[objs , L] = FindObjectBoundaries(BW, conn);

if (findholes)
  [holes, LabeledHoles] = FindHoleBoundaries(BW, conn);
  % Generate combined holes+objects label matrix
  L = L + (LabeledHoles~=0)*length(objs) + LabeledHoles;
else
  holes = {};
end

% Create the output matrix
B = [objs; holes];

% Return number of object boundaries
N = length(objs);

if(nargout > 3)
  % Produce an adjacency matrix showing parent-hole-child relationships
  A = CreateAdjMatrix(B, N);
end

%-----------------------------------------------------------------------------

function [BW, conn, findholes] = parseInputs(varargin)

checknargin(1,4,nargin,mfilename);

BW = varargin{1};

checkinput(BW, {'numeric','logical'}, {'real','2d','nonsparse'}, ...
           mfilename, 'BW', 1);

if ~islogical(BW)
  BW = BW ~= 0;
end

firstStringToProcess = 0;

if nargin < 2
  conn = 8;
else
  if ischar(varargin{2})
    firstStringToProcess = 2;
    conn = 8;
  else
    if nargin > 2,
      firstStringToProcess = 3; 
    end
    conn = varargin{2};
    checkinput(conn, {'double'}, {}, mfilename, 'CONN', 2);
    if (conn~=4 & conn~=8)
      eid = sprintf('Images:%s:badScalarConn', mfilename);
      msg = 'A scalar connectivity specifier CONN must either be 4 or 8';
      error(eid, msg);
    end
  end
end

findholes = true;

if firstStringToProcess
  validStrings = {'noholes', 'holes'};
  
  for k = firstStringToProcess:nargin
    % check for options
    string = checkstrs(varargin{k}, validStrings, mfilename, 'OPTION', k);
    switch string
     case 'noholes'
      findholes = false;
     case 'holes'
      findholes = true;
     otherwise
      error('Images:bwboundaries:unexpectedError', '%s', ...
            'Unexpected logic error.')
    end      
  end
end

%-----------------------------------------------------------------------------

function [A] = CreateAdjMatrix(B, numObjs)

A = sparse(false(length(B)));

levelCellArray = GroupBoundariesByTreeLevel(B, numObjs);

% scan through all the level pairs
for k = 1:length(levelCellArray)-1,

  parentsIdx = levelCellArray{k};     % outside boundaries
  childrenIdx = levelCellArray{k+1};  % inside boundaries
  
  parents  = B(parentsIdx);
  children = B(childrenIdx);
  
  sampChildren = GetSamplePointsFromBoundaries(children);
  
  for m=1:length(parents),
    parent = parents{m};
    inside = inpolygon(sampChildren(:,2), sampChildren(:,1),...
                     parent(:,2), parent(:,1));
    % casting to logical is necessary because of the bug, see GECK #137394
    inside = logical(inside);
    A(childrenIdx(inside), parentsIdx(m)) = true;
  end

end

%-----------------------------------------------------------------------------

function points = GetSamplePointsFromBoundaries(B)

points = zeros(length(B),2);

for m = 1:length(B),
  boundary = B{m};
  points(m,:) = boundary(1,:);
end

%-----------------------------------------------------------------------------

% Produces a cell array of indices into the boundaries cell array B.  The
% first element of the output cell array holds a double array of indices
% of boundaries which are the outermost (first layer of an onion), the
% second holds the second layer, and so on.

function idxGroupedByLevel = GroupBoundariesByTreeLevel(B, numObjs)


processHoles = ~(length(B) == numObjs);

% parse the input
objIdx  = 1:numObjs;
objs  = B(objIdx);

if processHoles
  holeIdx = numObjs+1:length(B);
  holes = B(holeIdx);
else
  holes = {};
end

% initialize output and loop control variables
idxGroupedByLevel = {};
done     = false;
findHole = false; % start with an object boundary

while ~done

  if (findHole)
    I = FindOutermostBoundaries(holes);
    holes = holes(~I); % remove processed boundaries

    idxGroupedByLevel = [ idxGroupedByLevel, {holeIdx(I)} ];
    holeIdx = holeIdx(~I);   % remove indices of processed boundaries
  else
    I = FindOutermostBoundaries(objs);
    objs = objs(~I);

    idxGroupedByLevel = [ idxGroupedByLevel, {objIdx(I)} ];
    objIdx = objIdx(~I);
  end

  if(processHoles)
    findHole = ~findHole;
  end
  
  if ( isempty(holes) && isempty(objs) )    
    done = true;
  end
  
end  
  
%-----------------------------------------------------------------------------

% Returns a logical vector showing the locations of outermost boundaries 
% in the input vector (ie 1 for the boundaries that are outermost and
% 0 for all other boundaries)
function I = FindOutermostBoundaries(B)

% Look for parent boundaries
I = false(1,length(B));

for m = 1:length(B),

  boundary = B{m};
  x = boundary(1,2); % grab a sample point for testing
  y = boundary(1,1);
  
  surrounded = false;
  for n = [1:(m-1), (m+1):length(B)], % exclude boundary under test
    boundary = B{n};
    if( inpolygon(x, y, boundary(:,2), boundary(:,1)) ),
        surrounded=true;
        break;
    end
  end
  
  I(m) = ~surrounded;
  
end

%-----------------------------------------------------------------------------

function [B, L] = FindObjectBoundaries(BW, conn)

L = bwlabel(BW, conn);
B = bwboundariesmex(L, conn);

%-----------------------------------------------------------------------------

function [B, L]= FindHoleBoundaries(BW, conn)

% Avoid topological errors.  If objects are 8 connected, then holes
% must be 4 connected and vice versa.
if (conn == 4)
  backgroundConn = 8;
else
  backgroundConn = 4;
end

% Turn holes into objects
BWcomplement = imcomplement(BW);

% clear unwanted "hole" objects from the border
BWholes = imclearborder(BWcomplement, backgroundConn);

% get the holes!
L = bwlabel(BWholes, backgroundConn);
B = bwboundariesmex(L, backgroundConn);
