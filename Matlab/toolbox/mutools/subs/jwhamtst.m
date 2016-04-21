% function [out,epkgdif,q] = jwhamtst(ham,zeroeps)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function [out,epkgdif,q] = jwhamtst(ham,zeroeps)

   epmeth = 0;
   kgmeth = 0;
   zeroeps = abs(zeroeps);

%  check if HAM is real
   realflg = 1;
   if any(any(imag(ham)))
     realflg = 0;
   end

%  get eigenvalues of HAM
   evls = eig(ham);

   outexact = [];
   if any(real(evls) == 0)
     if realflg == 1
       loc = find(real(evls)==0 & imag(evls) >= 0);
       outexact = sort(imag(evls(loc)));
     else
       loc = find(real(evls)==0);
       outexact = sort(imag(evls(loc)));
     end
   end

   q = min(abs(real(evls)));
   if q<zeroeps
     epmeth = 1;
     if realflg == 1
       loc = find( (abs(real(evls))<=zeroeps) & imag(evls) >= 0 );
     else
       loc = find( (abs(real(evls))<=zeroeps) );
     end
     outep = sort(imag(evls(loc)));
   end


   n = max(size(ham));
   [tmp,indmin] = min(abs(evls*ones(1,n)+ones(n,1)*evls'));
   if realflg == 1
     loc = find( indmin==[1:n] & (imag(evls)' >= 0) );
   else
     loc = find( indmin==[1:n] );
   end
   if ~isempty(loc) == 1
     kgmeth = 1;
     outkg = sort(imag(evls(loc)));
   end

   if epmeth == 0 & kgmeth == 0
     out = [];
     epkgdif = 0;
   elseif epmeth == 1 & kgmeth == 1
     out = sort([outep;outkg]);
     epkgdif = 0;
   elseif epmeth == 0 & kgmeth == 1
     out = outkg;
     epkgdif = 1;
   elseif epmeth == 1 & kgmeth == 0
     out = outep;
     epkgdif = 2;
   end
   out = out.';