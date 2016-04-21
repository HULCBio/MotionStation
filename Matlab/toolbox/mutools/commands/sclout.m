% function newsys = sclout(sys,outputs,fac)
%
%   Scale specified outputs of a SYSTEM or CONSTANT
%   matrix by a scalar number FAC or a SISO SYSTEM.
% or
%   Scale specified outputs of a VARYING
%   matrix by a scalar number FAC.
% or
%   Scale specified outputs of a VARYING
%   matrix by a VARYING number FAC.
%
%   See also: *, INDVCMP, MMULT, MSCL, SCLOUT, SCLIV and SEL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function newsys = sclout(sys,outputs,fac)

 if nargin < 3
   disp('usage: newsys = sclout(sys,outputs,fac)');
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 [mtypeo,nro,nco,mnumo] = minfo(outputs);
 [mtypef,mrowsf,mcolsf,mnumf] = minfo(fac);

 if max([nro,nco]) > mrows | min([nro,nco]) > 1 | ...
      max(outputs) > mrows | min(outputs) < 1 | ...
      floor(outputs) ~= ceil(outputs) | ~strcmp(mtypeo,'cons')
   error('incorrect OUTPUT specification')
   return
 end
 if nco~=1
   outputs = outputs';
 end

 if mrowsf == 1 & mcolsf == 1
   if strcmp(mtype,'syst') & strcmp(mtypef,'cons')
     [a,b,c,d] = unpck(sys);
     c(outputs,:) = fac*c(outputs,:);
     d(outputs,:) = fac*d(outputs,:);
     newsys = pck(a,b,c,d);
   elseif (strcmp(mtype,'syst') | strcmp(mtype,'cons')) ...
               & strcmp(mtypef,'syst')
     for i=1:mrows
       if i == 1
         if max(outputs==1)
           newsys = fac;
         else
           newsys = 1;
         end
       else
         if max(outputs==i)
           newsys = daug(newsys,fac);
         else
           newsys = daug(newsys,1);
         end
       end
     end
     newsys = mmult(newsys,sys);
   elseif strcmp(mtype,'cons') & strcmp(mtypef,'cons')
     newsys = sys;
     newsys(outputs,:) = fac*sys(outputs,:);
   elseif strcmp(mtype,'vary') & strcmp(mtypef,'cons')
     newsys = sys;
     therows = ksum([0:mnum-1]*mrows,outputs);
     newsys(therows,1:mcols) = fac*sys(therows,1:mcols);
   elseif strcmp(mtype,'vary') & strcmp(mtypef,'vary')
     code = indvcmp(sys,fac);
     if code == 1
       newsys = sys;
       for i=1:mnum
         newsys((i-1)*mrows+outputs,1:mcols) = ...
            fac(i,1)*sys((i-1)*mrows+outputs,1:mcols);
       end
     else
       error('Inconsistent varying data')
       return
     end
   elseif strcmp(mtype,'cons') & strcmp(mtypef,'vary')
     newsys = zeros(mnumf*mrows+1,mcols+1);
     newsys(1:mnumf*mrows,1:mcols) = kron(ones(mnumf,1),sys);
     newsys(mnumf*mrows+1,mcols+1) = inf;;
     newsys(mnumf*mrows+1,mcols) = mnumf;;
     newsys(1:mnumf,mcols+1) = fac(1:mnumf,2);
     for i=1:mnumf
       newsys((i-1)*mrows+outputs,1:mcols) = fac(i,1)*sys(outputs,:);
     end
   else
     error('Incompatible matrix types')
     return
   end
 else
   error('FAC should be a scalar')
   return
 end
%
%