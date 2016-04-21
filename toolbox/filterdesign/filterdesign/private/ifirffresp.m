function [DH,DW] = ifirffresp(N, F, GF, W, bg, L, DEV)
%IFIRFFRESP Freq resp for f design in advanced ifir.
%
%   Inputs:
%       N - Filter Order
%       F - Frequency edges
%       GF - Frequency grid
%       W - Weights
%       bg - interpolating filter iteration
%       L - Interpolation factor
%       DEV - vector of passband/stopband deviations (ripples)

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:45 $

[DH,Fpassindx,Hzpass] = determinemagresp(GF,F,bg,L);

DW = determineweights(GF,F,Fpassindx,bg,L,DEV,Hzpass);

%--------------- Determine desired mag response ---------------------------
function [DH,Fpassindx,Hzpass] = determinemagresp(GF,F,bg,L)

% There are only two bands
DH = zeros(size(GF)); % Preallocate

% Find streched passband 
Fpassindx = find(GF==F(2));
GFpass = GF(1:Fpassindx);

% Compute the zerophase response of BG(z^(1/L)) on the passband
Hzpass = lclzerophase(bg,1,GFpass*pi/L);

DH(1:Fpassindx) = 1./Hzpass;
%--------------- Determine weights ---------------------------
function DW = determineweights(GF,F,Fpassindx,bg,L,DEV,Hzpass)

DW = zeros(size(GF)); % Preallocate

% Find compressed stopband 
Fstopindx = find(GF==F(3));
GFstop = GF(Fstopindx:end);

% Compute the zerophase response of BF(z^L) on the freq. grid
Hzstop = lclzerophase(bg,1,GFstop*pi/L);

DW(1:Fpassindx) = abs(Hzpass);
DW(Fstopindx:end) = abs(DEV(1)*Hzstop/DEV(2));
