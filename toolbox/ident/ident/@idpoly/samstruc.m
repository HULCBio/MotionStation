function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2001/04/06 14:22:21 $

errflag=[];
if ~isa(th1,'idpoly')|~isa(th2,'idpoly')
   errflag=...
      ['Only models of the same type (IDSS, IDPOLY, GREYBOX, IDARX) can  be merged.'];
   return
end
  if ~(th1.na==th2.na&all(th1.nb==th2.nb)&th1.nc==th2.nc&...
         th1.nd==th2.nd&all(th1.nf==th2.nf)&all(th1.nk==th2.nk))
      errflag=['Only models of the same orders can be merged.'];
   end
