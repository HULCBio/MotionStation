function B = tformarray( A, T, R, tdims_A, tdims_B, tsize_B, tmap_B, F )
%TFORMARRAY Geometric transformation of a multidimensional array. 
%   B = TFORMARRAY(A,T,R,TDIMS_A,TDIMS_B,TSIZE_B,TMAP_B,F) applies
%   a geometric transformation to array A to produce array B.
%
%   TFORMARRAY is like IMTRANSFORM, but is intended for problems
%   involving higher-dimensioned arrays or mixed input/output
%   dimensionality, or requiring greater user control or customization.
%   (Anything -- and more -- that can be accomplished with IMTRANSFORM
%   can be accomplished with a combination of MAKETFORM, MAKERESAMPLER,
%   FINDBOUNDS, and TFORMARRAY, but for many tasks involving 2-D images,
%   IMTRANSFORM is simpler.)
%
%   Brief description of inputs
%   ---------------------------
%   A         Input array or image
%   T         Geometric transformation, typically created with
%             MAKETFORM
%   R         Resampler, typically created with MAKERESAMPLER
%   TDIMS_A   Row vector listing the input transform dimensions
%   TDIMS_B   Row vector listing the output transform dimensions
%   TSIZE_B   Output array size in the transform dimensions
%   TMAP_B    Array of point locations in output space; can be used as an
%             alternative way to specify a geometric transformation
%   F         Array of fill values
%
%   Detailed description of inputs
%   ------------------------------
%   A         A can be any nonsparse numeric array, and can be real or
%             complex. It can also be logical.
%
%   T         T is a structure that defines a particular geometric
%             transformation.  For each location in the output transform
%             subscript space (as defined by TDIMS_B and TSIZE_B),
%             TFORMARRAY uses T and the function TFORMINV to compute the
%             corresponding location in the input transform subscript
%             space (as defined by TDIMS_A and SIZE(A)).
%
%             If T is empty, then TFORMARRAY operates as a direct resampling
%             function, applying the resampler defined in R to compute
%             values at each transform space location defined in TMAP_B 
%             (if TMAP_B is non-empty) or at each location in the output
%             transform subscript grid.
%
%   R         R is a structure that defines how to interpolate values of
%             the input array at specified locations.  R is usually
%             created with MAKERESAMPLER, which allows fine control
%             over how to interpolate along each dimension, as well as
%             what input array values to use when interpolating close the
%             edge of the array.
%
%   TDIMS_A   TDIMS_A and TDIMS_B indicate which dimensions of the input
%   TDIMS_B   and output arrays are involved in the geometric
%             transformation.  Each element must be unique, and must be a
%             positive integer.  The entries need not be listed in
%             increasing order, but the order matters.  It specifies the
%             precise correspondence between dimensions of arrays A and B
%             and the input and output spaces of the transformer, T.
%             LENGTH(TDIMS_A) must equal T.ndims_in, and LENGTH(TDIMS_B)
%             must equal T.ndims_out.
%
%             Suppose, for example, that T is a 2-D transformation,
%             TDIMS_A = [2 1], and TDIMS_B = [1 2].  Then the column
%             dimension and row dimension of A correspond to the first
%             and second transformation input-space dimensions,
%             respectively.  The row and column dimensions of B
%             correspond to the first and second output-space
%             dimensions, respectively.
%
%   TSIZE_B   TSIZE_B specifies the size of the array B along the
%             output-space transform dimensions.  Note that the size of B
%             along nontransform dimensions is taken directly from the
%             size of A along those dimensions.  If, for example, T is a
%             2-D transformation, size(A) = [480 640 3 10], TDIMS_B is
%             [2 1], and TSIZE_B is [300 200], then size(B) is [200 300 3].
%
%   TMAP_B    TMAP_B is an optional array that provides an alternative
%             way of specifying the correspondence between the position
%             of elements of B and the location in output transform
%             space.  TMAP_B can be used, for example, to compute the
%             result of an image warp at a set of arbitrary locations in
%             output space.  If TMAP_B is not empty, then the size of
%             TMAP_B takes the form: 
%
%                 [D1 D2 D3 ... DN L]
%
%             where N equals length(TDIMS_B).  The vector [D1 D2 ... DN]
%             is used in place of TSIZE_B.  If TMAP_B is not empty, then
%             TSIZE_B should be [].
%
%             The value of L depends on whether or not T is empty.  If T
%             is not empty, then L is T.ndims_out, and each L-dimension
%             point in TMAP_B is transformed to an input-space location
%             using T.  If T is empty, then L is LENGTH(TDIMS_A), and
%             each L-dimensional point in TMAP_B is used directly as a
%             location in input space.
%
%   F         F is a double-precision array containing fill values.
%             The fill values in F may be used in three situations:
%
%             (1) When a separable resampler is created with MAKERESAMPLER
%                 and its PADMETHOD is set to either 'fill' or 'bound',
% 
%             (2) When a custom resampler is used that supports the 'fill'
%                 or 'bound' pad methods (with behavior that is specific
%                 to the customization), or
% 
%             (3) When the map from the transform dimensions of B
%                 to the transform dimensions of A is deliberately
%                 undefined for some points. Such points are encoded in
%                 the input transform space by NaNs in either TMAP_B or
%                 in the output of TFORMINV.
%
%             In the first two cases, fill values are used to compute values
%             for output locations that map outside or near edges of the input
%             array.  Fill values are copied into B when output locations map
%             well outside the input array.  Type 'help makeresampler' for
%             further details on 'fill' and 'bound'.
%
%             F can be a scalar (including NaN), in which case its value
%             is replicated across all the nontransform dimensions.  Or F
%             can be a nonscalar whose size depends on size(A) in the
%             nontransform dimensions.  Specifically, if K is the J-th
%             nontransform dimension of A, then SIZE(F,J) must be either
%             SIZE(A,K) or 1.  As a convenience to the user, TFORMARRAY
%             replicates F across any dimensions with unit size such that
%             after the replication SIZE(F,J) equals size(A,K).
%
%             For example, suppose A represents 10 RGB images and has
%             size 200-by-200-by-3-by-10, T is a 2-D transformation, and
%             TDIMS_A and TDIMS_B are both [1 2].  In other words,
%             TFORMARRAY will apply the same 2-D transform to each color
%             plane of each of the 10 RGB images.  In this situation you
%             have several options for F:
%
%             - F can be a scalar, in which case the same fill value
%               is used for each color plane of all 10 images.
%
%             - F can be a 3-by-1 vector, [R G B]'.  Then R, G, and B
%               will be used as the fill values for the corresponding
%               color planes of each of the 10 images.  This can be
%               interpreted as specifying an RGB "fill color," with
%               the same color used for all 10 images.
%
%             - F can be a 1-by-10 vector.  This can be interpreted as
%               specifying a different fill value for each of 10
%               images, with that fill value being used for all three
%               color planes.  (Each image gets a distinct grayscale
%               fill-color.)
%
%             - F can be a 3-by-10 matrix, which can be interpreted as
%               supplying a different RGB fill-color for each of the
%               10 images.
%
%   Example
%   -------
%   Create a 2-by-2 checkerboard image where each square is 20 pixels
%   wide, then transform it with a projective transformation.  Use a
%   pad method of 'circular' when creating a resampler, so that the
%   output appears to be a perspective view of an infinite checkerboard.
%   Swap the output dimensions.  Specify a 100-by-100 output image.
%   Leave TMAP_B empty, since TSIZE_B is specified.  Leave the fill
%   value empty, since it won't be needed.
%
%       I = checkerboard(20,1,1);
%       imview(I)
%       T = maketform('projective',[1 1; 41 1; 41 41;   1 41],...
%                                  [5 5; 40 5; 35 30; -10 30]);
%       R = makeresampler('cubic','circular');
%       J = tformarray(I,T,R,[1 2],[2 1],[100 100],[],[]);
%       imview(J)
%
%   See also IMTRANSFORM, MAKERESAMPLER, MAKETFORM, FINDBOUNDS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $ $Date: 2003/08/23 05:54:44 $

% Start checking the inputs.
message = nargchk(8,8,nargin);
if ~isempty(message)
    eid = sprintf('Images:%s:nargchkError',mfilename);
    error(eid,'%s',message);
end

% Construct a new tsize_B if tmap_B is non-empty.
tsize_B = CheckDimsAndSizes( tdims_A, tdims_B, tsize_B, tmap_B, T );

% Get the 'full sizes' of A and B and their non-transform sizes (osize).
[fsize_A, fsize_B, osize] = fullsizes(size(A), tsize_B, tdims_A, tdims_B);

% Finish checking the inputs.
CheckInputArray( A );
CheckResampler( R, tdims_A );
F = CheckFillArray( F, osize );

% Determine blocking, if any.
if ~isempty(tmap_B)
    nBlocks = 1;  % Must process in a single block if tmap_B is supplied.
else
    blockingfactors = GetBlocking(tsize_B,max(length(tdims_A),length(tdims_B)));
    nBlocks = prod(blockingfactors);
end

% If there is no tmap_B, process large arrays in multiple blocks to conserve
% the memory required by the output grid G and its mapping to the input
% space M.  Otherwise, do the resampling in one large block.
if nBlocks == 1
    % If not already supplied in tmap_B, construct a grid G mapping B's
    % transform subscripts to T's output space or (if T = []) directly to
    % A's transform subscripts.
    if ~isempty(tmap_B)
        G = tmap_B;
    else
        hi = tsize_B;
        lo = ones(1,length(hi));
        G = ConstructGrid(lo,hi);
    end

    % If there is a tform, use it to extend the map in G to A's
    % transform subscripts.
    if ~isempty(T)
        M = tforminv(G,T);
    else
        M = G;
    end
    G = []; % Free memory used by G (which is no longer needed).

    % Resample A using the map M and resampler R.
    B = resample(A, M, tdims_A, tdims_B, fsize_A, fsize_B, F, R);
else
    % Pre-allocate B with size fsize_B and class(B) = class(A).
    B(prod(fsize_B)) = A(1);
    B = reshape(B,fsize_B);
    
    % Loop over blocks in output transform space... 
    [lo, hi] = GetBlockLimits(tsize_B, blockingfactors);
    for i = 1:nBlocks
        % Construct the geometric map for the current block.
        G = ConstructGrid(lo(i,:),hi(i,:));
        if ~isempty(T)
            M = tforminv(G,T);
        else
            M = G;
        end
        G = []; % Free memory used by G (which is no longer needed).
    
        % Construct size and subscript arrays for the block, then resample.
        [bsize_B, S] = ConstructSubscripts(fsize_B, tdims_B, lo(i,:), hi(i,:));
        B(S{:}) = resample(A, M, tdims_A, tdims_B, fsize_A, bsize_B, F, R);
    end
end

%--------------------------------------------------------------------------

function B = resample( A, M, tdims_A, tdims_B, fsize_A, fsize_B, F, R )

% Evaluates the resampling function defined in the resampler R at
% each point in the subscript map M and replicated across all the
% non-transform dimensions of A, producing a warped version of A in B.

B = feval(R.resamp_fcn, A, M, tdims_A, tdims_B, fsize_A, fsize_B, F, R );

%--------------------------------------------------------------------------

function [bsize_B, S] = ConstructSubscripts( fsize_B, tdims_B, lo, hi )

% Determines the size of the block of array B bounded by the values in
% vectors LO and HI, and constructs an array of subscripts for assigning
% an array into that block.

bsize_B = fsize_B;
bsize_B(tdims_B) = hi - lo + 1;

fdims_B = length(fsize_B);
S = repmat({':'},[1,fdims_B]);
for i = 1:length(tdims_B)
    S{tdims_B(i)} = lo(i) : hi(i);
end

%--------------------------------------------------------------------------

function G = ConstructGrid( lo, hi )

% Constructs a regular grid from the range of subscripts defined by
% vectors LO and HI, and packs the result into a single array, G.
% G is D(1) x D(2) x ... x D(N) x N where D(k) is the length of
% lo(k):hi(k) and N is the length of LO and HI.

N = length(hi);
E = cell(1,N);
for i = 1:N;
    E{i} = lo(i):hi(i);  % The subscript range for each dimension
end
G = CombinedGrid(E{:});

%--------------------------------------------------------------------------

function G = CombinedGrid(varargin)

% If N >= 2, G = COMBINEDGRID(x1,x2,...,xN) is a memory-efficient
% equivalent to:
%
%   G = cell(N,1);
%   [G{:}] = ndgrid(x1,x2,...,xN);
%   G = cat(N + 1, G{:});
%
% (where x{i} = varargin{i} and D(i) is the number of
% elements in x{}).
%
% If N == 1, COMBINEDGRID returns x1 as a column vector. (The code
% with NDGRID replicates x1 across N columns, returning an N-by-N
% matrix -- which is inappropriate for our application.)
%
% N == 0 is not allowed.

N = length(varargin);
if N == 0
    eid = sprintf('Images:%s:combinegridCalledNoArgs',mfilename);
    error(eid,'%s',...
          'Internal Error: COMBINEDGRID called with no arguments.');
end

for i=1:N
    D(1,i) = numel(varargin{i});
end

if N == 1
    % Special handling required to avoid calling RESHAPE
    % with a single-element size vector.
    G = varargin{1}(:);
else
    % Pre-allocate the output array.
    G = zeros([D N]);
    
    % Prepare to generate a comma-separated list of N colons.
    colons = repmat({':'},[1 N]);
    
    for i=1:N
        % Extract the i-th vector, reshape it to run along the
        % i-th dimension (adding singleton dimensions as needed),
        % replicate it across all the other dimensions, and
        % copy it to G(:,:,...,:,i) -- with N colons.
        x = varargin{i}(:);
        x = reshape( x, [ones(1,i-1) D(i) ones(1,N-i)] );
        x = repmat(  x, [ D(1:i-1)    1     D(i+1:N) ] );
        G(colons{:},i) = x;
    end
end

%--------------------------------------------------------------------------

function blockingfactors = GetBlocking( tsize, P )

% With large input arrays, the memory used by the grid and/or map
% (G and M) in the main function can be substantial and may exceed
% the memory used by the input and output images -- depending on the
% number of input transform dimensions, the number of non-transform
% dimensions, and the storage class of the input and output arrays.
% So the main function may compute the map block-by-block, resample
% the input for just that block, and assign the result to a pre-allocated
% output array.  We define the blocks by slicing the output transform space
% along lines, planes, or hyperplanes normal to each of the subscript
% axes.  We call the number of regions created by the slicing along a
% given axis the 'blocking factor' for that dimension.  (If no slices
% are made, the blocking factor is 1.  If all the blocking factors are
% 1 (which can be tested by checking if prod(blockingfactors) == 1),
% then the output array is small enough to process as a single block.)
% The blockingfactors array created by this function has the same
% size as TSIZE, and its dimensions are ordered as in TSIZE.
%
% This particular implementation has the following properties:
% - All blocking factors are powers of 2
% - After excluding very narrow dimensions, it slices across the
%   remaining dimensions to defined blocks whose dimensions tend
%   toward equality. (Of course, for large aspect ratios and relatively
%   few blocks, the result may not actually get very close to equality.)

% Control parameters
Nt = 20;  % Defines target block size
Nm =  2;  % Defines cut-off to avoid blocking on narrow dimensions
% The largest block will be on the order of 2^Nt doubles (but may be
% somewhat larger).  Any dimensions with size less than 2^Nm (= 4)
% will have blocking factors of 1.  They are tagged by zeros in the
% qDivisible array below.

% Separate the dimensions that are too narrow to divide into blocks.
qDivisible = tsize > 2^(Nm+1);
L = sum(qDivisible);

% The number of blocks will be 2^N.  As a goal, each block will
% contain on the order of 2^Nt values, but larger blocks may be
% needed to avoid subdividing narrow dimensions too finely.
%
% If all dimensions are large, then we'd like something like
%
%   (1) N = floor(log2(prod(tsize)/(2^Nt/P)));
%
% That's because we'd like prod(size(M)) / 2^N to be on the order of 2^Nt,
% and prod(size(M)) = prod(tsize) * P.  The following slightly more complex
% formula is equivalent to (1), but divides out the non-divisible dimensions
%
%   (2) N = floor(log2(prod(tsize(qDivisible)) / ...
%                             (2^Nt/(P*prod(tsize(~qDivisible)))))); 
%
% However, it is possible that we might not be able to block an image as
% finely as we'd like if its size is due to having many small dimensions
% rather than a few large ones.  That's why the actual formula for N in
% the next line of code replaces the numerator in (2) with 2^((Nm+1)*L)
% if this quantity is larger. In such a case, we'd have
%
%   (3) N = floor(log2(prod(tsize(qDivisible)) / 2^((Nm+1)*L)));
%
% and would have to make do with fewer blocks in order to ensure a minimum
% block size greater than or equal to 2^Nm.  The fact that our block sizes
% always satisfy this constraint is proved in the comments at the end of
% this function.

N = floor(log2(prod(tsize(qDivisible)) / ...
               max( (2^Nt)/(P*prod(tsize(~qDivisible))), 2^((Nm+1)*L) )));

% Initialize the blocking factor for the each divisible dimensions
% as unity.  Iterate N times, each time multiplying one of the
% blocking factors by 2.  The choice of which to multiply is driven
% by the goal of making the final set of average divisible block
% dimensions (stored in D at the end of the iteration) as uniform
% as possible.
B = ones(1,L);
D = tsize(qDivisible);
blockingfactors = zeros(size(tsize));

for i = 1:N
    k = find(D == max(D));
    k = k(1);  % Take the first if there is more than one maximum
    B(k) = B(k) * 2;
    D(k) = D(k) / 2;
end
blockingfactors( qDivisible) = B;
blockingfactors(~qDivisible) = 1;

% Assertion: After the loop is complete, all(D >= 2^Nm).
if any(D < 2^Nm)
    eid = sprintf('Images:%s:blockDimsTooSmall',mfilename);
    error(eid,'%s',...
          'Internal Error: Block dimension below minimum.');
end

% Let Dmin = min(D) after the loop is complete.  Dmin is the smallest
% average block size among the 'divisible' dimensions.  The following
% is a proof that Dmin >= 2^Nm.
%
% There are two possibilities: Either the blocking factor corresponding
% to Dmin is 1 or it is not.  If the blocking factor is 1, the proof
% is trival: Dmin > 2^(Nm+1) > 2^Nm (otherwise this dimension would
% not be included by virtue of qDivisible being false). Otherwise,
% because the algorithm continually divides the largest
% element of D by 2, it is clear that when the loop is complete
%
%   (1)  Dmin >= (1/2) * max(D).
%
% max(D) must equal or exceed the geometric mean of D,
%
%   (2)  max(D) >= (prod(D))^(1/L).
%
% From the formula for N,
%
%   (3)  N <= log2(prod(tsize(qDivisible)) / 2^((Nm+1)*L)).
%
% Because exactly N divisions by 2 occur in the loop,
%
%   (4)  prod(tsize(qDivisible) = (2^N) * prod(D);
%
% Combining (3) and (4),
%
%   (5)  prod(D) >= 2^((Nm+1)*L).
%
% Combining (1), (2), and (5) completes the proof,
%
%   (6)  Dmin >= (1/2) * max(D)
%             >= (1/2)*(prod(D))^(1/L)
%             >= (1/2)*(2^((Nm+1)*L))^(1/L) = 2^Nm.

%--------------------------------------------------------------------------

function [lo, hi] = GetBlockLimits( tsize_B, blockingfactors )

% Construct matrices LO and HI containing the lower and upper limits for
% each block, making sure to enlarge the upper limit of the right-most
% block in each dimension as needed to reach the edge of the image.
% LO and HI are each nBlocks-by-N.

N = length(tsize_B);
blocksizes = floor(tsize_B ./ blockingfactors);
blocksubs  = [0 ones( 1,N-1)];
delta      = [1 zeros(1,N-1)];
nBlocks = prod(blockingfactors);
lo = zeros(nBlocks,N);
hi = zeros(nBlocks,N);
for i = 1:nBlocks;
    blocksubs = blocksubs + delta;
    while any(blocksubs > blockingfactors)
        % 'Carry' to higher dimensions as required.
        k = find(blocksubs > blockingfactors);
        blocksubs(k) = 1;
        blocksubs(k+1) = blocksubs(k+1) + 1;
    end
    lo(i,:) = 1 + (blocksubs - 1) .* blocksizes;
    hi(i,:) = blocksubs .* blocksizes;
    qUpperLim = blocksubs == blockingfactors;
    hi(i,qUpperLim) = tsize_B(qUpperLim);
end
if any(blocksubs ~= blockingfactors)
    eid = sprintf('Images:%s:failedToIterate',mfilename);
    error(eid,'%s',...
          'Internal Error: Failed to iterate over all blocks.');
end

%--------------------------------------------------------------------------

function [fsize_A, fsize_B, osize] = fullsizes(size_A, tsize_B, tdims_A, tdims_B)

% Constructs row vectors indicating the full sizes of A and B (FSIZE_A and
% FSIZE_B), including trailing singleton dimensions. Also constructs a row
% vector (OSIZE) listing (in order) the sizes of the non-transform
% dimensions of both A and B.
%
% There are two ways for trailing singletons to arise: (1) values in
% TDIMS_A exceed the length of SIZE_A or values in TDIMS_B exceed the
% length of TSIZE_B plus the number on non-transform dimensions of A and
% (2) all dimensions of A are transform dimensions (e.g., A is a grayscale
% image) -- in this case a trailing singleton is added to A and then
% transferred to B.
%
% Example:
%
%   [fsize_A, fsize_B] = ...
%      fullsizes( [7 512 512 512 3 20 ], [200 300], [2 3 4], [1 2] );
%
%   returns fsize_A = [  7   512   512   512     3    20]
%   and     fsize_B = [200   300     7     3    20]
%   and     osize   = [  7     3    20].

% Actual dimensionality of input array
ndims_A = length(size_A);

% 'Full' dimensionality of input array --
% Increase ndims(A) as needed, to allow for the largest
% transform dimensions as specified in tdims_A, then
% make sure there is at least one non-transform dimension.
fdims_A = max([ndims_A max(tdims_A)]); 
if fdims_A == length(tdims_A)
    fdims_A = fdims_A + 1;
end

% 'Full' size of input array --
% Pad size_A with ones (as needed) to allow for values
% in tdims_A that are higher than ndims(A):
fsize_A = [size_A ones(1,fdims_A - ndims_A)];

% The non-transform sizes of A and B:
osize = fsize_A(~ismember(1:fdims_A,tdims_A));

% The minimum ndims of B:
ndims_B = length(osize) + length(tdims_B);

% Increase ndims_B as needed, to allow for the largest
% transform dimensions as specified in tdims_B:
fdims_B = max(ndims_B, max(tdims_B)); 

% The full size of B, including possible padding:
isT_B = ismember(1:fdims_B, tdims_B);
padding = ones(1,fdims_B - (length(osize) + length(tsize_B)));
[sdims_B index] = sort(tdims_B);
fsize_B = zeros(size(isT_B));
fsize_B( isT_B) = tsize_B(index);
fsize_B(~isT_B) = [osize padding];

%---------------------------------------------------------------------

function K = PredictNDimsG( N, L )

if N == 1
    K = 2;
elseif N > 1 && L == 1
    K = N;
elseif N > 1 && L > 1
    K = N + 1;
else
    eid = sprintf('Images:%s:NLMustBePositive',mfilename);
    error(eid,'%s',...
          'Internal Error: N and L must both be positive.');
end

%---------------------------------------------------------------------

function tsize_B = CheckDimsAndSizes( tdims_A, tdims_B, tsize_B, tmap_B, T )

% Check dimensions
if ~IsFinitePositiveIntegerRowVector( tdims_A )
    eid = sprintf('Images:%s:invalidTDIMS_A',mfilename);
    error(eid,'%s',...
          'TDIMS_A must be a row vector of finite, positive integers.');
end

if ~IsFinitePositiveIntegerRowVector( tdims_B )
    eid = sprintf('Images:%s:invalidTDIMS_B',mfilename);
    error(eid,'%s','TDIMS_B must be a row vector of finite, positive integers.');
end

P = length(tdims_A);
N = length(tdims_B);

if length(unique(tdims_A)) ~= P
    eid = sprintf('Images:%s:nonUniqueTDIMS_A',mfilename);
    error(eid,'%s','All values in TDIMS_A must be unique.');
end

if length(unique(tdims_B)) ~= N
    eid = sprintf('Images:%s:nonUniqueTDIMS_B',mfilename);
    error(eid,'%s','All values in TDIMS_B must be unique.');
end

% If tmap_B is supplied, ignore the input value of tsize_B and 
% construct tsize_B from tmap_B instead. Allow for the possibility
% that the last dimension of tmap_B is a singleton by copying no
% more than N values from size(tmap_B).

if isempty(tmap_B)
    L = N;
else
    if ~isempty(tsize_B)
        wid = sprintf('Images:%s:ignoringTSIZE_B',mfilename);       
        msg1 = 'Both TMAP_B and TSIZE_B are non-empty; ';
        msg2 = 'TSIZE_B will be ignored.';
        warning(wid,'%s %s',msg1,msg2);
              
    end
    
    if ~isa(tmap_B,'double') || ~isreal(tmap_B) || issparse(tmap_B) || ...
          any(isinf(tmap_B(:)))
        eid = sprintf('Images:%s:invalidTMAP_B',mfilename);       
        msg1 = 'TMAP_B must be a non-sparse, finite real-valued array';
        msg2 = ' of class double.'; 
        error(eid,'%s %s',msg1, msg2);
    end
    
    L = size(tmap_B,N+1);
    
    if isempty(T) && L ~= P
        eid = sprintf('Images:%s:invalidSizeTMAP_B',mfilename);        
        msg1 = 'SIZE(TMAP_B) is inconsistent with LENGTH(TDIMS_A) ';
        msg2 = 'or LENGTH(TDIMS_B).';
        error(eid,'%s %s',msg1, msg2);
    end
    
    if ndims(tmap_B) ~= PredictNDimsG(N,L)
        eid = sprintf('Images:%s:invalidDimsTMAP_B',mfilename);        
        error(eid,'%s',...
              'NDIMS(TMAP_B) is inconsistent with TDIMS_B and SIZE(TMAP_B).');
    end
    
    size_G = size(tmap_B);
    tsize_B(1:N) = size_G(1:N);
end

% Check T
if ~isempty(T)
    if ~istform(T)
        eid = sprintf('Images:%s:invalidTFORMStruct',mfilename);        
        error(eid,'%s','T is not a valid TFORM struct.');
    end
    
    if length(T) > 1
        eid = sprintf('Images:%s:multipleTFORMStructs',mfilename);        
        error(eid,'%s','T must be a single TFORM struct.');
    end
    
    if T.ndims_in ~= P
        eid = sprintf('Images:%s:dimsMismatchA',mfilename);        
        error(eid,'%s','T.NDIMS_IN must match LENGTH(TDIMS_A).');
    end
    
    if T.ndims_out ~= L
        eid = sprintf('Images:%s:dimsMismatchB',mfilename);        
        error(eid,'%s',...
              'T.NDIMS_OUT is inconsistent with LENGTH(TDIMS_B) or SIZE(TMAP_B).');
    end
end

if ~IsFinitePositiveIntegerRowVector( tsize_B )
    eid = sprintf('Images:%s:invalidTSIZE_B',mfilename);        
    error(eid,'%s',...
          'TSIZE_B must be a row vector of finite, positive integers.');
end

% tsize_B and tdims_B must have the same length.
if length(tsize_B) ~= N
    eid = sprintf('Images:%s:lengthMismatchB',mfilename);        
    error(eid,'%s','Lengths of TSIZE_B and TDIMS_B must match.');
end

%---------------------------------------------------------------------

function CheckInputArray( A )

if (~isnumeric(A) && ~islogical(A)) || issparse(A)
    eid = sprintf('Images:%s:invalidA',mfilename);        
    error(eid,'%s',...
          'A must be a non-sparse numeric or logical array.');
end

%---------------------------------------------------------------------

function CheckResampler( R, tdims_A )

if ~isresampler(R) || (length(R) ~= 1)
    eid = sprintf('Images:%s:invalidResampler',mfilename);        
    error(eid,'%s','R must be a valid resampler struct.');
end

if R.ndims ~= Inf && R.ndims ~= length(tdims_A)
    eid = sprintf('Images:%s:resamplerDimsMismatch',mfilename);        
    error(eid,'%s','R''s ''ndims'' field doesn''t match LENGTH(TDIMS_A).');
end

%---------------------------------------------------------------------

function F = CheckFillArray( F, osize )

if isempty(F)
    F = 0;
else
    if ~isa(F,'double') || issparse(F)
        eid = sprintf('Images:%s:invalidF',mfilename);        
        error(eid,'%s','F must be a non-sparse array of class double.');
    end
    
    % Validate SIZE(F), stripping off trailing singletons.
    size_F = size(F);
    last = max([1 find(size_F ~= 1)]);
    size_F = size_F(1:last);
    
    % SIZE_F can't be longer than OSIZE.
    N = length(osize);
    q = (length(size_F) <= N);
    if q
        % Add (back) enough singletons to make size_F the same length as OSIZE.
        size_F = [size_F ones(1,N-length(size_F))];
        
        % Each value in SIZE_F must be unity (or zero), or must match OSIZE.
        q = all(size_F == 1 | size_F == osize);
    end
    if ~q
        eid = sprintf('Images:%s:sizeMismatchFA',mfilename);        
        error(eid,'%s','SIZE(F) is inconsistent with the non-tranform sizes of A.');
    end
end

%---------------------------------------------------------------------

function q = IsFinitePositiveIntegerRowVector( v )

q = isa(v,'double')   ...
    & ~issparse(v)    ...
    & ndims(v) == 2   ...
    & size(v,1) == 1  ...
    & size(v,2) >= 1;

if q
    q = ~(~isreal(v)            ...
        | ~all(v == floor(v)) ...
        | ~all(isfinite(v))   ...
        | any(v < 1));
end
