function se = strel(varargin)
%STREL Create morphological structuring element.
%   SE = STREL('arbitrary',NHOOD) creates a flat structuring element with
%   the specified neigbhorhood.  NHOOD is a matrix containing 1's and 0's;
%   the location of the 1's defines the neighborhood for the morphological
%   operation.  The center (or origin) of NHOOD is it's center element,
%   given by FLOOR((SIZE(NHOOD) + 1)/2).  You can also omit the 'arbitrary'
%   string and just use STREL(NHOOD).
%
%   SE = STREL('arbitrary',NHOOD,HEIGHT) creates a nonflat structuring
%   element with the specified neighborhood.  HEIGHT is a matrix the same
%   size as NHOOD containing the height values associated with each nonzero
%   element of NHOOD.  HEIGHT must be real and finite-valued.  You can also
%   omit the 'arbitrary' string and just use STREL(NHOOD,HEIGHT).
%
%   SE = STREL('ball',R,H,N) creates a nonflat "ball-shaped" (actually an
%   ellipsoid) structuring element whose radius in the X-Y plane is R and
%   whose height is H.  R must be a nonnegative integer, and H must be a
%   real scalar.  N must be an even nonnegative integer.  When N is greater
%   than 0, the ball-shaped structuring element is approximated by a
%   sequence of N nonflat line-shaped structuring elements.  When N is 0, no
%   approximation is used, and the structuring element members comprise all
%   pixels whose centers are no greater than R away from the origin, and the
%   corresponding height values are determined from the formula of the
%   ellipsoid specified by R and H.  If N is not specified, the default
%   value is 8.  Note: Morphological operations using ball approximations
%   (N>0) run much faster than when N=0.
%
%   SE = STREL('diamond',R) creates a flat diamond-shaped structuring
%   element with the specified size, R.  R is the distance from the
%   structuring element origin to the points of the diamond.  R must be a
%   nonnegative integer scalar.
%
%   SE = STREL('disk',R,N) creates a flat disk-shaped structuring element
%   with the specified radius, R.  R must be a nonnegative integer.  N must
%   be 0, 4, 6, or 8.  When N is greater than 0, the disk-shaped structuring
%   element is approximated by a sequence of N (or sometimes N+2)
%   periodic-line structuring elements.  When N is 0, no approximation is
%   used, and the structuring element members comprise all pixels whose
%   centers are no greater than R away from the origin.  N can be omitted,
%   in which case its default value is 4.  Note: Morphological operations
%   using disk approximations (N>0) run much faster than when N=0.  Also,
%   the structuring elements resulting from choosing N>0 are suitable for
%   computing granulometries, which is not the case for N=0.  Sometimes it
%   is necessary for STREL to use two extra line structuring elements in the
%   approximation, in which case the number of decomposed structuring
%   elements used is N+2.
%
%   SE = STREL('line',LEN,DEG) creates a flat linear structuring element
%   with length LEN.  DEG specifies the angle (in degrees) of the line as
%   measured in a counterclockwise direction from the horizontal axis.
%   LEN is approximately the distance between the centers of the
%   structuring element members at opposite ends of the line.
%
%   SE = STREL('octagon',R) creates a flat octagonal structuring element
%   with the specified size, R.  R is the distance from the structuring
%   element origin to the sides of the octagon, as measured along the
%   horizontal and vertical axes.  R must be a nonnegative multiple of 3.
%
%   SE = STREL('pair',OFFSET) creates a flat structuring element containing
%   two members.  One member is located at the origin; the second member's
%   location is specified by the vector OFFSET.  OFFSET must be a
%   two-element vector of integers.
%
%   SE = STREL('periodicline',P,V) creates a flat structuring element
%   containing 2*P+1 members.  V is a two-element vector containing
%   integer-valued row and column offsets.  One structuring element member
%   is located at the origin.  The other members are located at 1*V, -1*V,
%   2*V, -2*V, ..., P*V, -P*V.
%
%   SE = STREL('rectangle',MN) creates a flat rectangle-shaped structuring
%   element with the specified size.  MN must be a two-element vector of
%   nonnegative integers.  The first element of MN is the number rows in the
%   structuring element neighborhood; the second element is the number of
%   columns.
%
%   SE = STREL('square',W) creates a square structuring element whose
%   width is W pixels.  W must be a nonnegative integer scalar.
%
%   Notes
%   -----
%   For all shapes except 'arbitrary', structuring elements are constructed
%   using a family of techniques known collectively as "structuring element
%   decomposition."  The principle is that dilation by some large
%   structuring elements can be computed faster by dilation with a sequence
%   of smaller structuring elements.  For example, dilation by an 11-by-11
%   square structuring element can be accomplished by dilating first with a
%   1-by-11 structuring element and then with an 11-by-1 structuring
%   element.  This results in a theoretical performance improvement of a
%   factor of 5.5, although in practice the actual performance improvement
%   is somewhat less.  Structuring element decompositions used for the
%   'disk' and 'ball' shapes are approximations; all other decompositions
%   are exact.
%
%   Examples
%   --------
%       se1 = strel('square',11)      % 11-by-11 square
%       se2 = strel('line',10,45)     % line, length 10, angle 45 degrees
%       se3 = strel('disk',15)        % disk, radius 15
%       se4 = strel('ball',15,5)      % ball, radius 15, height 5
%
%   See also IMDILATE, IMERODE.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.16.6.4 $  $Date: 2003/08/23 05:53:28 $

if (nargin == 0)
    % No input arguments --- return empty strel
    se = StrelStruct;
    se = class(se, 'strel');
    
elseif ((nargin == 1) && isa(varargin{1}, 'strel'))
    % One strel input --- return it unchanged
    se = varargin{1};
    return
    
else
    [type,params] = ParseInputs(varargin{:});
    
    switch type
      case 'arbitrary'
        se = MakeArbitraryStrel(params{:});
      case 'square'
        se = MakeSquareStrel(params{:});
      case 'diamond'
        se = MakeDiamondStrel(params{:});
      case 'rectangle'
        se = MakeRectangleStrel(params{:});
      case 'octagon'
        se = MakeOctagonStrel(params{:});
      case 'line'
        se = MakeLineStrel(params{:});
      case 'pair'
        se = MakePairStrel(params{:});
      case 'periodicline'
        se = MakePeriodicLineStrel(params{:});
      case 'disk'
        se = MakeDiskStrel(params{:});
      case 'ball'
        se = MakeBallStrel(params{:});
      otherwise
        error('Images:strel:unknownStrelType', 'Unexpected strel type.');
    end
end

%%%
%%% MakeArbitraryStrel
%%%
function se = MakeArbitraryStrel(nhood,height)

se = StrelStruct;
se.nhood = nhood ~= 0;
se.height = height;

if (~isempty(nhood) && all(nhood(:)) && ~any(height(:)))
    % Strel is flat with an all-ones neighborhood.  Decide whether to decompose
    % it.
    size_nhood = size(nhood);
    % Heuristic --- if theoretical computation advantage is
    % at least a factor of two, then assume that the advantage
    % is worth the overhead cost of performing dilation or erosion twice.
    advantage = prod(size_nhood) / sum(size_nhood);
    if (advantage >= 2)
        num_dims = ndims(nhood);
        se.decomposition = strel;
        %%% These lines are commented out and replaced by the code
        %%% following to work around an interpreter bug, g84870.
        %%% se.decomposition = repmat(se.decomposition,1,num_dims);
        %%% for k = 1:ndims(nhood)
        %%%     size_k = ones(1,num_dims);
        %%%     size_k(k) = size(nhood,k);
        %%%     se.decomposition(k) = strel(ones(size_k));
        %%% end
        
        for k = 1:ndims(nhood)
            size_k = ones(1,num_dims);
            size_k(k) = size(nhood,k);
            if k == 1
                se.decomposition = strel(ones(size_k));
            else
                se.decomposition(k) = strel(ones(size_k));
            end
        end
    end
end

se = class(se, 'strel');

%%%
%%% MakeSquareStrel
%%%
function se = MakeSquareStrel(M)

se = strel(ones(M,M));

%%%
%%% MakeRectangleStrel
%%%
function se = MakeRectangleStrel(MN)

se = strel(ones(MN));

%%%
%%% MakeDiamondStrel
%%%
function se = MakeDiamondStrel(M)

se = StrelStruct;
[rr,cc] = meshgrid(-M:M);
se.nhood = (abs(rr) + abs(cc)) <= M;
se.height = zeros(size(se.nhood));

% Heuristic --- if M > 2, assume computational advantage of decomposition
% is worth the cost of performing multiple dilations (or erosions).
if (M > 2)
    % Compute the logarithmic decomposition of the strel using the method in
    % Rein van den Boomgard and Richard van Balen, "Methods for Fast
    % Morphological Image Transforms Using Bitmapped Binary Images," CVGIP:
    % Models and Image Processing, vol. 54, no. 3, May 1992, pp. 252-254.
    
    n = floor(log2(M));
    se.decomposition = strel([0 1 0; 1 1 1; 0 1 0]);
    for k = 0:(n-1)
        P = 2^(k+1) + 1;
        middle = (P+1)/2;
        nhood = zeros(P,P);
        nhood(1,middle) = 1;
        nhood(P,middle) = 1;
        nhood(middle,1) = 1;
        nhood(middle,P) = 1;
        se.decomposition(end+1) = strel(nhood);
    end
    q = M - 2^n;
    if (q > 0)
        P = 2*q+1;
        middle = (P+1)/2;
        nhood = zeros(P,P);
        nhood(1,middle) = 1;
        nhood(P,middle) = 1;
        nhood(middle,1) = 1;
        nhood(middle,P) = 1;
        se.decomposition(end+1) = strel(nhood);
    end
end

se = class(se, 'strel');

%%%
%%% MakeOctagonStrel
%%%
function se = MakeOctagonStrel(M)

% The ParseInputs routine checks to make sure M is a multiple of 3.
k = M/3;
se = StrelStruct;

[rr,cc] = meshgrid(-M:M);
se.nhood = abs(rr) + abs(cc) <= M + k;
se.height = zeros(size(se.nhood));

% Compute the decomposition.  To decompose an octagonal strel for M=3k,
% first the strel is decomposed into k strels that each have M=3.  Then,
% each M=3 strel is further (recursively) decomposed into 4 line-segment
% strels.
if (k == 1)
    % It's an M=3 strel, so decompose into 4 line strels.
    a = [0 0 0; 1 1 1; 0 0 0];
    b = a';
    c = eye(3);
    d = rot90(c);
    se.decomposition = strel(a);
    se.decomposition(2) = strel(b);
    se.decomposition(3) = strel(c);
    se.decomposition(4) = strel(d);
    
elseif (k > 1)
    % Decompose into k strels, each of which has M=3.  Notice the
    % recursive call to strel('octagon',...).
    se.decomposition = repmat(strel('octagon',3), k, 1);
end

se = class(se, 'strel');

%%%
%%% MakePairStrel
%%%
function se = MakePairStrel(MN)

se = StrelStruct;
size_nhood = abs(MN) * 2 + 1;
se.nhood = false(size_nhood);
center = floor((size_nhood + 1)/2);
se.nhood(center(1),center(2)) = 1;
se.nhood(center(1) + MN(1), center(2) + MN(2)) = 1;
se.height = zeros(size_nhood);

se = class(se, 'strel');

%%%
%%% MakeLineStrel
%%%
function se = MakeLineStrel(len,theta_d)

se = StrelStruct;

if (len >= 1)
    % The line is constructed so that it is always symmetric with respect
    % to the origin.
    theta = theta_d * pi / 180;
    x = round((len-1)/2 * cos(theta));
    y = -round((len-1)/2 * sin(theta));
    [c,r] = intline(-x,x,-y,y);
    M = 2*max(abs(r)) + 1;
    N = 2*max(abs(c)) + 1;
    se.nhood = false(M,N);
    idx = sub2ind([M N], r + max(abs(r)) + 1, c + max(abs(c)) + 1);
    se.nhood(idx) = 1;
    se.height = zeros(M,N);
else
    % Do nothing here, which effectively returns the empty strel.
end

se = class(se, 'strel');

%%%
%%% MakePeriodicLineStrel
%%%
function se = MakePeriodicLineStrel(p,v)
se = StrelStruct;
v = v(:)';
p = (-p:p)';
pp = repmat(p,1,2);
vv = repmat(v,length(p),1);
rc = pp .* vv;
r = rc(:,1);
c = rc(:,2);
M = 2*max(abs(r)) + 1;
N = 2*max(abs(c)) + 1;
se.nhood = false(M,N);
idx = sub2ind([M N], r + max(abs(r)) + 1, c + max(abs(c)) + 1);
se.nhood(idx) = 1;
se.height = zeros(M,N);

se = class(se, 'strel');

%%%
%%% MakeDiskStrel
%%%
function se = MakeDiskStrel(r,n)

if (r < 3)
    % Radius is too small to use decomposition, so force n=0.
    n = 0;
end

se = StrelStruct;

if (n == 0)
    % Use simple Euclidean distance formula to find the disk neighborhood.  No
    % decomposition.
    [xx,yy] = meshgrid(-r:r);
    nhood = xx.^2 + yy.^2 <= r^2;

else
    % Reference for radial decomposition of disks:  Rolf Adams, "Radial
    % Decomposition of Discs and Spheres," CVGIP:  Graphical Models and
    % Image Processing, vol. 55, no. 5, September 1993, pp. 325-332.
    %
    % The specific decomposition technique used here is radial
    % decomposition using periodic lines.  The reference is:  Ronald
    % Jones and Pierre Soille, "Periodic lines: Definition, cascades, and
    % application to granulometries," Pattern Recognition Letters,
    % vol. 17, 1996, pp. 1057-1063.
    
    % Determine the set of "basis" vectors to be used for the
    % decomposition.  The rows of v will be used as offset vectors for
    % periodic line strels.
    switch n
      case 4
        v = [ 1 0
              1 1
              0 1
              -1 1];
        
      case 6
        v = [ 1 0
              1 2
              2 1
              0 1
              -1 2
              -2 1];
        
      case 8
        v = [ 1 0
              2 1
              1 1
              1 2
              0 1
              -1 2
              -1 1
              -2 1];
        
      otherwise
        % This error should have been caught already in ParseInputs.
        error('Images:getheight:invalidN', 'For disk strels, N must be 0, 4, 6, or 8');
    end

    % Determine k, which is the desired radial extent of the periodic
    % line strels.  For the origin of this formula, see the second
    % paragraph on page 328 of the Rolf Adams paper.
    theta = pi/(2*n);
    k = 2*r/(cot(theta) + 1/sin(theta));
    
    % For each periodic line strel, determine the repetition parameter,
    % rp.  The use of floor() in the computation means that the resulting
    % strel will be a little small, but we will compensate for this
    % below.
    for q = 1:n
        rp = floor(k / norm(v(q,:)));
        if (q == 1)
            se.decomposition = strel('periodicline', rp, v(q,:));
        else
            se.decomposition(q) = strel('periodicline', rp, v(q,:));
        end
    end
    
    % Now dilate the strels in the decomposition together to see how
    % close we came to the desired disk radius.
    
    nhood = imdilate(1, se.decomposition, 'full');
    nhood = nhood > 0;
    [rd,cd] = find(nhood);
    M = size(nhood,1);
    rd = rd - floor((M+1)/2);
    max_horiz_radius = max(rd(:));
    radial_difference = r - max_horiz_radius;
    
    % Now we are going to add additional vertical and horizontal line
    % strels to compensate for the fact that the strel resulting from the
    % above decomposition tends to be smaller than the desired size.
    len = 2*(radial_difference-1) + 1;
    if (len >= 3)
        % Add horizonal and vertical line strels.
        se.decomposition(end+1) = strel('line',len,0);
        se.decomposition(end+1) = strel('line',len,90);
        
        % Update the computed neighborhood to reflect the additional strels in
        % the decomposition.
        nhood = imdilate(nhood, se.decomposition(end-1:end), 'full');
        nhood = nhood > 0;
    end
end

se.nhood = nhood;
se.height = zeros(size(nhood));

se = class(se, 'strel');

%%%
%%% MakeBallStrel
%%%
function se = MakeBallStrel(r,h,n)

se = StrelStruct;

if (r == 0)
    % Make a unit strel.
    se.nhood = true;
    se.height = h;
    
elseif (n == 0)
    % Use Euclidean distance and ellipsoid formulas to construct strel;
    % no decomposition used.
    [xx,yy] = meshgrid(-r:r);
    se.nhood = xx.^2 + yy.^2 <= r^2;
    se.height = h * sqrt(r^2 - min(r^2,xx.^2 + yy.^2)) / r;
    
else
    % Radial decomposition of a sphere.  Reference is the Rolf Adams
    % paper listed above.

    % Height profile for each radial line strel is given by a parametric
    % formula of the form (a, g(a)), where a is a function of beta.  See
    % page 331 of the Rolf Adams paper.  Our strategy for using this
    % function is to create a table of (a,g(a)) values and then
    % interpolate into this table.
    beta = linspace(0,pi,100)';
    a = beta - pi/2 - sin(beta).*cos(beta);
    g_a = sin(beta).^2;
    
    % Length of each line strel.
    L = pi*r/n;

    % Compute the end-point coordinates of each line strel.
    theta = pi * (0:(n/2 - 1))' / n;
    xy = round(L/2 * [cos(theta) sin(theta)]);
    xy = [xy ; [-xy(:,2) xy(:,1)]];
    
    for k = 1:n
        % For each line strel, compute the x-y coordinates of the elements
        % of the strel, and also compute the corresponding height.
        x = xy(k,1);
        y = xy(k,2);
        [xx,yy] = intline(0,x,0,y);
        xx = [xx; -xx(2:end)];
        yy = [yy; -yy(2:end)];
        dist = sqrt(xx.^2 + yy.^2);
        ap = dist*n/r;
        z = h/n * interp1q(a, g_a, ap);
        
        % We could have nan's at the end-points now; replace them by 0.
        z(isnan(z)) = 0;

        % Now form neighborhood and height matrices with which we can call
        % strel.
        xmin = min(xx);
        ymin = min(yy);
        M = -2*ymin + 1;
        N = -2*xmin + 1;
        nhood = zeros(M,N);
        height = zeros(M,N);
        row = yy - ymin + 1;
        col = xx - xmin + 1;
        idx = row + M*(col-1);
        nhood(idx) = 1;
        height(idx) = z;
        if (k == 1)
            se.decomposition = strel(nhood,height);
        else
            se.decomposition(k) = strel(nhood,height);
        end
    end
    
    % Now compute the neighborhood and height of the strel resulting the radial
    % decomposition.
    full_height = imdilate(0,se.decomposition,'full');
    full_nhood = isfinite(full_height);
    se.nhood = full_nhood;
    se.height = full_height;
end

se = class(se, 'strel');

%%%
%%% StrelStruct
%%%
function s = StrelStruct

s.nhood = [];
s.height = [];
s.decomposition = [];
s.version = 1;

%%%
%%% The intline function here is borrowed directly from
%%% toolbox/images/images/private/intline.
%%%
function [x,y] = intline(x1, x2, y1, y2)
%INTLINE Integer-coordinate line drawing algorithm.
%   [X, Y] = INTLINE(X1, X2, Y1, Y2) computes an
%   approximation to the line segment joining (X1, Y1) and
%   (X2, Y2) with integer coordinates.  X1, X2, Y1, and Y2
%   should be integers.  INTLINE is reversible; that is,
%   INTLINE(X1, X2, Y1, Y2) produces the same results as
%   FLIPUD(INTLINE(X2, X1, Y2, Y1)).

dx = abs(x2 - x1);
dy = abs(y2 - y1);

% Check for degenerate case.
if ((dx == 0) && (dy == 0))
  x = x1;
  y = y1;
  return;
end

flip = 0;
if (dx >= dy)
  if (x1 > x2)
    % Always "draw" from left to right.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (y2 - y1)/(x2 - x1);
  x = (x1:x2).';
  y = round(y1 + m*(x - x1));
else
  if (y1 > y2)
    % Always "draw" from bottom to top.
    t = x1; x1 = x2; x2 = t;
    t = y1; y1 = y2; y2 = t;
    flip = 1;
  end
  m = (x2 - x1)/(y2 - y1);
  y = (y1:y2).';
  x = round(x1 + m*(y - y1));
end
  
if (flip)
  x = flipud(x);
  y = flipud(y);
end


%%%
%%% ParseInputs
%%%
function [type,params] = ParseInputs(varargin)

type = '';
params = {};

default_ball_n = 8;
default_disk_n = 4;

checknargin(1, 4, nargin, 'strel');

if ~ischar(varargin{1})
    type = 'arbitrary';
    params = varargin;
else
    params = varargin(2:end);
    
    valid_strings = {'arbitrary'
                     'square'
                     'diamond'
                     'rectangle'
                     'octagon'
                     'line'
                     'pair'
                     'periodicline'
                     'disk'
                     'ball'};
    type = checkstrs(varargin{1}, valid_strings, 'strel', ...
                     'STREL_TYPE', 1);
end

num_params = numel(params);

switch type
  case 'arbitrary'
    if num_params < 1
        eid = 'Images:strel:tooFewInputsForArbitrary';
        msg = 'Too few inputs.';
        error(eid,'%s',msg);
    end
    
    % Check validity of the NHOOD argument.
    nhood = params{1};
    checkinput(nhood, {'numeric', 'logical'}, {'real'}, 'strel', ...
               'NHOOD', 2);
    
    % Check validity of the HEIGHT argument.
    if num_params >= 2
        height = params{2};
        checkinput(height, {'double'}, {'real', 'nonnan'}, 'strel', ...
                   'HEIGHT', 3);
        if ~isequal(size(height), size(nhood))
            eid = 'Images:strel:sizeMismatch';
            msg = 'For arbitrary strels, the HEIGHT input must be a real double matrix with the same size as the NHOOD input.';
            error(eid,'%s',msg);
        end
    else
        params{2} = zeros(size(nhood));
    end
    
  case 'square'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForSquare';
        msg = 'Too few inputs for ''square'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 1)
        eid = 'Images:strel:tooManyInputsForSquare';
        msg = 'Too many inputs for ''square'' strel.';
        error(eid,'%s',msg);
    end
    M = params{1};
    checkinput(M, {'double'}, {'scalar' 'integer' 'real' 'nonnegative'}, ...
               'strel', 'SIZE', 2);
    
  case 'diamond'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForDiamond';
        msg = 'Too few inputs for ''diamond'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 1)
        eid = 'Images:strel:tooManyInputsForDiamond';
        msg = 'Too many inputs for ''diamond'' strel.';
        error(eid,'%s',msg);
    end
    M = params{1};
    checkinput(M, {'double'}, {'scalar' 'integer' 'nonnegative'}, ...
               'strel', 'SIZE', 2);

  case 'octagon'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForOctagon';
        msg = 'Too few inputs for ''octagon'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 1)
        eid = 'Images:strel:tooManyInputsForOctagon';
        msg = 'Too many inputs for ''octagon'' strel.';
        error(eid,'%s',msg);
    end
    M = params{1};
    checkinput(M, {'double'}, {'scalar' 'real' 'integer' 'nonnegative'}, ...
               'strel', 'SIZE', 2);
    if rem(M,3) ~= 0
        eid = 'Images:strel:notMultipleOf3';
        msg = 'For octagon strels, the SIZE input must be a nonnegative multiple of 3.';
        error(eid,'%s',msg);
    end
    
  case 'rectangle'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForRectangle';
        msg = 'Too few inputs for ''rectangle'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 1)
        eid = 'Images:strel:tooManyInputsForRectangle';
        msg = 'Too many inputs for ''rectangle'' strel.';
        error(eid,'%s',msg);
    end
    MN = params{1};
    checkinput(MN, {'double'}, {'vector' 'real' 'integer' 'nonnegative'}, ...
               'strel', 'SIZE', 2);
    if numel(MN) ~= 2
        eid = 'Images:strel:badSizeForRectangle';
        msg = 'For rectangle strels, SIZE must have two elements.';
        error(eid,'%s',msg);
    end
    
  case 'pair'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForPair';
        msg = 'Too few inputs for ''pair'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 1)
        eid = 'Images:strel:tooManyInputsForPair';
        msg = 'Too many inputs for ''pair'' strel.';
        error(eid,'%s',msg);
    end
    RC = params{1};
    checkinput(RC, {'double'}, {'vector' 'real' 'integer'}, ...
               'strel', 'OFFSET', 2);
    if numel(RC) ~= 2
        eid = 'Images:strel:badOffsetsForPair';
        msg = 'For pair strels, OFFSET must have two elements.';
        error(eid,'%s',msg);
    end

  case 'line'
    if (num_params < 2)
        eid = 'Images:strel:tooFewInputsForLine';
        msg = 'Too few inputs for ''line'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 2)
        eid = 'Images:strel:tooManyInputsForLine';
        msg = 'Too many inputs for ''line'' strel.';
        error(eid,'%s',msg);
    end
    len = params{1};
    checkinput(len, {'double'}, {'scalar' 'real' 'nonnegative'}, ...
               'strel', 'LEN', 2);

    deg = params{2};
    checkinput(deg, {'double'}, {'scalar' 'real'}, 'strel', 'DEG', 3);
    
  case 'periodicline'
    if (num_params < 2)
        eid = 'Images:strel:tooFewInputsForPeriodicLine';
        msg = 'Too few inputs for ''periodicline'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 2)
        eid = 'Images:strel:tooManyInputsForPeriodicLine';
        msg = 'Too many inputs for ''periodicline'' strel.';
        error(eid,'%s',msg);
    end
    p = params{1};
    checkinput(p, {'double'}, {'scalar' 'real' 'integer' 'nonnegative'}, ...
               'strel', 'P', 2);

    v = params{2};
    checkinput(v, {'double'}, {'vector' 'real' 'integer'}, 'strel', ...
               'V', 3);
    if numel(v) ~= 2
        eid = 'Images:strel:wrongSizeForV';
        msg = 'For periodic line strels, V must be a two-element vector.';
        error(eid,'%s',msg);
    end
    
  case 'disk'
    if (num_params < 1)
        eid = 'Images:strel:tooFewInputsForDisk';
        msg = 'Too few inputs for ''disk'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 2)
        eid = 'Images:strel:tooManyInputsForDisk';
        msg = 'Too many inputs for ''disk'' strel.';
        error(eid,'%s',msg);
    end

    r = params{1};
    checkinput(r,{'double'}, {'scalar' 'real' 'integer' 'nonnegative'}, ...
               'strel', 'R', 2);

    if (num_params < 2)
        params{2} = default_disk_n;
    else
        n = params{2};
        checkinput(n, {'double'}, {'scalar' 'real' 'integer'}, ...
                   'strel', 'N', 3);
        if ((n ~= 0) && (n ~= 4) && (n ~= 6) && (n ~= 8))
            eid = 'Images:strel:invalidN';
            msg = 'For disk strels, N must be 0, 4, 6, or 8.';
            error(eid,'%s',msg);
        end
    end
    
  case 'ball'
    if (num_params < 2)
        eid = 'Images:strel:tooFewInputsForBall';
        msg = 'Too few inputs for ''ball'' strel.';
        error(eid,'%s',msg);
    end
    if (num_params > 3)
        eid = 'Images:strel:tooManyInputsForBall';
        msg = 'Too many inputs for ''ball'' strel.';
        error(eid,'%s',msg);
    end

    r = params{1};
    checkinput(r, {'double'}, {'scalar' 'real' 'integer' 'nonnegative'}, ...
               'strel', 'R', 2);

    h = params{2};
    checkinput(h, {'double'}, {'scalar' 'real'}, 'strel', 'H', 3);

    if (num_params < 3)
        params{3} = default_ball_n;
    else
        n = params{3};
        checkinput(n, {'double'}, {'scalar' 'real' 'integer' 'nonnegative' ...
                            'even'}, 'strel', 'N', 4);
    end
            
  otherwise
    % This code should be unreachable.
    eid = 'Images:strel:unrecognizedStrelType';
    msg = 'Unrecognized strel type.';
    error(eid,'%s',msg);
end
