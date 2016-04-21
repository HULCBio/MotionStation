function s = qreportupdate(s,q)
%QREPORTUPDATE  Update quantization report field.
%   S = QREPORTUPDATE(S,Q) updates the quantization report field S with the
%   information contained in quantizer object Q.  See QREPORT for a
%   description of the fields. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:27:55 $
if ischar(s.min)
  s.max = get(q,'max');
  s.min = get(q,'min');
else
  s.max = max(s.max,get(q,'max'));
  s.min = min(s.min,get(q,'min'));
end
s.nover = s.nover + get(q,'nover');
s.nunder = s.nunder + get(q,'nunder');
s.noperations = s.noperations + get(q,'noperations');
