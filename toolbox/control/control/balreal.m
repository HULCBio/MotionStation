function [ab,bb,cb,g,T,Ti] = balreal(a,b,c)
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

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%BALREAL  Balanced state-space realization and model reduction.
%   [Ab,Bb,Cb] = BALREAL(A,B,C) returns a balanced state-space 
%   realization of the system (A,B,C).
%
%   [Ab,Bb,Cb,G,T] = BALREAL(A,B,C) also returns a vector G containing
%   the diagonal of the gramian of the balanced realization, and 
%   matrix T, the similarity transformation used to convert (A,B,C) 
%   to (Ab,Bb,Cb).  If the system (A,B,C) is normalized properly, 
%   small elements in gramian G indicate states that can be removed to
%   reduce the model to lower order.

%	J.N. Little 3-6-86
%	Revised 12-30-88
%       Alan J. Laub 10-30-94
%       P. Gahinet 6-27-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.12.4.1 $  $Date: 2002/11/11 22:21:09 $

%       Reference:
%       [1] Laub, A.J., M.T. Heath, C.C. Paige, and R.C. Ward,
%           ``Computation of System Balancing Transformations and Other
%           Applications of Simultaneous Diagonalization Algorithms,''
%           IEEE Trans. Automatic Control, AC-32(1987), 115--122.
%
%       The old balreal used an eigenvalue algorithm described in
%	 1) Moore, B., Principal Component Analysis in Linear Systems:
%	    Controllability, Observability, and Model Reduction, IEEE 
%	    Transactions on Automatic Control, 26-1, Feb. 1981.
%	 2) Laub, A., "Computation of Balancing Transformations", Proc. JACC
%	    Vol.1, paper FA8-E, 1980.

error(nargchk(3,3,nargin));
[sys,g,Ti,T] = balreal(ss(a,b,c,zeros(size(c,1),size(b,2))));
[ab,bb,cb] = ssdata(sys);
