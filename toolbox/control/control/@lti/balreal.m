function [sysb,g] = balreal(sys)
%BALREAL  Gramian-based balancing of state-space realizations.
%
%   [SYSB,G] = BALREAL(SYS) computes a balanced state-space 
%   realization for the stable portion of the linear system SYS.
%   For stable systems, SYSB is an equivalent realization 
%   for which the controllability and observability Gramians
%   are equal and diagonal, their diagonal entries forming
%   the vector G of Hankel singular values.  Small entries in G  
%   indicate states that can be removed to simplify the model  
%   (use MODRED to reduce the model order).
% 
%   If SYS has unstable poles, its stable part is isolated, 
%   balanced, and added back to its unstable part to form SYSB.
%   The entries of G corresponding to unstable modes are set 
%   to Inf.  Use BALREAL(SYS,CONDMAX) to control the condition 
%   number of the stable/unstable decomposition (see STABSEP
%   for details).  
%
%   [SYSB,G,T,Ti] = BALREAL(SYS,...) also returns the balancing 
%   state transformation x_b = T*x used to transform SYS into SYSB,
%   as well as the inverse transformation x = Ti*x_b.
%
%   See also MODRED, GRAM, SSBAL, SS.

%	J.N. Little 3-6-86
%	Revised 12-30-88
%       Alan J. Laub 10-30-94
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.11.4.2 $  $Date: 2003/01/07 19:31:58 $
try
   sys = ss(sys);
catch
   if isproper(sys)
      error(sprintf('Not available for models of class %s.',class(sys)))
   else
      error('Not available for improper models.')
   end
end
[sysb,g] = balreal(sys);
