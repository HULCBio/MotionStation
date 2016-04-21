function [d,blk] = ccdesign(nfactors,varargin)
%CCDESIGN Generate central composite design.
%   D=CCDESIGN(NFACTORS) generates a central composite design for
%   NFACTORS factors.  The output matrix D is N-by-NFACTORS, where N is
%   the number of points in the design.  Each row represents one run of
%   the design, and it has the settings of all factors for that run.
%   Factor values are normalized so that the cube points take values
%   between -1 and 1.
%   
%   D=CCDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...)
%   allows you to specify additional parameters and their values.
%   Valid parameters are the following:
%   
%      Parameter    Value
%      'center'     The number of center points to include, or 'uniform'
%                   to select the number of center points to give uniform
%                   precision, or 'orthogonal' (the default) to give an
%                   orthogonal design.
%      'fraction'   Fraction of full factorial for cube portion expressed
%                   as an exponent of 1/2:  0 = whole design, 1 = 1/2
%                   fraction, 2 = 1/4 fraction, etc.
%      'type'       Either 'inscribed', 'circumscribed', or 'faced'.
%      'blocksize'  The maximum number of points allowed in a block.
%   
%   [D,BLK]=CCDESIGN(...) requests a blocked design.  The output
%   vector BLK is a vector of block numbers.  Blocks are groups of
%   runs that are to be measured under similar conditions (for example,
%   on the same day).  Blocked designs minimize the effect of between-
%   block differences on the parameter estimates.
%
%   See also BBDESIGN, ROWEXCH, CORDEXCH.

%   Reference:
%      Box and Hunter (1957), Annals of Mathematical Statistics
   
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.2 $  $Date: 2003/11/01 04:25:23 $

if nfactors<2
   error('stats:ccdesign:BadNumFactors',...
         'Number of factors must be at least 2.')
end
okargs = {'center' 'fraction' 'type' 'blocksize'};
defaults = {[] [] 'circumscribed' Inf};
[eid,emsg,ncenter,frac,startype,blocksize] = ...
    statgetargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:ccdesign:%s',eid),emsg)
end

% Check for valid inputs
oktypes = {'circumscribed' 'inscribed' 'faced'};
if isempty(startype) | ~ischar(startype)
   i = [];
else
   i = strmatch(lower(startype), oktypes);
end
if isempty(i)
   error('stats:ccdesign:BadType',...
         'Valid types are ''inscribed'', ''circumscribed'', and ''faced''.');
end
startype = oktypes{i};
if blocksize ~= Inf
   if ~isnumeric(blocksize) | blocksize<1 | blocksize~=floor(blocksize)
      error('stats:ccdesign:BadBlockSize',...
            'Value of ''blocksize'' parameter must be a positive ingeger.');
   end
end
blocked = (nargout>=2) | isfinite(blocksize);

% Get generators for cube portion
[g,frac,bg] = getgen(nfactors,frac,blocked);
if isempty(g)
   error('stats:ccdesign:NoDesign',...
       'Cannot find design for %d factors with a 1/2^%d fractional cube.',...
       nfactors, frac);
end
nc = 2^(nfactors-frac);

% Generate star portion
ns = 2*nfactors;             % # star points
if isequal(startype,'faced')
   alpha = 1;
else
   alpha = nc^0.25;
end
ds = kron(eye(nfactors),[-alpha;alpha]);

% Select center points
if ischar(ncenter) & ~isempty(ncenter)
   okvals = {'uniform' 'orthogonal'};
   j = strmatch(lower(ncenter),okvals);
   if isempty(j)
      error('stats:ccdesign:BadCenter','Bad value for ''center'' parameter.');
   end
   ncenter = okvals{j};
end
useorth = false;
if isequal(ncenter,'uniform')
   [ncenter,useorth] = ncenterup(nfactors,frac);
   if useorth
      warning('stats:ccdesign:NoUniformPrecision',...
       ['Number of center points for uniform precision unknown for\n'...
       'this design, using center points for orthogonality instead.']);
   end
end
if isempty(ncenter) | isequal(ncenter,'orthogonal') | useorth
   % See Box & Hunter (1975), eqn. 81, with lambda4=0.
   ncenter = max(1,ceil(4*sqrt(nc) + 4 - 2*nfactors));
elseif prod(size(ncenter))~=1 | ncenter<0 | ncenter~=floor(ncenter)
   error('stats:ccdesign:BadCenter','Bad value for ''center'' parameter.');
end

% Now generate cube portion
dc = fracfact([g ' ' bg]);
if blocked
   blk = ones(nc,1);        % default, entire cube in one block
   if ~isempty(bg)
      % Separate design columns and block columns
      blkcols = dc(:,nfactors+1:end);
      dc = dc(:,1:nfactors);
      
      % Use as many block generators as required for this block size
      numblkgen = size(blkcols,2);
   else
      numblkgen = 0;
   end
   minblksize = 1 + max(ns, nc/(2^numblkgen));
   if minblksize>blocksize
      warning('stats:ccdesign:BlockSizeExceeded',...
          'Cannot find a design with fewer than %d runs per block.',...
          minblksize);
   end
   cblocksize = nc;         % block size in cube portion w/o center points
   if numblkgen>0
      b = ceil(log2(max(1,nc/(blocksize-1))));
      if b>0
         if b<size(blkcols,2)
            blkcols = blkcols(:,1:b);
         end
         [xxx1,xxx2,blk] = unique(blkcols,'rows');
         cblocksize = sum(blk==1);
      end
   end
   
   % Adjust number of center points if necessary to fit in blocks
   nblocks = max(blk)+1;
   ctrblks = getctrblks(ncenter,blocksize,nblocks,cblocksize,ns);
   if ncenter>length(ctrblks)
      warning('stats:ccdesign:CenterPointLimit',...
              'Block size limit allows only %d center points.',...
                      length(ctrblks));
      ncenter = length(ctrblks);
   elseif ncenter<nblocks
      warning('stats:ccdesign:CenterPointDeficit',...
        'Number of center points (%d) less than number of blocks (%d).',...
        ncenter,nblocks);
   end
end

% Generate complete design including center points
nruns = ns + nc + ncenter;
d = zeros(nruns,nfactors);
d(1:nc,:) = dc;
d(nc+1:nc+ns,:) = ds;

if blocked
   blk(nruns) = 0;
   blk(nc+1:nc+ns) = nblocks;
   blk(nc+ns+1:end) = ctrblks(1:ncenter);
end

% Inscribe the design if requested
if isequal(startype,'inscribed');
   d = d/alpha;
end

return;

% -----------------------------------------------
function [g,frac,blkgen] = getgen(nfactors,frac,blocked)
%GETGEN Get generator string given number of factors and fraction

% If no fraction specified, use the smallest supported fraction
% (highest exponent).
if nargin<2 | isempty(frac)
   bestfrac = [0 0 0 0 1 1 1 2 2 3 4];
   if nfactors <= length(bestfrac)
      frac = bestfrac(nfactors);
   else
      frac = 1;
   end
end

% Get generator string
g = '';
blkgen = '';
nletters = nfactors - frac;
alf = char(96+(1:nletters));

switch(nfactors)
 case 3,                               blkgen = 'abc';
 case 4,                               blkgen = 'abcd';
 case 5
  if     frac==0,                      blkgen = 'abc bcde';
  elseif frac==1, g = 'abcd'; end
 case 6
  if     frac==0, g = '';              blkgen = 'abcd cdef';
  elseif frac==1, g = 'abcde';         blkgen = 'abc'; end
 case 7
  if     frac==1, g = 'abcdef';        blkgen = 'abcd abef bdf'; end
 case 8
  if     frac==1, g = 'abcdefg';
  elseif frac==2; g = 'abcd abef';     blkgen = 'ace bdf'; end
 case 9
  if     frac==1, g = 'abcdefgh';
  elseif frac==2, g = 'abcde cdefg'; end
 case 10
  if     frac==1, g = 'abcdefghi';
  elseif frac==2, g = 'abcde defgh';
  elseif frac==3, g = 'abcd bceg acfg'; end
 case 11
  if     frac==1, g = 'abcdefghij';
  elseif frac==2, g = 'abcdef defghi';
  elseif frac==3, g = 'abcde bcdgh acefg';
  elseif frac==4, g = 'abcd bceg acfg abcdefg'; end
end

% We have no catalog of generators for fractions of larger designs,
% but the 1/2 fraction is easy.
if nfactors>11 & frac==1
   g = alf;
end

% That generator string specifies the factors that are confounded with
% the first few.  We also need the single-letter generators for these.
if frac==0 | ~isempty(g)
   g = [sprintf('%c ',alf), g];
end

if ~blocked, blkgen = ''; end


% ----------------------------------------
function [n0,useorth] = ncenterup(k,frac)
%NCENTERUP Compute number of center points for uniform precision.
%   According to Box & Hunter, Annals of Mathematical Statistics, 1957,
%   the following gives the number of center points required to make
%   the prediction variance in a central composite design be the same
%   at the origin as it is one unit from the origin.

% For now, use the number of center points recommended by B&H in their table
useorth = false;
if     k>=2 & k<=8 & frac==0
   v = [NaN 5 6 7 10 15 21 28];
   n0 = v(k);
elseif k>=5 & k<=8 & frac==1
   v = [NaN NaN NaN NaN 6 9 14 20];
   n0 = v(k);
elseif k==8        & frac==2
   n0 = 13;
else
   % For some designs we can't determine the number of centerpoints to
   % get uniform precision, so we'll use the number for orthogonality.
   useorth = true;
   n0 = [];
end


% --------------- 
function ctrblks = getctrblks(ncenter,blocksize,nb,cblocksize,sblocksize)
%GETCTRBLKS Get center point block assignments.
%    CTRBLKS = GETCTRBLKS(NCENTER,NBLOCKS,CBLOCKSIZE,SBLOCKSIZE) returns
%    a vector of block assignments for the center points for NCENTER
%    center points in NBLOCKS blocks having CBLOCKSIZE other points already
%    assigned to the cube blocks and SBLOCKSIZE points already assigned
%    to the star block.

nperblock = ceil(ncenter/nb);
maxncs = blocksize - sblocksize;  % max #center points for star block
maxncc = blocksize - cblocksize;  % same for each cube block

% Fit the desired center points into blocks to satisfy constraints
if sblocksize+nperblock>blocksize
   ncs = blocksize - sblocksize;                  % #ctr pts for star block
   ncc = ceil(min(maxncc, (ncenter-ncs)/(nb-1))); % same for each cube block
elseif cblocksize+nperblock>blocksize
   ncc = blocksize - cblocksize;
   ncs = min(maxncs, (ncenter-ncc*(nb-1)));
else
   ncs = nperblock;
   ncc = nperblock;
end

ncenter = min(ncenter, ncs+(nb-1)*ncc);
ctrblks = repmat((1:nb-1)',ncc,1);
ctrblks = [ctrblks(1:ncenter-ncs); repmat(nb,ncs,1)];
