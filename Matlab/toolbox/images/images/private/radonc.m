function varargout = radonc(varargin)
%RADONC Helper function for RADON.
%   [P,R] = RADONC(I,THETA) returns P, the Radon transform of I
%   evaluated for the angles in THETA, and R, a vector containing
%   radial coordinates corresponding to the columns of P.
%
%   See also RADON.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.12.4.2 $  $Date: 2003/08/01 18:11:25 $

%#mex

error('Images:radonc:missingMEXFile', 'Missing MEX-file: %s', mfilename);

