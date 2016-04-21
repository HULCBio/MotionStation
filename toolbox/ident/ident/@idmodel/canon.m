function [sys,T] = canon(sys,varargin)
%CANON  Canonical state-space realizations for IDMODEL objects.
%   Requires the Control Systems Toolbox.
%
%   CMOD = CANON(MOD,TYPE) computes a canonical state-space 
%   realization CMOD of the IDMODEL MOD.  The string TYPE
%   selects the type of canonical form:
%     'modal'    :  Modal canonical form where the system 
%                   eigenvalues appear on the diagonal. 
%                   The state matrix A must be diagonalizable.
%     'companion':  Companion canonical form where the characteristic
%                   polynomial appears in the right column.
%
%   [CMOD,T] = CANON(MOD,TYPE) also returns the state transformation 
%   matrix T relating the new state vector z to the old state vector
%   x by z = Tx.  This syntax is only meaningful when MOD is a 
%   state-space model.
%
%   The modal form is useful for determining the relative controll-
%   ability of the system modes.  Note: the companion form is ill-
%   conditioned and should be avoided if possible.
%
%   The disturbance model (K-matrix) is included in the
%   tranformation. To work only with the measured inputs, use
%   CANON(MOD('m'),TYPE).
%
%   Covariance information is lost in the transformation.
%
%   See also SS2SS.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:22:15 $

try
  sys1 = ss(sys);
catch
  error(lasterr)
end
if nargin == 1
 [sys1, T] = canon(sys1); 
 else
[sys1, T] = canon(sys1,varargin{:});
end
sys = idss(sys1);

