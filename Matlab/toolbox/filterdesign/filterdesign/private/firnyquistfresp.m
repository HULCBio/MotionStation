function [DH,DW] = firnyquistfresp(N, F, GF, W, hp,nneg,Decay)
%FIRNYQUISTFRESP Freq resp for design of Hs in FIRNYQUIST.
%
%   Inputs:
%       N - Filter Order
%       F - Frequency edges
%       GF - Frequency grid
%       W - Weights
%       hp - impulse response of partial filter
%       nneg - boolean flag indicating nonnegative zerophase or not
%       Decay - rate of decay (slope) for stopband

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:42 $

DH = determinemagresp(GF,F);

DW = determineweights(GF,F,W,hp,nneg,Decay);

%--------------- Determine desired mag response ---------------------------
function DH = determinemagresp(GF,F)

% There are only two bands
DH = zeros(size(GF)); % Preallocate

% Passband has only one point
DH(1) = 1;

%--------------- Determine weights ---------------------------
function DW = determineweights(GF,F,W,hp,nneg,Decay)

DW = zeros(size(GF)); % Preallocate

DW(1) = W(1);

% Compute the zerophase response of BF(z^L) on the freq. grid
Hz = lclzerophase(hp,1,GF*pi);

if nneg,
    DW(2:end) = sqrt(abs(Hz(2:end)));
else,
    DW(2:end) = abs(Hz(2:end));
end

if Decay ~= 0,
    % Determine deltay from Decay
    deltax = F(4)-F(3);
    deltay = Decay*deltax;

    % Weight must increase exponentially for linear dB slope
    DW(2:end) = DW(2:end).*10.^(linspace(0,deltay/20,length(GF)-1));
end
