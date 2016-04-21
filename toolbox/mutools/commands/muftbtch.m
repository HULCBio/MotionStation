% function [dsysl,dsysr] =
%      muftbtch(pre_dsysl,Ddata,sens,blk,nmeas,ncntrl,dim,wt)
%
%   Fit the magnitude curve obtained by multiplying the old D
%   frequency response (from PRE_DSYSL) with the DDATA data.
%   Returns stable, minimum phase system matrices DSYSL and
%   DSYSR, which can be absorbed into the original interconnection
%   structure with multiplications (using MMULT), and one inverse
%   (using MINV). Once absorbed, a H_infinity design can then be
%   performed, completing another iteration of MU-SYNTHESIS.
%
%   For the first MU-SYNTHESIS iteration, the variable
%   PRE_DSYSL should be set to the string  'first'.  In subsequent
%   iterations, PRE_DSYSL should be the previous (left) rational
%   D-scaling system matrix, DSYSL.
%
%   For MAGFIT the specification of dim=[hmax,htol,nmin,nmax]
%   (suggest dim=[.26,.1,0,3] to get a 3rd order fit of accuracy
%   of 1dB if possible.)
%
%   See also: FITMAG, FITSYS, MAGFIT, MUSYNFIT, MUFTBTCH, and MUSYNFLP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [dsysl,dsysr] = muftbtch(osysl,magdata,sens,blk,nmeas,ncntrl,dim,wt)

usg = 'usage: [dsysl,dsysr] =';
usg = [usg ' muftbtch(pre_dsysl,Ddata,sens,blk,nmeas,ncntrl,dim)'];

if nargin < 7, disp(usg); return
end
%
[nblk,x] = size(blk);
leftdim = nmeas;
 for i=1:nblk
  if blk(i,2) == 0
    leftdim = leftdim + blk(i,1);
    if blk(i,1) > 1
      disp('full Ds not implemented yet')
      return
    end
  else
    leftdim = leftdim + blk(i,2);
  end
 end
%
 [mtype,mrows,mcols,mnum] = minfo(magdata);
 omega = magdata(1:mnum,mcols+1);
 [stype,srows,scols,snum] = minfo(sens);
 if mnum ~= snum
   error('SENS & MAG data have diff # of points - rerun VMU')
   return
 end
 if nargin == 8
   [wtype,wrows,wcols,wnum] = minfo(wt);
   if wnum ~= mnum
    error('WT & MAG data have diff # of points - rerun VMU')
    return
   end
   supwt = wt(1:mnum,1);
 else
   supwt = ones(mnum,1);
 end
%
%  NORMALIZE THE DATA BY THE LAST DSCALE
%
 magdata(1:mnum,1:mcols-1) = ...
    inv(diag(magdata(1:mnum,mcols)))*magdata(1:mnum,1:mcols-1);
%
% MODIFICATION START %%%%%%%%%%%%%%
 if isstr(osysl)
   if strcmp(osysl,'first');
     osysl_g = eye(leftdim);
   else
     error('First argument should be the string   first   or a SYSTEM matrix')
     return
   end
 else
   [dum1,dum2,dum3,dum4] = minfo(osysl);
   if strcmp(dum1,'syst')
     osysl_g = frsp(osysl,omega);
   elseif strcmp(dum1,'cons')
     osysl_g = osysl;
   else
     error('First argument should be the string   first   or a SYSTEM matrix')
     return
   end
 end
% MODIFICATION END %%%%%%%%%%%%%%
 loc = 1;
 dsysl = [];
 dsysr = [];
 for i=1:nblk-1
   wt = vpck((abs(sens(1:mnum,i) .* supwt)),omega);
   osysl_g_loc = sel(osysl_g,loc,loc);
   newdata = vabs(mmult(osysl_g_loc,sel(magdata,1,i)));

 %  scalard = magfit(newdata,dim,wt);
   scalard = magfit(newdata,dim);
   tmpsys = [];
   for j=1:min([blk(i,1) blk(i,2)])
     tmpsys = daug(tmpsys,scalard);
   end
   dsysl = daug(dsysl,tmpsys);
   dsysr = daug(dsysr,tmpsys);
   if blk(i,1) < blk(i,2)
     for j=1:(blk(i,2)-blk(i,1))
       dsysl = daug(dsysl,scalard);
     end
   elseif blk(i,2) < blk(i,1)
     for j=1:(blk(i,1)-blk(i,2))
       dsysr = daug(dsysr,scalard);
     end
   end
   loc = loc + blk(i,2);
 end
 dsysl = daug(dsysl,eye(blk(nblk,2)+nmeas));
 dsysr = daug(dsysr,eye(blk(nblk,1)+ncntrl));
%
%