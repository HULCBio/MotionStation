% function [trowd,trowg] = sigmaub(blk)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [trowd,trowg] = sigmaub(blk)

  [nblk,dum] = size(blk);
  trowd = [];
  trowg = [];
  blkcf = [];
  blkcr = [];
  blkr = [];
  for i=1:nblk
    if blk(i,1) < 0
      blkr = [blkr;blk(i,:)];
    elseif blk(i,2) == 0
      blkcr = [blkcr;blk(i,:)];
    else
      blkcf = [blkcf;blk(i,:)];
    end
  end
  blkn = [blkr;blkcr;blkcf];
  for i=1:nblk
    if blkn(i,2) == 0 & blkn(i,1) > 0 % COMPLEX REPEATED SCALAR
      trowd = [trowd reshape(eye(blkn(i,1)),1,blkn(i,1)^2)];
    elseif blkn(i,2) == 0 & blkn(i,1) < 0 % REAL REPEATED SCALAR
      trowd = [trowd reshape(eye(abs(blkn(i,1))),1,blkn(i,1)^2)];
      trowg = [trowg zeros(1,abs(blkn(i,1)))];
    elseif blkn(i,1) == -1 & blkn(i,2) == -1 % REAL 1x1
      trowd = [trowd 1];
      trowg = [trowg 0];
    else % COMPLEX FULL BLOCK
      trowd = [trowd 1];
    end
  end