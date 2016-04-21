function f = isstable(Hq,sec)
%ISSTABLE  True if filter is stable.
%   ISSTABLE(Hq) Returns 1 if the filter in QFILT object Hq has poles
%   inside the unit circle and 0 if not.
%
%   ISSTABLE(Hq,I) returns the stability of the I-th section of the
%   QFILT object Hq.
%
%   The stability is determined by the quantized coefficients.
%
%   Example:
%     Hq = qfilt;
%     isstable(Hq)
%
%   See also QFILT/ISALLPASS, QFILT/ISFIR, QFILT/ISLINPHASE,
%   QFILT/ISMAXPHASE, QFILT/ISMINPHASE, QFILT/ISREAL.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:31:06 $

error(nargchk(1,2,nargin));

% Get the transfer function form of the quantized filter so we can look at
% the roots of the denominator.
if nargin < 2
  try
    [b,a] = qfilt2tf(Hq);
  catch
    % An error in QFILT2TF indicates that the filter is not stable.  For
    % example, if Hq = qfilt('latticear',{[1 1]}) then QFILT2TF errors
    % because the Levinson recursion fails.
    f = logical(0);
    return
  end
else
  % Get the section first
  nsec = numberofsections(Hq);
  if nsec<sec | sec<=0
    s = 's';
    if nsec==1
      s = '';
    end
    error(['Filter has ',num2str(nsec),' section',s, ...
          ' and you have asked for the stability of section ',...
          num2str(sec),'.']);
  end
  try
    c = qfilt2tf(Hq,'sections');
  catch
    % An error in QFILT2TF indicates that the filter is not stable.  For
    % example, if Hq = qfilt('latticear',{[1 1]}) then QFILT2TF errors
    % because the Levinson recursion fails.
    f = logical(0);
    return
  end
  if isnumeric(c{1})
    c = {c};
  end
  b = c{sec}{1};
  a = c{sec}{2};
end

r = roots(a);
if isempty(r)
  % No poles.  The denominator is a scalar, so it's stable.
  f = logical(1);
else
  % Stable if all poles are inside the unit circle.
  f = max(abs(r))<1;
end



