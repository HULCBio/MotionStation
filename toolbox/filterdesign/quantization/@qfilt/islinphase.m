function islinphaseflag = islinphase(Hq,sec)
%ISLINPHASE  True if filter object has linear phase sections.
%   ISLINPHASE(Hq) determines if the filter object Hq has linear phase
%   sections, and returns 1 if true and 0 if false.
%
%   ISLINPHASE(Hq,I) determines if the I-th section of the filter object
%   Hq is a linear phase section and returns 1 if true and 0 if false.
%
%   The determination is based on the reference coefficients.  A filter has
%   linear phase if it is FIR and its transfer function coefficients are are
%   symmetric or antisymmetric, or if it is IIR and it has poles on or outside
%   the unit circle and both numerator and denominator are symmetric or
%   antisymmetric.
%
%   Example:
%   This filter has linear phase.
%     num=[1 0 0 0 0 -1];
%     den=[1 -1];
%     Hq = qfilt('df2t',{num,den});
%     islinphase(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISFIR, QFILT/ISMAXPHASE,
%   QFILT/ISMINPHASE, QFILT/ISREAL, QFILT/ISSTABLE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:31:09 $ 

if nargin<2
  sec=[];
end

[Cq,Cr] = qfilt2tf(Hq,'sections');
if isnumeric(Cr{1})
  Cr = {Cr};
end
tol = eps^(2/3);
nn=sectionrange(Hq,sec);
islinphaseflag = 1;
isiirflag = ~isfir(Hq);
for k=nn
  % If the numerator is not symmetric, then not linear phase.
  if ~issymmetric(Cr{k}{1})
    islinphaseflag = 0;
    break
  end
  % If IIR and stable or denominator not symmetric, then not linear phase.
  if isiirflag & (max(abs(roots(Cr{k}{2})))<1-tol | ~issymmetric(Cr{k}{2}))
    islinphaseflag = 0;
    break
  end
end

function f = issymmetric(x)
%ISSYMETRIC Tests for symmetric or antisymmetric.
%   ISSYMETRIC(X) returns true (1) if vector X is symmetric or antisymmetric,
%   and false (0) if it is not.

% Remove zeros at the beggining of x (trailing zeros have been removed by
% qfilt2tf) 
x = x(min(find(x~=0)):end);
tol = eps^(2/3);
% Test to see if x is symmetric or antisymmetric.
if abs(x - conj(x(end:-1:1))) < tol | ...
      abs(x + conj(x(end:-1:1))) < tol
  f = 1;  % Symmetric or antisymmetric
else
  f=0;    % Not symmetric or antisymmetric
end
