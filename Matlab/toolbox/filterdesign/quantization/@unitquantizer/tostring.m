function s = tostring(u)
%TOSTRING  UNITQUANTIZER object to string.
%   S = TOSTRING(Q) converts UNITQUANTIZER object Q to a string.
%
%   Example:
%     q = unitquantizer
%     s = tostring(q)

%   Thomas A. Bryan, 6 May 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:35:53 $

% Convert to a regular quantizer object first.
qj = get(u,'quantizer');
q = quantizer(qj);
s = ['unit',tostring(q)];
