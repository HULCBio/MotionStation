% function rat_d = prefit(blk,prevord,mpd,dsens)
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rat_d = prefit(blk,prevord,mpd,dsens)

  [nblk,dum] = size(blk);
  numd = nblk-1;
  rat_d = [];

  for i=1:numd
	sysd = fitsys(sel(mpd,1,i),prevord(i),sel(dsens,1,i),1);
	rat_d = ipii(rat_d,sysd,i);
  end