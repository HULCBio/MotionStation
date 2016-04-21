function varargout = imhistc(varargin)
%IMHISTC Image histogram.
%   COUNTS = IMHISTC(A, N, ISSCALED, TOP) computes the N-bin
%   histogram for A. ISSCALED is 1 if we shouldn't compute the
%   256-bin histogram using the values in A as is. TOP gives the
%   maximum bin location.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.13.4.2 $  $Date: 2003/08/01 18:11:13 $

%#mex

error('Images:imhistc:missingMEXFile', 'Missing MEX-file: %s', mfilename);

