function [z,p,k,Ts,Td] = zpkdata(sys,flag)
%ZPKDATA  Quick access to zero-pole-gain data.
%
%   [Z,P,K] = ZPKDATA(SYS) returns the zeros, poles, and gain for
%   each I/O channel of the LTI model SYS.  The cell arrays Z,P 
%   and the matrix K have as many rows as outputs and as many columns 
%   as inputs, and their (I,J) entries specify the zeros, poles, 
%   and gain of the transfer function from input J to output I.  
%   SYS is first converted to zero-pole-gain format if necessary.
%
%   [Z,P,K,TS] = ZPKDATA(SYS)  also returns the sample time TS. 
%   Other properties of SYS can be accessed with GET or by direct 
%   structure-like referencing (e.g., SYS.Ts)
%
%   For a single SISO model SYS, the syntax
%       [Z,P,K] = ZPKDATA(SYS,'v')
%   returns the zeros Z and poles P as column vectors rather than
%   cell arrays.       
%
%   For arrays SYS of LTI models, Z,P,K are arrays of the same size as
%   SYS such that the ZPK representation of the m-th model SYS(:,:,m)
%   is Z(:,:,m), P(:,:,m), K(:,:,m).
%
%   See also ZPK, GET, TFDATA, SSDATA, LTIMODELS, LTIPROPS.

%   Author(s): P. Gahinet, 4-15-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $   $Date: 2002/04/10 06:11:28 $

z = sys.z;
p = sys.p;
k = sys.k;

% Convenience syntax for SISO case
sizes = size(k);
if nargin>1 & prod(sizes)<=1,
   if any(sizes),
      z = z{1};  p = p{1};
   else
      z = zeros(0,1);  p = zeros(0,1);
   end
end

% Sample time
Ts = getst(sys.lti);

% Obsolete TD output
if nargout>4,
   warning('Obsolete syntax. Use the property InputDelay to access input delays.')
   Td = get(sys.lti,'InputDelay')';
end
