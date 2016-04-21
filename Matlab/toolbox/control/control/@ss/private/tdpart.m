function [bp,nblocks] = tdpart(Td)
%TDPART  Block partitioning of delay time matrices.
%
%  [BP,N] = TDPART(TD) partitions the delay time matrix TD
%  into blocks that are a superposition of input and output
%  delays.  TDPART seeks to minimize the number N of blocks.
%  The resulting block partition BP is a nested cell array
%  representing the tree of block partitions.  Each node in
%  BP specifies how to split the current block B into 
%  B = [B1 , B2] or B = [B1 ; B2].  These nodes are of the 
%  form
%    { [block col sizes] , BP1 , BP2 }  
%  or
%    { [block row sizes] ; BP1 ; BP2 }  
%  where BP1 and BP2 specify how to further partition the 
%  subblocks B1 and B2.  Terminal nodes are set to {}.
%
%  See also C2D, D2D, PADE.

%   Author: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:02:52 $

% Note: choose column-wise partition when possible (because 
% of input-by-input simulation in LINRESP and IMPRESP)
if ~any(Td(:)),
   bp = {};
   nblocks = 1;
   return
end

% Compute block separator matrix (result of DxDy(Td))
tolzero = 1e4*eps;
Sep = diff(diff(Td(:,:,:),1,1),1,2);
Sep = any(abs(Sep)>tolzero*max(Td(:)),3);

% Recursively partition Td based using the information in SEP
rlimit = get(0,'RecursionLimit');
set(0,'RecursionLimit',1e4);

[bp,nblocks] = rsplit(Td,Sep);

set(0,'RecursionLimit',rlimit);
   

% Make sure this partition is better than the trivial row-by-row 
% or column-by-column partition
[ny,nu] = size(Td(:,:,1));
if nblocks>=min(ny,nu),
   % Replace by row-by-row partition if ny<nu, col-by-col 
   % partition otherwise
   nblocks = min(ny,nu);
   bp = hvsplit(Td,1+(ny>=nu));
end
   
      
%%%%%%%% Subfunction RSPLIT %%%%%%%%%%%%%%%%

function [P,nblocks] = rsplit(B,Sep)
%RSPLIT  Splits a block B horizontally or vertically.
%        The block separation matrix SEP is used to 
%        decide where and how to split in order to 
%        keep the overall block count as small as 
%        possible.

[nr,nc] = size(Sep);
ny = nr+1;  
nu = nc+1;

% Termination cases (recursion exited here)
if ~any(Sep(:)),
   % Block B is in the desired format (terminal node)
   P = {};  
   nblocks = 1;  
   return
elseif min(nr,nc)==1,
   % Split B into two rows or two columns
   P = cat(2-(nr==1),{[1 1]},{},{});
   nblocks = 2;  
   return
end

% ROWSUMS (COLSUMS) count how many separating ones are contained in
% each row (column) of SEP.  Find the row and column with highest density
% of ones, called best row split (BRS) and best column split (BCS)
RowSums = sum(Sep,2);
ColSums = sum(Sep,1);
if min(RowSums)+min(ColSums)>=min(nr,nc),
   % No partition can do better than unit-row or unit-column splitting
   P = hvsplit(B,1+(ny>=nu));
   nblocks = min(ny,nu);
   return
end
[rsmax,brs] = max(RowSums);
[csmax,bcs] = max(ColSums);

% Compute the booleans LEFT, RIGHT, UP, DOWN defined by
%   LEFT (RIGHT) = 1 if BRS has one entries left (right) of BCS
%   UP (DOWN) = 1 if BCS has one entries above (below) BRS
left = any(Sep(brs,1:bcs-1));
right = any(Sep(brs,bcs+1:nc));
up = any(Sep(1:brs-1,bcs));
down = any(Sep(brs+1:nr,bcs));

% Determine whether to partition along BRS or BCS
% SPLITDIR = 1 -> BCS,  SPLITDIR = 2 -> BRS
if rsmax==1 & csmax==1,
   % Delays consist of input+output delays, plus uniform delay 
   % THETA in one of the four blocks with corners at (BRS,BCS).
   % Splitting direction affects number of delay blocks needed
   % to represent THETA.  Compute THETAS using 2x2 window 
   % centered at (BRS,BCS)
   Window = B([brs brs+1],[bcs bcs+1],:);
   Theta = Window(1,1,:) + Window(2,2,:) - Window(1,2,:) - Window(2,1,:);
   OKloc = all(repmat(abs(Theta),[ny nu])<=B,3);
   
   if all(Theta>=0),
      % Additional delays in blocks (1,1) or (2,2)
      OK11 = OKloc(1:brs,1:bcs);   
      OK22 = OKloc(brs+1:ny,bcs+1:nu);
      if min(size(OK11))<=min(size(OK22)) & (all(OK11(:)) | ~all(OK22)),
         SplitDir = 1 + (brs>=bcs);
      else
         SplitDir = 1 + (ny-brs>=nu-bcs);
      end
   elseif all(Theta<0),
      % Additional delays in blocks (1,2) or (2,1)
      OK12 = OKloc(1:brs,bcs+1:nu);   
      OK21 = OKloc(brs+1:ny,1:bcs);
      if min(size(OK12))<=min(size(OK21)) & (all(OK12(:)) | ~all(OK21)),
         SplitDir = 1 + (brs>=nu-bcs);
      else
         SplitDir = 1 + (ny-brs>=bcs);
      end
   else
      SplitDir = 2;
   end
   
elseif rsmax==1 | csmax==1,
   % Either BRS or BCS contains a single one entry
   SplitDir = 1+(rsmax>=csmax);
   
elseif left+right+up+down == 3,
   % T-shaped junction  
   SplitDir = 1 + (up+down==1);
   
elseif left+right+up+down<4,
   % L-shaped junction 
   % Handle trivial cases where half of SEP is all zeros
   % RE: Watch for ~any([])=1 (wrong partition of [0 0 0;0 0 0;1 1 1;1 1 1;0 0 0]);
   ix = [brs+1:(up*nr) , 1:(~up*brs)-1];
   jx = [bcs+1:(left*nc) , 1:(~left*bcs)-1];
   Six = Sep(ix,:);  % block below BRS if up=1, above BRS otherwise
   Sjx = Sep(:,jx);  % block right of BCS if left=1, left of BCS otherwise
   if length(Sjx) & ~any(Sjx(:)),
      % SJX is all zeros: split vertically
      SplitDir = 1;
   elseif length(Six) & ~any(Six(:)),
      % SIX is all zeros: split horizontally
      SplitDir = 2;
   else
      % Other cases: explore both options
      SplitDir = [1 2];
   end
   
else
   % X-shaped junction
   % Stay on the safe side and explore both options (akeen of dynamic 
   % programming optimization)
   SplitDir = [1 2];
   
end


% Recursively split B
itail = cell(1,ndims(B)-2);
itail(:) = {':'};

if isequal(SplitDir,1)
   % Split along BCS
   [P1,nb1] = rsplit(B(:,1:bcs,itail{:}),Sep(:,1:bcs-1));
   [P2,nb2] = rsplit(B(:,bcs+1:end,itail{:}),Sep(:,bcs+1:nc));
   P = {[bcs nu-bcs] , P1 , P2};
   nblocks = nb1 + nb2;
elseif isequal(SplitDir,2)
   % Split along BRS
   [P1,nb1] = rsplit(B(1:brs,:,itail{:}),Sep(1:brs-1,:));
   [P2,nb2] = rsplit(B(brs+1:end,:,itail{:}),Sep(brs+1:nr,:));
   P = {[brs ny-brs] ; P1 ; P2};
   nblocks = nb1 + nb2;
else
   % Try both options and keep the best one
   % BRS split
   [Pr1,nbr1] = rsplit(B(1:brs,:,itail{:}),Sep(1:brs-1,:));
   [Pr2,nbr2] = rsplit(B(brs+1:end,:,itail{:}),Sep(brs+1:nr,:));
   % BCS split
   [Pc1,nbc1] = rsplit(B(:,1:bcs,itail{:}),Sep(:,1:bcs-1));
   [Pc2,nbc2] = rsplit(B(:,bcs+1:end,itail{:}),Sep(:,bcs+1:nc));
   
   if nbr1+nbr2<nbc1+nbc2,
      % Go with BRS
      P = {[brs ny-brs] ; Pr1 ; Pr2};
   else
      P = {[bcs nu-bcs] , Pc1 , Pc2};
   end
   nblocks = min(nbr1+nbr2,nbc1+nbc2);
end



%%%%%%%% Subfunction HVSPLIT %%%%%%%%%%%%%%%%

function P = hvsplit(B,dim)
%HVSPLIT  Splits B row by row (DIM=1) or column by column (DIM=2)

[nr,nc] = size(B(:,:,1));
itail = cell(1,ndims(B)-2);
itail(:) = {':'};

if min(nr,nc)==1,
   P = {};
elseif dim==1,
   % row-wise split
   P = {[1 nr-1] ; {} ; hvsplit(B(2:end,:,itail{:}),1)};
else
   P = {[1 nc-1] , {} , hvsplit(B(:,2:end,itail{:}),2)};
end
