% function rat_d = autod(clpg,blk,maxord,perctol,ddata,dsens,mubnd)
%
%	Automatically picks order for RATIONAL D-scalings,
%	by cycling through each one individually, making
%	sure that each rational fit does a good job with
%	all other D's set to their optimal (non-rational)
%	values.  Has adjustable MAXORD, and PERCTOL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rat_d = autod(clpg,blk,maxord,perctol,ddata,dsens,mubnd)

  omega = getiv(clpg);
  uppermu = vunpck(sel(mubnd,1,1));
  peakmu = max(uppermu);

  lowcutoff = 0.2;
  lowtestval = 0.1;

  lowmu_f = find(uppermu<lowcutoff*peakmu);
  low_pts = length(lowmu_f);
  lowmu = xtracti(sel(mubnd,1,1),lowmu_f);
  highmu_f = find(uppermu>=lowcutoff*peakmu);
  high_pts = length(highmu_f);
  highmu = xtracti(sel(mubnd,1,1),highmu_f);

  [nblk,dum] = size(blk);
  numd = nblk-1;
  minphased = [];
  rat_d = [];
  [dleft,dright] = unwrapd(ddata,blk);
  optscl_clpg = mmult(dleft,vrdiv(clpg,dright));
  for i=1:numd
	minphased = sbs(minphased,genphase(sel(ddata,1,i)));
  end
  for i=1:numd
	haved = 0;
	ord = 0;
	while haved == 0
		sysd = fitsys(sel(minphased,1,i),ord,sel(dsens,1,i),1);
		rat_d = ipii(rat_d,sysd,i);
		sysdg = frsp(sysd,omega);
		blksum = cumsum([1 1;blk]);
		inputs = [blksum(i,1):blksum(i+1,1)-1]';
		outputs = [blksum(i,2):blksum(i+1,2)-1]';
		dratodf = vrdiv(vabs(sysdg),sel(ddata,1,i));
		scl_clpg = sclin(sclout(optscl_clpg,outputs,dratodf),inputs,minv(dratodf));
		nscl_clpg = vnorm(scl_clpg);
		low_nscl = xtracti(nscl_clpg,lowmu_f);
		lowtest = msub(low_nscl,lowmu,lowtestval*peakmu);
		high_nscl = xtracti(nscl_clpg,highmu_f);
		hightest = msub(high_nscl,mscl(highmu,perctol));
		if ( all(vunpck(lowtest)<0) & all(vunpck(hightest)<0) ) | ord == maxord(i)
			haved = 1;
		else
			ord = ord+1;
		end
	end
  end