function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:22:23 $

errflag=[];
if ~isa(th1,'idss')|~isa(th2,'idss')
   errflag=...
      ['Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX) can  be merged.'];
   return
end
arg1=[th1.As,th1.Bs,th1.Cs',th1.Ks,th1.X0s];
arg2=[th2.As,th2.Bs,th2.Cs',th2.Ks,th2.X0s];
err=0;
try
   if ~all(all(isnan(arg1)==isnan(arg2))'),err=1;end
   if ~all(all(arg1(find(~isnan(arg1)))==arg2(find(~isnan(arg2))))'),err=1;end
   if ~all(all(isnan(th1.Ds)==isnan(th2.Ds))'),err=1;end
   if ~all(all(th1.Ds(find(~isnan(th1.Ds)))==th2.Ds(find(~isnan(th2.Ds))))'),err=1;end
catch
   err = 1;
end

if err
   errflag=['State-space models must have the same underlying structure.'];
   return
end
