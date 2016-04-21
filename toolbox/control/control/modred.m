function [ab,bb,cb,db] = modred(a,b,c,d,elim)
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

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%MODRED Model state reduction.
%   [Ab,Bb,Cb,Db] = MODRED(A,B,C,D,ELIM) reduces the order of a model
%   by eliminating the states specified in vector ELIM.  The state
%   vector is partioned into X1, to be kept, and X2, to be eliminated,
%
%       A = |A11  A12|      B = |B1|    C = |C1 C2|
%           |A21  A22|          |B2|
%       .
%       x = Ax + Bu,   y = Cx + Du
%
%   The derivative of X2 is set to zero, and the resulting equations
%   solved for X1.  The resulting system has LENGTH(ELIM) fewer states
%   and can be envisioned as having set the ELIM states to be 
%   infinitely fast.
%
%   See also BALREAL and DMODRED

%   J.N. Little 9-4-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2003/01/07 19:32:53 $

error(nargchk(5,5,nargin));
rsys = modred(ss(a,b,c,d),elim);
[ab,bb,cb,db] = ssdata(rsys);

% end modred

