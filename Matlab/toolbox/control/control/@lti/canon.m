function [sys,T] = canon(sys,varargin)
%CANON  Canonical state-space realizations.
%
%   CSYS = CANON(SYS,TYPE) computes a canonical state-space 
%   realization CSYS of the LTI model SYS.  The string TYPE
%   selects the type of canonical form:
%     'modal'    :  Modal canonical form where the system 
%                   eigenvalues appear on the diagonal. 
%                   The state matrix A must be diagonalizable.
%     'companion':  Companion canonical form where the characteristic
%                   polynomial appears in the right column.
%
%   [CSYS,T] = CANON(SYS,TYPE) also returns the state transformation 
%   matrix T relating the new state vector z to the old state vector
%   x by z = Tx.  This syntax is only meaningful when SYS is a 
%   state-space model.
%
%   The modal form is useful for determining the relative controll-
%   ability of the system modes.  Note: the companion form is ill-
%   conditioned and should be avoided if possible.
%
%   See also SS2SS, CTRB, CTRBF, SS.

%   Clay M. Thompson  7-3-90
%   Revised: P. Gahinet  6-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 05:51:46 $

error(nargchk(1,2,nargin));
sys = canon(ss(sys),varargin{:});
T = [];  % SYS is not a state-space model if lti/canon is called

