function isminphaseflag = isminphase(Hq,sec)
%ISMINPHASE  True if filter object has minimum-phase sections.
%   ISMINPHASE(Hq) determines if the filter object Hq has minimum-phase
%   filter sections, and returns 1 if true and 0 if false.
%
%   ISMINPHASE(Hq,I) determines if the I-th section of the filter object
%   Hq is a minimum-phase section and returns 1 if true and 0 if false.
%
%   The determination is based on the reference coefficients.  A filter
%   is minimum phase if all the zeros of its transfer function are on or
%   inside the unit circle, or if the numerator is a scalar.
%
%   Example:
%     Hq = qfilt;
%     isminphase(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISFIR, QFILT/ISLINPHASE,
%   QFILT/ISMAXPHASE, QFILT/ISREAL, QFILT/ISSTABLE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 15:31:15 $ 

nsecs = numberofsections(Hq);
if nargin<2
  sec=[];
end
nn=sectionrange(Hq,sec);

[Zq,Pq,Kq,Zr]=zplane(Hq);
if ~iscell(Zr)
  Zr = {Zr};
end
% Concatenate all zeros into one column vector.
z = cat(1,Zr{nn});

% Minimum phase if if there are no zeros (i.e., scalar filter), or all zeros
% are inside the unit circle.
if isempty(z)
  isminphaseflag = 1;
elseif max(abs(z)) < 1+eps^(2/3)
  % elseif is necessary because abs([]) = [], and 1 | [] = []
  isminphaseflag = 1;
else
  isminphaseflag = 0;
end
