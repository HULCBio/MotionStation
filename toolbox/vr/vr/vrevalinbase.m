function vrevalinbase(fn)
%VREVALINBASE Function wrapper for EVALIN('base', ...).
%
%   This function wraps the call to EVALIN('base', ...) so that it has
%   correct MATLAB context information when called from VR callbacks.
%
%   Not to be called directly.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/12 23:21:19 $  $Author: batserve $

evalin('base', fn);
