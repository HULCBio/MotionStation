% function newsys = sclin(sys,inputs,fac)
%
%   Scale specified inputs of a SYSTEM or CONSTANT
%   matrix by a scalar number FAC or a SISO SYSTEM.
% or
%   Scale specified inputs of a VARYING
%   matrix by a scalar number FAC.
% or
%   Scale specified inputs of a VARYING
%   matrix by a VARYING number FAC.
%
%   See also: *, INDVCMP, MMULT, MSCL, SCLOUT, SCLIV and SEL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function newsys = sclin(sys,inputs,fac)

 if nargin < 3
   disp('usage: newsys = sclin(sys,inputs,fac)');
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(sys);
 [mtypei,nro,nco,mnumi] = minfo(inputs);
 [mtypef,mrowsf,mcolsf,mnumf] = minfo(fac);

 if max([nro,nco]) > mcols | min([nro,nco]) > 1 | ...
      max(inputs) > mcols | min(inputs) < 1 | ...
      floor(inputs) ~= ceil(inputs) | ~strcmp(mtypei,'cons')
   error('incorrect INPUT specification')
   return
 end
 if nco~=1
   inputs = inputs';
 end


 if mrowsf == 1 & mcolsf == 1
   if strcmp(mtype,'syst') & strcmp(mtypef,'cons')
     [a,b,c,d] = unpck(sys);
     b(:,inputs) = fac*b(:,inputs);
     d(:,inputs) = fac*d(:,inputs);
     newsys = pck(a,b,c,d);
   elseif (strcmp(mtype,'syst') | strcmp(mtype,'cons')) ...
               & strcmp(mtypef,'syst')
     for i=1:mcols
       if i == 1
         if max(inputs==1)
           newsys = fac;
         else
           newsys = 1;
         end
       else
         if max(inputs==i)
           newsys = daug(newsys,fac);
         else
           newsys = daug(newsys,1);
         end
       end
     end
     newsys = mmult(sys,newsys);
   elseif strcmp(mtype,'cons') & strcmp(mtypef,'cons')
     newsys = sys;
     newsys(:,inputs) = fac*sys(:,inputs);
   elseif strcmp(mtype,'empt') | strcmp(mtypef,'empt')
     newsys = [];
   elseif strcmp(mtype,'vary') & strcmp(mtypef,'cons')
     newsys = sys;
     newsys(1:mnum*mrows,inputs) = fac*sys(1:mnum*mrows,inputs);
   elseif strcmp(mtype,'vary') & strcmp(mtypef,'vary')
     code = indvcmp(sys,fac);
     if code == 1
       newsys = sys;
       for i=1:mnum
         newsys((i-1)*mrows+1:i*mrows,inputs) = ...
            fac(i,1)*sys((i-1)*mrows+1:i*mrows,inputs);
       end
     else
       error('inconsistent varying data')
       return
     end
   elseif strcmp(mtype,'cons') & strcmp(mtypef,'vary')
     newsys = zeros(mnumf*mrows+1,mcols+1);
     newsys(1:mnumf*mrows,1:mcols) = kron(ones(mnumf,1),sys);
     newsys(mnumf*mrows+1,mcols+1) = inf;;
     newsys(mnumf*mrows+1,mcols) = mnumf;;
     newsys(1:mnumf,mcols+1) = fac(1:mnumf,2);
     for i=1:mnumf
       newsys((i-1)*mrows+1:i*mrows,inputs) = fac(i,1)*sys(:,inputs);
     end
   else
     error('Incompatible matrix types')
     return
   end
 else
   error('FAC should have 1 input and 1 output')
   return
 end
%
%