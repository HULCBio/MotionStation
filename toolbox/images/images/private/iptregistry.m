function varargout = iptregistry(varargin)
%IPTREGISTRY Store information in persistent memory.
%   IPTREGISTRY(A) stores A in persistent memory.
%   A = IPTREGISTRY returns the value currently stored.
%
%   Once called, IPTREGISTRY cannot be cleared by calling clear
%   mex.
%
%   See also IPTGETPREF, IPTSETPREF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.12.4.2 $  $Date: 2003/08/01 18:11:18 $

%#mex

error('Images:iptregistry:missingMEXFile', 'Missing MEX-file: %s', mfilename);
