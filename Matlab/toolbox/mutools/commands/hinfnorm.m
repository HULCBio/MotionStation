% function out = hinfnorm(sys,ttol,iiloc)
%
%   Calculates the H_infinity norm of stable, SYSTEM
%   matrices, using the Hamiltonian method, or of VARYING
%   matrices, using PKVNORM. The second argument is used
%   for SYSTEM matrices, and is the relative tolerance
%   between the upper and lower bounds for the infinity
%   norm when the search is terminated. There is an optional
%   third argument, for a initial frequency guess, if desired.
%   for SYSTEM matrices, OUT is a 1x3 row vector, with the
%   lower bound, upper bound, and the frequency where the lower
%   bound occurs. The default value for TTOL is 0.001.
%
%   See also: H2SYN, H2NORM, HINFCHK, HINFSYN, and HINFFI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function out = hinfnorm(sys,ttol,iiloc)
 if nargin == 0
   disp('usage: out = hinfnorm(sys,ttol)')
   return
 end
 if nargin == 1
   ttol = 0.001;
   iiloc = 5*abs(rand(1,1));
 end
 if nargin == 2
   iiloc = 5*abs(rand(1,1));
 end
%for j-w axis eigenvalue test
 defzero = 1e-9;

 [mtype,mrows,mcols,mnum] = minfo(sys);
 if mtype == 'vary'
   out = pkvnorm(sys);
 elseif mtype == 'cons'
   if nargout == 1
     out = norm(sys);
     out = [out out 0];
   else
     disp(['SYSTEM is a constant, norm is ' num2str(norm(sys))])
   end
 else
   [a,b,c,d] = unpck(sys);
   if max(real(eig(a))) >= 0
     disp('SYSTEM has closed-right-half plane poles')
     if nargout == 1
       out = [inf inf 0];
     end
     return
   end
   nd = norm(d);
   code = hinfchk(sys,ttol,defzero);
   if isempty(code) & nd < ttol
     if nargout == 0
       disp(['Norm is less than ' num2str(ttol) ' (tolerance)']);
     else
       out = [0 ttol 0];
     end
     return
   end
   idn = eye(mnum);
   [p,hesa] = hess(a);
   hesb = p' * b;
   hesc = c * p;
   g = hesa \ hesb;
   tfzero = d - hesc*g;
   ntfz = norm(tfzero);
   tfiiloc = (sqrt(-1)*iiloc*idn - hesa) \ hesb;
   nnn = norm(hesc*tfiiloc + d);
   if nd >= ntfz
     if nd >= nnn
       nrma = nd;
       loc = inf;
     else
       nrma = nnn;
       loc = iiloc;
     end
   else
     if ntfz >= nnn
       nrma = ntfz;
       loc = 0;
     else
       nrma = nnn;
       loc = iiloc;
     end
   end
   if nrma == 0
     nrmt = 1e-8;
   else
     nrmt = (1+ttol)*nrma;
   end
   code = hinfchk(sys,nrmt,defzero);
   j = 0;

   maxit = 100;
   while j < maxit
     j = j+1;
     if isempty(code)
       if nargout == 0
         disp(['norm between ' num2str(nrma) ' and ' num2str(nrmt)]);
         disp(['achieved near ' num2str(loc)]);
       else
         out = [nrma nrmt loc];
       end
       j = maxit + 1;
     else
       if length(code) == 1
         probfreq = code;
       else
         probfreq = geosplit(code);
       end
       tmp = 0;
       for jj=1:length(probfreq)
         g = ( (sqrt(-1)*probfreq(jj)) * idn - hesa) \ hesb;
         xtry = norm(d + hesc*g);
         if xtry > tmp
           tmp = xtry;
           loc = probfreq(jj);
         end
       end
       nrma = tmp;
       nrmt = (1+ttol)*nrma;
       code = hinfchk(sys,nrmt,defzero);
     end
   end
   if j == maxit
      disp('HINFNORM iteration DID NOT converge')
      disp(['a lower bound for the norm is ' num2str(nrma)]);
      if nargout == 1
        out = [nrma inf loc];
      end
   end
 end
%
%
