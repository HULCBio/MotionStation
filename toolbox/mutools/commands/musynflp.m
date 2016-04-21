% function [dsysl,dsysr] = musynfit(pre_dsysl,Ddata,sens,blk,nmeas,...
%                                    ncntrl,clpg,upbd,wt)
%
%   Fits the magnitude curve obtained by multiplying the old D
%   frequency response (from PRE_DSYSL) with the DDATA data.
%   Returns stable, minimum phase system matrices DSYSL and
%   DSYSR, which can be absorbed into the original interconnection
%   structure with multiplications (using MMULT), and one inverse
%   (using MINV). Once absorbed, a H_infinity design can be
%   performed, completing another iteration of MU-SYNTHESIS.
%
%   For the first MU-SYNTHESIS iteration, the variable
%   PRE_DSYSL should be set to the string  'first'
%   In subsequent iterations, PRE_DSYSL should be the previous
%   (left) rational D-scaling system matrix, DSYSL.
%
%   The (optional) variable CLPG is the matrix that produced the DDATA, SENS
%   and UPBD data. Upon fitting the DDATA, the stable, minimum phase
%   system matrices DSYSL and DSYSR, are absorbed into the original
%   matrix CLPG and plotted along with the UPBD data. A comparison of
%   these two plots provides insight into how well the rational system
%   matrices DSYSL and DSYSR fit the DDATA. The newly scaled matrix DMDI,
%   which is CLPG with DSYSL and DSYSR wrapped is then return. If CLPG
%   and UPBD are not provided, the default is to plot the SENS
%   variable instead.
%
%   The optional WT variable allows you to weight the DDATA, the default
%   is no additional weighting on the DDATA.
%
%   Identical to MUSYNFIT except that FITMAGLP is called instead of
%   FITMAG, and this calls MAGFIT.
%
%   See also: DKIT, FITMAGLP, FITSYS, MAGFIT, and MUFTBTCH and MUSYNFIT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [dsysl,dsysr] = musynflp(osysl,magdata,sens,blk,nmeas,ncntrl,...
                                    clpg,upbd,wt)
% CLPG has the Previous rational D's
% MAGDATA is the new incremental D's
% The returned DMDI is  DSYSL*CLPG*DSYSR^{-1}

if nargin < 6 | nargin == 7
 disp('usage: [dsysl,dsysr] = musynflp(pre_dsysl,Ddata,sens,blk,nmeas,ncntrl)')
 return
end

[nblk,x] = size(blk);
leftdim = nmeas;
 for i=1:nblk
  if blk(i,2) == 0
    leftdim = leftdim + blk(i,1);
    if blk(i,1) > 1
      disp('full Ds not implemented yet')
      return
    else
      blk(i,2) = 1;
    end
  else
    leftdim = leftdim + blk(i,2);
  end
 end

 [mtype,mrows,mcols,mnum] = minfo(magdata);
 omega = magdata(1:mnum,mcols+1);
 [stype,srows,scols,snum] = minfo(sens);
 if mnum ~= snum
   error('SENS & MAG data have diff # of points - rerun MU')
   return
 end
 if nargin == 9
   [wtype,wrows,wcols,wnum] = minfo(wt);
   if wnum ~= mnum
    error('NOMG & MAG data have diff # of points - rerun MU ')
    return
   end
   supwt = wt(1:mnum,1);
 else
   supwt = ones(mnum,1);
 end
 if nargin == 8
   if ~indvcmp(clpg,magdata)
    error('Closed-loop freq response (CLPG) & MAGDATA have different IVs')
    return
   end
 end

 if nargin > 6
   [dleft,dright] = unwrapd(magdata,blk);
   dmdi = mmult(dleft,clpg,minv(dright)); % rational D's, VABS(data)
 end
%  NORMALIZE THE DATA BY THE LAST DSCALE: This rapidly scales
%  all of the D-scalings by the inverse of the last D scaling.

   [ddd,ddrp,ddindv,dder] = vunpck(magdata);
   [ddrows,ddcols] = size(ddd);
   dddn = ddd(:,ddcols*ones(1,ddcols)).\ddd;
   magdata(1:ddrows,1:ddcols) = dddn;

 if isstr(osysl)
   if strcmp(osysl,'first');
     osysl_g = eye(leftdim);
   else
     error('First argument should be the string   ''first''   or a SYSTEM matrix')
     return
   end
 else
   [dum1,dum2,dum3,dum4] = minfo(osysl);
   if strcmp(dum1,'syst')
     osysl_g = frsp(osysl,omega);
   elseif strcmp(dum1,'cons')
     osysl_g = osysl;
   else
     error('First argument should be the string   ''first''   or a SYSTEM matrix')
     return
   end
 end

 loc = 1;
 dsysl = [];
 dsysr = [];
 for i=1:nblk-1
   wt = vpck((abs(sens(1:mnum,i) .* supwt)),omega);
   osysl_g_loc = sel(osysl_g,loc,loc);
   newdata = vabs(mmult(osysl_g_loc,sel(magdata,1,i)));
   heading = ['FITTING D SCALING #' int2str(i) ' of ' int2str(nblk-1)];
   if nargin == 6
     [scalard] = fitmaglp(newdata,wt,heading,osysl_g_loc);
   else
     [scalard] = fitmaglp(newdata,wt,heading,osysl_g_loc,dmdi,upbd,blk,i);
   end
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