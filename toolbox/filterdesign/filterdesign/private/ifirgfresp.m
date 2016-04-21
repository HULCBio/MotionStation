function [DH,DW] = ifirgfresp(N, F, GF, W, bf, L)
%IFIRGFRESP Freq resp for g design in advanced ifir.
%
%   Inputs:
%       N - Filter Order
%       F - Frequency edges
%       GF - Frequency grid
%       W - Weights
%       bf - periodic filter iteration
%       L - Interpolation factor

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:46 $

DH = determinemagresp(GF,F);

DW = determineweights(GF,F,bf,L,W);

%--------------- Determine desired mag response ---------------------------
function DH = determinemagresp(GF,F)

% There are only two bands
DH = zeros(size(GF)); % Preallocate

% Passband has only one point
DH(1) = 1;

%--------------- Determine weights ---------------------------
function DW = determineweights(GF,F,bf,L,W)

DW = zeros(size(GF)); % Preallocate

DW(1) = W(1);

% Compute the zerophase response of BF(z^L) on the freq. grid
Hz = lclzerophase(upsample(bf,L),1,GF*pi);

DW(2:end) = abs(Hz(2:end));

