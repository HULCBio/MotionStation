function rsys = modred(sys,varargin)
%MODRED  Model state reduction.
%
%   RSYS = MODRED(SYS,ELIM) reduces the order of the state-space model 
%   SYS by eliminating the states specified in vector ELIM.  The full 
%   state vector X is partitioned as X = [X1;X2] where X2 is to be 
%   discarded, and the reduced state is set to Xr = X1+T*X2 where T is 
%   chosen to enforce matching DC gains (steady-state response) between 
%   SYS and RSYS.
%
%   ELIM can be a vector of indices or a logical vector commensurate
%   with X where TRUE values mark states to be discarded.  Use BALREAL to 
%   first isolate states with negligible contribution to the I/O response.
%   If SYS has been balanced with BALREAL and the vector G of Hankel
%   singular values has M small entries, you can use MODRED to eliminate 
%   the corresponding M states.
%   Example:
%      [sys,g] = balreal(sys)   % compute balanced realization
%      elim = (g<1e-8)          % small entries of g -> negligible states
%      rsys = modred(sys,elim)  % remove negligible states
%
%   RSYS = MODRED(SYS,ELIM,METHOD) also specifies the state elimination
%   method.  Available choices for METHOD include
%      'MatchDC' :  Enforce matching DC gains (default)
%      'Truncate':  Simply delete X2 and sets Xr = X1.
%   The 'Truncate' option tends to produces a better approximation in the
%   frequency domain, but the DC gains are not guaranteed to match.
%
%   See also BALREAL, SS.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2003/01/07 19:32:13 $
error('Only applicable to state-space models (see SS).')
