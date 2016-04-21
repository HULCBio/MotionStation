%function out = blknorm(mat,blk)
%
%   Takes block by block norms of the input matrix MAT.
%   BLK represents the block structure associated with MAT.
%   Note that all blocks are treated as full block
%   regardless of their block structure.
%
%   See also: MU, PKVNORM, VNORM, and VSVD.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = blknorm(mat,blk)
  if nargin < 2
    disp('usage: out = blknorm(mat,blk)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nblk,dum] = size(blk);
  for i=1:nblk
    if blk(i,2)==0
       blk(i,2)=blk(i,1);
    end %if
  end %for
  [nr,nc] = size(mat);
    if mtype == 'cons'
      out = blknrms(mat,blk);
    elseif mtype == 'vary'
      omega = mat(1:mnum,mcols+1);
      npts = mnum;
      nrout = nblk;
      ncout = nblk;
      out = zeros(npts*nrout+1,ncout+1);
      ftop = (npts+1)*mrows;
      ptop = 1:mrows:ftop;
      ptopm1 = ptop(2:npts+1) - 1;
      for i=1:npts
        out((i-1)*nrout+1:i*nrout,1:ncout) = ...
           blknrms(mat(ptop(i):ptopm1(i),1:mcols),blk);
      end
      out(1:mnum,ncout+1) = omega;
      out(nrout*mnum+1,ncout) = npts;
      out(nrout*mnum+1,ncout+1) = Inf;
    elseif mtype == 'syst'
      error('BLKNORM is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
%
%