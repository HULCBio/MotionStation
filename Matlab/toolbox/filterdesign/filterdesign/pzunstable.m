function [z2, p2, k2] = pzunstable(z, p, k)
%PZUNSTABLE Flips all zeros inside the unit circle and all poles outside making
%   the digital filter strictly uinstable. This assures that a stable original
%   filter transforms to the stable target one after frequency transformation.
%
%   Inputs:
%     Z          - Zeros of the prototype lowpass filter
%     P          - Poles of the prototype lowpass filter
%     K          - Gain factor of the prototype lowpass filter
%   Outputs:
%     Z2         - Zeros of the target filter
%     P2         - Poles of the target filter
%     K2         - Gain factor of the target filter
%
%   Example:
%        Z1       = [1.5;0.25].*exp(i*pi*[0.2;0.3]);
%        P1       = 1./conj(Z1);
%        [Z2, P2] = pzunstable(Z1, P1);
%        fvtool(poly(Z1),poly(P1),poly(Z2),poly(P2));

%   Author(s): Dr. Artur Krukowski
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2001/11/16 13:28:18 $

% --------------------------------------------------------------------
% Check the input arguments

error(nargchk(2,3,nargin));

error(ftransfargchk(z, 'Zeros of the filter', 'vector'));
error(ftransfargchk(p, 'Poles of the filter', 'vector'));

if nargin == 2,
   k = 1;
else
   error(ftransfargchk(k, 'Gain of the filter',  'scalar'));
end;

% --------------------------------------------------------------------
% Perform the calculations

z2      = z;
idx     = find(abs(z2) > 1);
z2(idx) = 1./conj(z2(idx));

p2      = p;
idx     = find(abs(p2) < 1);
p2(idx) = 1./conj(p2(idx));

k2 = k;