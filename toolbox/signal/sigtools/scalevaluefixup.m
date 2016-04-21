function Hq = scalevaluefixup(Hq)
%SCALEVALUEFIXUP Fix up the scale values.
%   Hq = SCALEVALUEFIXUP(Hq) fixes up the scale values of Hq if there
%   are too many or too few for the number of sections.  If too
%   many, then the scale values are truncated.  If too few, then the
%   scale values are extended by ones.

%   Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:50:42 $ 

if ~isa(Hq,'qfilt')
  return
end
nsecs = numberofsections(Hq);
scale = scalevalues(Hq);
nscale = length(scale);
if nscale > 1 & nscale ~= nsecs+1
  % Only adjust if not the correct length
  if nscale > nsecs+1
    % Truncate if too many scale factors
    scale = scale(1:nsecs+1);
  else
    % Pad with 1's if too few
    scale = [scale(:).' ones(1,nsecs+1-nscale)];
  end
end
set(Hq,'scalevalues',scale);
