function isfirflag = isfir(Hq,sec)
%ISFIR  True if filter is FIR.
%   ISFIR(Hq) determines if the filter object Hq is an FIR filter and
%   returns 1 if true and 0 if false.
%
%   ISFIR(Hq,I) determines if the I-th section of the filter object Hq
%   is an FIR filter and returns 1 if true and 0 if false.
%
%   Example:
%     Hq = qfilt;
%     isfir(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISLINPHASE, QFILT/ISMAXPHASE,
%   QFILT/ISMINPHASE, QFILT/ISREAL, QFILT/ISSTABLE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

if nargin<2
  sec=[];
end

isfirflag = 1;
switch filterstructure(Hq)
  case {'fir','firt','symmetricfir','antisymmetricfir','latticema',...
          'latcmax','latticemaxphase'}
    % We know it is FIR based on the filter structure, so do nothing.
  otherwise
    % It is not an FIR filter structure, but it may still be FIR if the
    % denominator of the transfer function is a scalar.
    [Cq,Cr] = qfilt2tf(Hq,'sections');
    if isnumeric(Cr{1})
      Cr = {Cr};
    end
    nn=sectionrange(Hq,sec);
    for k=nn
      if ~isscalar(signalpolyutils('removezeros', Cr{k}{2})),
        isfirflag = 0;
        break
      end
    end
end

