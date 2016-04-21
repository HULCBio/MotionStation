function msg = overflowmsg(q,oldnover)
%OVERFLOWMSG  Quantizer overflow message.
%   MSG = OVERFLOWMSG(Q, OLDNOVER) generates a warning message if
%   Q.NOVERFLOWS - OLDNOVER > 0, where OLDNOVER is an integer.
%
%   This is useful for creating a warning message if new overflows occurred
%   during a calculation.
%
%  See also QUANTIZER, QUANTIZER/QUANTIZE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:34:33 $

msg = '';
newnover = q.quantizer.nover-oldnover;
if newnover > 0
  if newnover == 1
    overflows = 'overflow';
  else
    overflows = 'overflows';
  end
  msg = sprintf('%d %s.',newnover, overflows);
end

