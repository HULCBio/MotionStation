function isallpassflag = isallpass(Hq,sec)
%ISALLPASS  True if filter object has all-pass sections.
%   ISALLPASS(Hq) determines if the filter object Hq has all-pass filter
%   sections, and returns 1 if true and 0 if false.
%
%   ISALLPASS(Hq,I) determines if the I-th section of the filter object
%   Hq is an all-pass section and returns 1 if true and 0 if false.
%
%   The determination is based on the reference coefficients.  A filter
%   is all-pass if the numerator is the conjugate reverse of the
%   denominator.
%
%   Example:
%     Hq = qfilt;
%     isallpass(Hq)
%
%   See also QFILT/ISFIR, QFILT/ISLINPHASE, QFILT/ISMAXPHASE,
%   QFILT/ISMINPHASE, QFILT/ISREAL, QFILT/ISSTABLE. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:32:05 $ 

if nargin<2
  sec=[];
end

[Cq,Cr] = qfilt2tf(Hq,'sections');
if isnumeric(Cr{1})
  Cr = {Cr};
end
tol = eps^(2/3);
nn=sectionrange(Hq,sec);
isallpassflag = 1;
tol = eps^(2/3);
for k=nn
  b = Cr{k}{1};  % Numerator
  a = Cr{k}{2};  % Denominator
  isallpassflag = signalpolyutils('isallpass',b,a,tol);
  if isallpassflag==0, break; end
end
