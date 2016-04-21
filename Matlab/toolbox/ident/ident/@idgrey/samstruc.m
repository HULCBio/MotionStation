function errflag = samstruc(th1,th2)
%SAMSTRUC Checks if two IDMODELs have the same structure
%
%      err = samstuc(M1,M2)
%
%      err =[] id the structures of M1 and M2 coincide. Otherwise it contains
%      an error message.
%

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $ $Date: 2001/04/06 14:22:31 $

errflag=[];
if ~isa(th1,'idgrey')|~isa(th2,'idgrey')
   errflag=...
      ['Only models of the same type (IDSS, IDPOLY, IDGREY, IDARX) can  be merged.'];
   return
end
if   ~strcmp(th1.MfileName,th2.MfileName)
   errflag=['Only idgrey models with the same MfileName can be merged.'];
return   
end
err = 0;
if ~isempty(th1.FileArgument)
   if isempty(th2.FileArgument)
      err=1;
   else
      try
         if th1.FileArgument~=th2.FileArgument
            err = 1;
         end
      catch
         err = 1;
      end
   end
end
if err
   errflag=['Only idgrey models with the same FileArgument can be merged.'];
end

