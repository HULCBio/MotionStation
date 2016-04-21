function varargout = zpkdata(sys,varargin)
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

%       Author(s): P. Gahinet, 25-3-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.14 $   $Date: 2002/04/10 05:47:17 $

% Convert to zpk and call zpk/zpkdata
nout = max(1,nargout);
[varargout{1:nout}] = zpkdata(zpk(sys),varargin{:});

