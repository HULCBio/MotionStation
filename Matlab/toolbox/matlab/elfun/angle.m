function p = angle(h)
%ANGLE  Phase angle.
%   ANGLE(H) returns the phase angles, in radians, of a matrix with
%   complex elements.  
%
%   See also ABS, UNWRAP.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:38:19 $

% Clever way:
% p = imag(log(h));

% Way we'll do it:
p = atan2(imag(h), real(h));

