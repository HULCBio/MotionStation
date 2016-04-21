% function [blkp,rp,fp,widd,widp,nrd,ncd,rnblk,rblk,rblkp] = ptrs(blk)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%  BLK is the user-defined block structure. It is a NBLK x 2
%  matrix of nonnegative integers. the i'th row of BLK describes
%  the dimensions of the i'th block in the perturbation structure.
%  if the i'th row of BLK is of the form  [ r c ], where r and c
%  are both positive, then the i'th block is a rxc full block.
%  if the i'th row of BLK is [ r 0 ], where r is positive, then
%  the i'th block is a repeated scalar block of dimension r. the
%  argument r must always be positive.
%
%  NBLK is the number of blocks in the block structure (it is the
%  row dimension of BLK)
%
%  BLKP is a NBLK+1 x 2 matrix of pointers for the block structure.
%  If Delta is a matrix with the correct block structure, then the
%  i'th pertubation block begins in row BLKP(i,1), and column BLKP(i,2)
%  (WARNING: since m*delta is square, though neither m nor Delta need
%  be square, to reference the block of m that the i'th pertubation
%  block feeds back across starts in row BLKP(i,2) of m, and column
%  BLKP(i,1))
%
%  RBLK is derived from BLK be replacing all of the repeated scalar
%  blocks with a different structure. in particular, if there is an
%  rxr repeated scalar block in BLK, then this turns into r 1x1 blocks
%  in RBLK. then, RNBLK and RBLKP are defined as above, but with reference
%  to RBLK.
%
%  RP is a pointer to the repeated scalar block of BLK. the number
%  of repeated scalar blocks in BLK is LENGTH(RP). for instance, if
%  RP(1) = 3, then this says that the first repeated scalar block
%  of BLK is the 3rd block.
%
%  FP is the analogue of RP but for full blocks.
%
%  in MU, the d-scaling matrices are returned as a row vector, and
%  may be unwrapped into their complete block diagonal form using
%  UNWRAPD. the variable WIDD gives the column dimension of this row
%  vector form of the d-scalings
%
%  in MU, the perturbation matrices are returned as a row vector, and
%  may be unwrapped into their complete block diagonal form using
%  UNWRAPP. the variable WIDP gives the column dimension of this row
%  vector form of the perturbations.
%
%  NRD is the row dimension of the perturbation, while NCD is the
%  column dimension of the perturbation. Modulo representing repeated
%  scalar blocks with zeros in the second column of BLK, NRD and NCD
%  are the column sums of BLK

function [blkp,rp,fp,widd,widp,nrd,ncd,rnblk,rblk,rblkp] = ptrs(blk)
  [nblk,dum] = size(blk);
  blkp = zeros(nblk+1,2);
  blkp(1,:) = [1 1];
  nrd = 0;
  ncd = 0;
  widp = 0;
  widd = 0;
  rp = [];
  fp = [];
  rblk = [];
  rnblk = 0;
  for i=1:nblk
    nrd = nrd + blk(i,1);
    if blk(i,2) == 0
      if blk(i,1) > 1
        rp = [rp i];
      else
        fp = [fp i];
      end
      ncd = ncd + blk(i,1);
      blkp(i+1,:) = blkp(i,:) + [blk(i,1) blk(i,1)];
      widp = widp + 1;
      widd = widd + blk(i,1)*blk(i,1);
      rblk = [rblk ; ones(blk(i,1),2)];
      rnblk = rnblk + blk(i,1);
    else
      fp = [fp i];
      blkp(i+1,:) = blkp(i,:) + blk(i,:);
      ncd = ncd + blk(i,2);
      widd = widd + 1;
      widp = widp + blk(i,1)*blk(i,2);
      rblk = [rblk ; blk(i,:)];
      rnblk = rnblk + 1;
    end
  end
  if nargout == 10
    rblkp = ptrs(rblk);
  end
%
%