function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:59 $

errflag=[];
if ~isa(th1,'idarx')|~isa(th2,'idarx')
   errflag=...
      ['Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX) can  be merged.'];
   return
end
  if ~(all(all(th1.na==th2.na)')&all(all(th1.nb==th2.nb)') &all(all(th1.nk==th2.nk)'))
      errflag=['Only models of the same orders can be merged.'];
   end
