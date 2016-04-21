function w = notchwidth(NotchGroup,Ts)
%NOTCHWIDTH  Computes X-axis positions of notch width markers.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:52:34 $

% Notch (s^2+2*Zeta1*w0*s+w0^2)/(s^2+2*Zeta2*w0*s+w0^2) with Zeta1<=Zeta2

% Markers are located at DepthFraction of the total notch depth in dB
% (for an isolated notch)
DepthFraction = 0.25;

% Get zero and pole damping (1st column of Zeta -> zero, 2nd column -> Pole
[w0,Zeta] = damp([NotchGroup.Zero(1);NotchGroup.Pole(1)],Ts);   
Zeta2 = Zeta.^2;
w0 = w0(1);

% Frequency-axis positions W given by
%     x^2 + 4 Zeta1^2 (x+1)
%     --------------------- = (Zeta1/Zeta2)^(2*DepthFraction) = THETA
%     x^2 + 4 Zeta2^2 (x+1)
% with x = (W/W0)^2 - 1.      
% Rewrite as x^2 - 2 beta x - 2 beta = 0 where
%     BETA = 2 (Zeta1^2 - THETA * Zeta2^2) / (THETA-1).
theta = (Zeta2(1)/Zeta2(2))^DepthFraction;   % right-hand side
% RE: As Zeta1/Zeta2 -> 1, BETA -> 2 * (1/DepthFraction-1) * Zeta1^2
if abs(theta-1)<1e-2
    beta = 2 * (1/DepthFraction-1) * Zeta2(1);
else
    beta = 2 * (Zeta2(1) - theta * Zeta2(2)) / (theta-1);
end

% Solve for x
d = sqrt(beta^2 + 2*beta);
w = [w0 * sqrt(1+beta-d) ; w0 * sqrt(1+beta+d)];

% Limit x values to Nyquist frequency in discrete time
if Ts,
    nf = pi/Ts;
    w = min(w,nf);
    if w0>0.999*nf
        % Do not display right marker (can't be moved and prevents moving notch)
        w(2) = NaN;
    end
end
    
