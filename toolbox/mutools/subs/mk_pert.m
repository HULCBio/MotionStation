%function rv = mk_pert(az,bw,nblk,blk,blkp,lb)
%	Makes a row vector perturbation from lower
%	bound data.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rv = mk_pert(az,bw,nblk,blk,blkp,lb)
 if lb <= 0
   rv = [];
 else
   rv = [];
   for i=1:nblk
     if blk(i,2) == 0
	if abs(az(blkp(i,2),1)) > 10*eps
            rv = [rv bw(blkp(i,1),1)/az(blkp(i,2),1)];
	  else
            rv = [rv 1];
	end %if az(
     else
       av = az(blkp(i,2):blkp(i+1,2)-1,1);
       bv = bw(blkp(i,1):blkp(i+1,1)-1,1);
       tmp = bv*av';
       sclfac = norm(bv)*norm(av);
	if sclfac > 10*eps
           tmp = tmp / sclfac;
	end %if sclfac
       for j=1:blk(i,1)
         rv = [rv tmp(j,:)];
       end
     end
   end
   rv = (1.0/lb)*rv;
 end
%
%