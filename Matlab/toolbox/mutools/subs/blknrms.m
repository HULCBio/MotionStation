%function cm = blknrms(mat,blk)
%
%   Takes block by block norms of matrix MAT.
%   BLK represents the block structure associated with MAT.
%
%   See also: BLKNORM, MU, PKVNORM, VNORM, and VSVD.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function cm = blknrms(mat,blk)

[mrows,mcols] = size(mat);
[nblk,dum] = size(blk);
  for i=1:nblk
    if blk(i,2)==0
       blk(i,2)=blk(i,1);
    end %if
  end %for
  [blkp,repp,fulp,wd,wpert,nrd,ncd] = ptrs(blk);
     % see PTRS for definitions of these variables
  if nrd ~= mcols | ncd ~= mrows
    error('MATIN dimensions incompatible with BLK dimensions')
    return
  end

 for i=1:nblk
   for j=1:nblk
     cm(i,j) = norm(mat(blkp(i,2):blkp(i+1,2)-1,blkp(j,1):blkp(j+1,1)-1));
   end
 end

%
%