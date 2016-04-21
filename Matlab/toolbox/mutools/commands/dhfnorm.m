% function out = dhfnorm(sys,ttol,h,iiloc)
%
%   Calculates the H_infinity norm of stable, discrete time SYSTEM
%   matrix, SYS, via a bilinear transformation and HINFNORM, or of VARYING
%   matrices, using PKVNORM. The second argument, TTOL, is used
%   for SYSTEM matrices, and is the relative tolerance
%   between the upper and lower bounds for the infinity
%   norm when the search is terminated. TTOL is optional with a
%   default value of 0.001. The optional third augment, H,
%   is the sample period (default = 1). The optional fourth
%   argument, IILOC, is for an initial frequency guess for
%   the worst case frequency, if desired.
%
%   For SYSTEM matrices, OUT is a 1x3 row vector, with the
%   lower bound, upper bound, and the frequency where the lower
%   bound occurs. For CONSTANT matrices, OUT is a 1x3 row vector,
%   with the NORM of the matrix in the 1st two entries and 0 for
%   the frequency. OUT is the PKVNORM of SYS if SYS is a VARYING
%   matrix.
%
%   See also: DHFSYN, HINFNORM, H2SYN, H2NORM, HINFCHK, HINFSYN,
%              HINFFI, NORM, PKVNORM, SDHFNORM, and SDHFSYN.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function out = dhfnorm(sys,ttol,h,iiloc)
 if nargin == 0
   disp('usage: out = dhfnorm(sys,ttol,h)')
   return
 end
 if nargin == 1
   ttol = 0.001;
   h=1;
   iiloc = 5*abs(rand(1,1));
 end
 if nargin == 2
   h=1;
   iiloc = 5*abs(rand(1,1));
 end
 if nargin == 3
   iiloc = 5*abs(rand(1,1));
 end


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
   if max(abs(eig(a))) >= 1
     error('SYSTEM has unstable poles')
     return
   end
   sys_c=bilinz2s(sys,h);
   iiloc_c=(2/h)*tan(iiloc*h/2);
   if nargout==1,
       out=hinfnorm(sys_c,ttol,iiloc_c);
       om_d=(2/h)*atan(out(3)*h/2);
       out(3)=om_d;
     else
      out0= hinfnorm(sys_c,ttol,iiloc_c);
      om_d=(2/h)*atan(out0(3)*h/2);
      out0(3)=om_d;
      disp(['norm between ' num2str(out0(1)) ' and ' num2str(out0(2))]);
      disp(['achieved near ' num2str(om_d)]);
    end, %if nargout==1
  end