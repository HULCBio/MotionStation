function ismaxphaseflag = ismaxphase(Hq,sec)
%ISMAXPHASE  True if filter object has maximum-phase sections.
%   ISMAXPHASE(Hq) determines if the filter object Hq has maximum-phase
%   filter sections, and returns 1 if true and 0 if false.
%
%   ISMAXPHASE(Hq,I) determines if the I-th section of the filter object
%   Hq is a maximum-phase section and returns 1 if true and 0 if false.
%
%   The determination is based on the reference coefficients.  A filter
%   is maximum phase if all the zeros of its transfer function are on or
%   outside the unit circle, or if the numerator is a scalar.
%
%   Example:
%     Hq = qfilt;
%     ismaxphase(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISFIR, QFILT/ISLINPHASE,
%   QFILT/ISMINPHASE, QFILT/ISREAL, QFILT/ISSTABLE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 15:31:12 $ 

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

% Maximum phase if if there are no zeros (i.e., scalar filter), or all zeros
% are outside the unit circle.
if isempty(z)
  ismaxphaseflag = 1;
elseif min(abs(z)) > 1-eps^(2/3)
  % elseif is necessary because abs([]) = [], and 1 | [] = []
  ismaxphaseflag = 1;
else
  ismaxphaseflag = 0;
end
