function [num,den,Ts,Td] = tfdata(sys,flag)
%TFDATA  Quick access to transfer function data.
%
%   [NUM,DEN] = TFDATA(SYS) returns the numerator(s) and denominator(s) 
%   of the transfer function SYS.  For a transfer function with NY 
%   outputs and NU inputs, NUM and DEN are NY-by-NU cell arrays where
%   the (I,J) entry specifies the transfer function from input J to 
%   output I.  SYS is first converted to transfer function if necessary.
%
%   [NUM,DEN,TS] = TFDATA(SYS) also returns the sample time TS.  Other
%   properties of SYS can be accessed with GET or by direct structure-like 
%   referencing (e.g., SYS.Ts)
%
%   For a single SISO model SYS, the syntax
%       [NUM,DEN] = TFDATA(SYS,'v')
%   returns the numerator and denominator as row vectors rather than
%   cell arrays.
%
%   For arrays SYS of LTI models, NUM and DEN are ND cell arrays with
%   the same sizes as SYS, and such that NUM(:,:,k) and DEN(:,:,k) 
%   specify the transfer function of the k-th model SYS(:,:,k).
%
%   See also TF, GET, ZPKDATA, SSDATA, LTIMODELS, LTIPROPS.

%   Author(s): S. Almy
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.6 $  $Date: 2002/04/10 06:16:25 $

error('TFDATA is not supported for FRD models.')
