function [d,blk] = bbdesign(nfactors,varargin)
%BBDESIGN Generate Box-Behnken design.
%   D=BBDESIGN(NFACTORS) generates a Box-Behnken design for NFACTORS
%   factors.  The output matrix D is N-by-NFACTORS, where N is the
%   number of points in the design.  Each row lists the settings for
%   all factors, scaled between -1 and 1.
%
%   D=BBDESIGN(NFACTORS,'PNAME1',pvalue1,'PNAME2',pvalue2,...)
%   allows you to specify additional parameters and their values.
%   Valid parameters are the following:
% 
%       Parameter    Value
%       'center'     The number of center points to include.
%       'blocksize'  The maximum number of points allowed in a block.
%
%   [D,BLK]=BBDESIGN(...) requests a blocked design.  The output
%   vector BLK is a vector of block numbers.
%
%   Box and Behnken proposed designs when the number of factors was
%   equal to 3-7, 9-12, or 16.  This function produces those designs.
%   For other values of NFACTORS, this function produces designs
%   that are constructed in a similar way, even though they were not
%   tabulated by Box and Behnken and they may be too large to be
%   practical.
%
%   See also CCDESIGN, ROWEXCH, CORDEXCH.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.2 $  $Date: 2003/11/01 04:25:00 $

okargs = {'center' 'blocksize'};
defaults = {[] Inf};
[eid,emsg,ncenter,blocksize] = statgetargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:bbdesign:%s',eid),emsg)
end

if ~isnumeric(nfactors) | prod(size(nfactors))~=1
   error('stats:bbdesign:BadNumFactors',...
         'Number of factors must be an integer 3 or larger.');
elseif nfactors<3 | nfactors~=floor(nfactors)
   error('stats:bbdesign:BadNumFactors',...
         'Cannot generate Box-Behnken design for %g factors.', nfactors);
end

% Select center points
if isempty(ncenter)
   ncenter = getncenter(nfactors);
end
if prod(size(ncenter))~=1 | ncenter<0 | ncenter~=floor(ncenter)
   error('stats:bbdesign:BadCenter','Bad value for ''center'' parameter.');
end

% Check block size
if blocksize ~= Inf
   if ~isnumeric(blocksize) | blocksize<1 | blocksize~=floor(blocksize)
      error('stats:bbdesign:BadBlockSize',...
            'Value of ''blocksize'' parameter must be a positive ingeger.');
   end
end

% Get component designs with their blocking structure
[B,Bb] = getbibd(nfactors);
[F,Fb] = getfactorial(nfactors);

% Merge the designs, add centerpoints, and define blocks
wmsg = '';
d = mergeBF(B,F,ncenter,nfactors);
if nargout>=2
   nb = size(B,1);
   nf = size(F,1);
   [ctrwng,blk] = blockBF(nb,nf,Bb,Fb,ncenter,nfactors,blocksize);
   if ctrwng
      warning('stats:bbdesign:CenterPointDeficit',...
        'Number of center points (%d) less than number of blocks (%d).',...
        ncenter,max(blk));
   end
end

if nargout>=2
   if isempty(blk)
      % If no blocking is possible, then everything is in block 1
      blk = ones(size(d,1),1);
   end

   b0 = max(histc(blk,1:max(blk)));
   if b0>blocksize
      warning('stats:bbdesign:BlockSizeExceeded',...
             'Actual block size (%d) is larger than requested size (%d).',...
             b0,blocksize);
   end
end

% -----------------------------------
function n = getncenter(k)
%GETNCENTER Get default number of center points for Box-Behnken design.

v = [NaN NaN 3 3   6 6 6 8   10 10 12 12   12 12 12 12];
n = v(min(k,length(v)));

% -----------------------------------
function [B,Bb] = getbibd(k)
%GETBIBD Get BIBD or PBIBD component design for Box-Behnken design.
%   Returns the balanced or partially balanced incomplete blocked
%   design required to generate a Box-Behnken design, plus a set
%   of block assignments if the design can be blocked based on the
%   BIBD component.

Bb = [];
if k==3
   B = [1 2; 1 3; 2 3];
elseif k==4
   B = [1 2; 3 4; 1 4; 2 3; 1 3; 2 4];
   Bb= [  1;   1;   2;   2;   3;   3];
elseif k==5
   B = [1 2; 3 4; 2 5; 1 3; 4 5; 2 3; 1 4; 3 5; 1 5; 2 4];
   Bb= [  1;   1;   1;   1;   1;   2;   2;   2;   2;   2];
elseif k==6
   B = [1 2 4; 2 3 5; 3 4 6; 1 4 5; 2 5 6; 1 3 6];
elseif k==7
   B = [4 5 6; 1 6 7; 2 5 7; 1 2 4; 3 4 7; 1 3 5; 2 3 6];
elseif k==9
   B = [1 4 7; 2 5 8; 3 6 9; 1 2 3; 4 5 6; 7 8 9;1 5 9; 3 4 8; 2 6 7;
        1 6 8; 2 4 9; 3 5 7; 1 4 7; 2 5 8; 3 6 9];
   Bb=[     1;     1;     1;     2;     2;     2;    3;     3;     3;
            4;     4;     4;     5;     5;     5];
elseif k==10
   B = [2 6 7 10; 1 2 5 10; 2 3 7 8; 2 4 6 9; 1 8 9 10;
        3 4 5 10; 1 4 7 8 ; 3 5 7 9; 1 3 6 9; 4 5 6 8];
elseif k==11
   B = [3 7 8 9 11; 1 4 8 9 10; 2 5 9 10 11; 1 3 6 10 11;
        1 2 4 7 11; 1 2 3 5 8 ; 2 3 4 6 9  ; 3 4 5 7 10 ;
        4 5 6 8 11; 1 5 6 7 9 ; 2 6 7 8 10];
elseif k==12
   B = [1 2 5 7 ; 2 3 6 8 ; 3 4 7 9 ; 4 5 8 10 ; 5 6 9 11 ; 6 7 10 12;
        1 7 8 11; 2 8 9 12; 1 3 9 10; 2 4 10 11; 3 5 11 12; 1 4 6 12];
elseif k==16
   B = [1 2 6 9  ; 3 4 8 11 ; 5 10 13 14; 7 12 15 16;
        2 3 7 10 ; 1 4 5 12 ; 6 11 14 15; 8 9 13 16 ;
        2 5 6 13 ; 4 7 8 15 ; 1 9 10 14 ; 3 11 12 16;
        3 6 7 14 ; 1 5 8 16 ; 2 10 11 15; 4 9 12 13 ;
        1 3 13 15; 2 4 14 16; 5 7 9 11  ; 6 8 10 12 ;
        4 6 10 16; 3 5 9 15 ; 1 7 11 13 ; 2 8 12 14];
   Bb= [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6]';
else
   % The following generates all pairs of factor numbers
   p = (k-1):-1:2;
   I = zeros(k*(k-1)/2,1);
   I(cumsum([1 p])) = 1;
   I = cumsum(I);
   J = ones(k*(k-1)/2,1);
   J(cumsum(p)+1) = 2-p;
   J(1)=2;
   J = cumsum(J);
   B = [I J];
end   

% -----------------------------------
function [F,Fb] = getfactorial(k)
%GETFACTORIAL Get factorial component design for Box-Behnken design.

if ismember(k,[6 7 9])
   F = fracfact('a b c');
   Fb = prod(F,2);
   Fb = 1 + (Fb>0);
elseif ismember(k,[10 12 16])
   F = fracfact('a b c d');
   Fb = prod(F,2);
   Fb = 1 + (Fb>0);
elseif k==11
   F = fracfact('a b c d abcd');
   Fb = [];
else
   % This will produce the Box-Behnken designs for 3-5 factors.
   % It will also produce designs for larger numbers of factors
   % based on the 2^2 factorial.  These designs may be too large
   % for most practical uses, so they were not tabulated by Box
   % and Behnken.
   F = fracfact('a b');
   Fb = [];
end

% -----------------------------------
function d = mergeBF(B,F,ncenter,nfactors)
%MERGEBF Merge BIB and factorial components to get a Box-Behnken design.

% Measure the designs
nf = size(F,1);
nb = size(B,1);
nruns = nb*nf + ncenter;

% Get row and column indices for inserting F into B
r = repmat((1:nf*nb)',1,size(F,2));
r = r(:);
c = B(:)';
c = c(ones(nf,1),:);
c = c(:);

% Create full-size design and insert multiple copies of F
d = zeros(nruns,nfactors);
d(sub2ind(size(d),r,c)) = repmat(F,nb,1);

% -----------------------------------
function [ctrwng,blk] = blockBF(nb,nf,Bb,Fb,ncenter,nfactors,blocksize)
%BLOCKBF Block merged BIB and factorial components of Box-Behnken design.

% Measure the designs
ctrwng = false;
nruns = nb*nf + ncenter;

% Sometimes there's a choice, so look at the requested block size.
if nfactors==9 | nfactors==16
   if (nruns/2 <= blocksize)           % Factorial blocks are small enough
      Bb = [];
   elseif (nruns/max(Bb) <= blocksize) % BIB blocks are small enough
      Fb = [];
   % else we need to block on both designs, so don't empty either one out
   end
end

% First block the non-center points
if isempty(Fb) & ~isempty(Bb)
   % Blocking on the BIB design
   blk = Bb';
   blk = blk(ones(nf,1),:);
   blk = blk(:);
elseif isempty(Bb) & ~isempty(Fb)
   % Block on higher-level factorial interactions
   blk = repmat(Fb,nb,1);
elseif ~isempty(Fb) & ~isempty(Bb)
   % Block on both
   blk = Bb';
   blk = blk(ones(nf,1),:);
   blk = 2*(blk(:)-1);           % block numbers 0; 2; etc.
   blk = blk + repmat(Fb,nb,1);  % block numbers 1, 2; 3, 4; etc.
else
   blk = [];
end

% Check the blocking assignments, and take care of center points
if ~isempty(blk)
   nblocks = max(blk);
   if nblocks>ncenter
      ctrwng = true; % warn that we can't have a center point in each block
   end

   % Distribute the center points evenly across blocks
   cblk = 1:nblocks;
   cblk = cblk(ones(ceil(ncenter/length(cblk)),1),:);
   cblk = cblk(1:ncenter);
   blk = [blk; cblk(:)];
end
