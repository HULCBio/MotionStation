function [sys,xkeep] = sminreal(sys)
%SMINREAL  Compute a structurally minimal realization.
%
%   MSYS = SMINREAL(SYS) eliminates the states of the state-space
%   model SYS that are not connected to any input or output.  The
%   resulting state-space model MSYS is equivalent to SYS and is 
%   structurally minimal, i.e., minimal when all nonzero entries 
%   of SYS.A, SYS.B, SYS.C, and SYS.E are set to 1.
%
%   See also MINREAL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:48:06 $

error('Only meaningful for State-Space models.')
