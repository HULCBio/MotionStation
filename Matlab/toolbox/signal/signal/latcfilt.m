function [F,G,Zf] = latcfilt(K,V,X,ic,Zi)
%LATCFILT Lattice and lattice-ladder filter implementation.
%   [F,G] = LATCFILT(K,X) filters X with the FIR lattice coefficients
%   in vector K.  F is the forward lattice filter result, and G is
%   the backward lattice filter result. If K is such that ABS(K) <= 1,
%   F corresponds to the minimum-phase output of the filter and G
%   corresponds to the maximum-phase output.
%
%   If K and X are vectors, the result is a (signal) vector.
%   Matrix arguments are permitted under the following rules:
%   - If X is a matrix and K is a vector, each column of X is processed
%     through the lattice filter specified by K.
%   - If X is a vector and K is a matrix, each column of K is used to
%     filter X, and a signal matrix is returned.
%   - If X and K are both matrices with the same # of columns, then the
%     i-th column of K is used to filter the i-th column of X.  A
%     signal matrix is returned.
%
%   [F,G,Zf] = LATCFILT(K,X,'ic',Zi) gives access to the initial and final 
%   conditions, Zi and Zf, of the lattice states.  Zi must be a vector 
%   with length(K) entries.
%
%   [F,G] = LATCFILT(K,1,X) filters X with the all-pole or allpass
%   lattice coefficients in vector K.  F is the all-pole lattice filter
%   result and G is the allpass lattice filter result.  K must be a vector,
%   while X may be a signal matrix.
%
%   [F,G,Zf] = LATCFILT(K,1,X,'ic',Zi) gives access to the initial
%   and final conditions, Zi and Zf, of the lattice states.  Zi must be a 
%   vector with length(K) entries.
%
%   [F,G] = LATCFILT(K,V,X) filters X with the ARMA lattice-ladder
%   structure described by the lattice coefficients K and ladder
%   coefficients V.  F is the result of adding all outputs from the
%   ladder coefficients and G is the output of the allpass section of
%   the structure.  K and V must be vectors, while X may be a signal
%   matrix.
%
%   [F,G,Zf] = LATCFILT(K,V,X,'ic',Zi) gives access to the initial and 
%   final conditions, Zi and Zf, of the lattice states.  Zi must be a 
%   vector with length(K) entries.
%
%   See also FILTER, TF2LATC, LATC2TF.

%   Author(s): D. Orofino, R. Firtion
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 01:17:59 $

% The following comment, MATLAB compiler pragma, is necessary to avoid compiling 
% this M-file instead of linking against the MEX-file.  Don't remove.
%# mex

error('C MEX-file not found.');

% [EOF] latcfilt.m
