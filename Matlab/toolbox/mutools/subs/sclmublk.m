
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [matout,tmpblk] = sclmublk(mat,blk,fac)

  blkdim = blk;
  blkz = find(blk(:,2)==0);
  if ~isempty(blkz)
	blkdim(blkz,2) = blkdim(blkz,1);
  end
  blkpt = cumsum([1 1;blkdim]);

  srows = [];
  scols = [];
  matout = mat;
  for i=1:length(fac)
	if fac(i) ~= 0
		srows = [srows blkpt(i,2):blkpt(i+1,2)-1];
		scols = [scols blkpt(i,1):blkpt(i+1,1)-1];
		sfac = sqrt(fac(i));
		matout = sclout(matout,blkpt(i,2):blkpt(i+1,2)-1,sfac);
		matout = sclin(matout,blkpt(i,1):blkpt(i+1,1)-1,sfac);
	end
  end

  nzz = find(fac~=0);
  tmpblk = blk(nzz,:);