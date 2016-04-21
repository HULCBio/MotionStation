function [bz,az] = impinvar(b,a,Fs,tol)
%IMPINVAR Impulse invariance method for analog to digital filter conversion.
%   [BZ,AZ] = IMPINVAR(B,A,Fs) creates a digital filter with numerator
%   and denominator coefficients BZ and AZ respectively whose impulse 
%   response is equal to the impulse response of the analog filter with 
%   coefficients B and A sampled at a frequency of Fs Hertz.  The B and A
%   coefficients will be scaled by 1/Fs.
%
%   If you don't specify Fs, it defaults to 1 Hz.
%
%   [BZ,AZ] = IMPINVAR(B,A,Fs,TOL) uses the tolerance TOL for grouping 
%   repeated poles together.  Default value is 0.001, i.e., 0.1%.
%
%   NOTE: the repeated pole case works, but is limited by the
%         ability of the function ROOTS to factor such polynomials.
%
%   See also BILINEAR.

%   Added multiple pole capability, 3-Feb-96  J McClellan
%   Also, the filter gain is now multiplied by 1/Fs (per O&S, etc)

%   Author(s): J. McClellan, Georgia Tech, EE, DSP, 1990
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/13 00:18:01 $

error(nargchk(2,4,nargin))

if nargin<4,  tol = 1e-3; end
if nargin<3,  Fs = 1; end

[M,N] = size(a);
if ~xor(M==1,N==1)
    error(' A must be vector.')
end
[M,N] = size(b);
if M > 1 && N > 1
    error(' B must be vector.')
end

b = b(:);
a = a(:);
a1 = a(1);
if a1 ~= 0
% Ensure monotonicity of a
    a = a/a1;
end    
kimp=[];
if length(b) > length(a)
    error('Numerator B(s) degree must be no more than denominator A(s) degree.')
elseif  (length(b)==length(a))  
% remove direct feed-through term, restore later
    kimp = b(1)/a(1);
    b = b - kimp*a;  b(1)=[];
end

%--- Achilles Heel is repeated roots, so I adapted code from residue
%---  and resi2 here.  Now I can group roots, and there is no division.
pt = roots(a).';
Npoles = length(pt);
[mm,ip] = mpoles(pt,tol);
pt = pt(ip);
starts = find(mm==1);
ends = [starts(2:length(starts))-1;Npoles];
for k = 1:length(starts)
    jkl = starts(k):ends(k);
    polemult(jkl) = mm(ends(k))*ones(size(jkl));
    poleavg(jkl) = mean(pt(jkl))*ones(size(jkl));
end
rez = zeros(Npoles,1);
kp = Npoles;
while kp>0 
    pole = poleavg(kp);
    mulp = polemult(kp);
    num = b;
    den = poly( poleavg([1:kp-mm(kp),kp+1:Npoles]) );
    rez(kp) = polyval(num,pole) ./ polyval(den,pole);
    kp = kp-1;
    for k=1:mulp-1
        [num,den] = polyder(num/k,den);
        rez(kp) = polyval(num,pole) ./ polyval(den,pole);
        kp = kp-1;
    end
end

%----- Now solve for H(z) residues via impulse response matching
r = rez./gamma(mm);
p = poleavg;

az = poly(exp(p/Fs)).';
tn = (0:Npoles-1)'/Fs;
mm1 = mm(:).' - 1;
tt = tn(:,ones(1,Npoles)) .^ mm1(ones(size(tn)),:);
ee = exp(tn*p);
hh = ( tt.*ee ) * r;
bz = filter(az,1,hh);

if ~isempty(kimp)
% restore direct feed-through term
    bz = kimp*az(:) + [bz(:);0];
end
bz = bz/Fs;

bz = bz(:).';   % make them row vectors
az = az(:).';

cmplx_flag = any(imag(b)) | any(imag(a));
if ~cmplx_flag
   if  norm(imag([bz az]))/norm([bz az]) > 1000*eps
     warnStr = sprintf( ...
     ['  The output is not correct/robust.\n' ...
      '  Coeffs of B(s)/A(s) are real, but B(z)/A(z) has complex coeffs.\n' ...
      '  Probable cause is rooting of high-order repeated poles in A(s).']);
     warning(warnStr)
   end
   bz = real(bz);  
   az = real(az);
end
if a1~=0
    az = az*a1;
end
