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

%       Author(s): P. Gahinet, 25-3-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.18 $   $Date: 2002/04/10 06:06:43 $


num = sys.num;
den = sys.den;

% Convenience syntax for SISO case
sizes = size(num);
if nargin>1 & prod(sizes)<=1,
   if any(sizes),
      num = num{1};
      den = den{1};
   else
      num = zeros(1,0);
      den = zeros(1,0);
   end
end

% Sample time
Ts = getst(sys.lti);

% Obsolete TD output
if nargout>3,
   warning('Obsolete syntax. Use the property InputDelay to access input delays.')
   Td = get(sys.lti,'InputDelay')';
end
