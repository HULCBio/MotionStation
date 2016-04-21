function N = order(Hq,sec)
%ORDER  Filter order of a QFILT object.
%   ORDER(Hq) Returns the order of the QFILT object Hq.  If Hq is a
%   single-section filter, the order is given by the number of delays
%   needed for a minimum realization of the filter.
%
%   If Hq has multiple sections, the order is given by the the number of
%   delays needed for a minimum realization of the overall filter.
%
%   ORDER(Hq,I) returns the order of the I-th section of the QFILT
%   object Hq.  If I is a vector, then N is a vector of the orders of
%   the sections specified by I.
%
%   Example:
%     w = warning('on');
%     Hq = qfilt;
%     n = order(Hq)
%     warning(w);
%
%   See also QFILT.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/12 23:25:16 $

error(nargchk(1,2,nargin));
% The scalevalues don't figure into the calculation.  The modified
% qfilt is not returned from this function.
w = warning('off');
Hq = set(Hq,'scalevalues',[]);
warning(w);
if nargin < 2
  [b,a] = qfilt2tf(Hq);
  N = max(length(b),length(a)) - 1;
else
  % Get the section first
  nsec = numberofsections(Hq);
  sec = sec(:)';
  N = zeros(1,length(sec));
  nn = 1;
  for k=sec
    if nsec<k | k<=0
      s = 's';
      if nsec==1
        s = '';
      end
      error(['Filter has ',num2str(nsec),' section',s, ...
            ' and you have asked for the order of section ',...
            num2str(k),'.']);
    end
    c = qfilt2tf(Hq,'sections');
    if isnumeric(c{1})
      c = {c};
    end
    b = c{k}{1};
    a = c{k}{2};
    N(nn) = max(length(b),length(a)) - 1;
    nn = nn+1;
  end
end




