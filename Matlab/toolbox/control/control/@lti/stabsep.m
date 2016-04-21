function [G1,G2] = stabsep(G,varargin)
%STABSEP  Stable/unstable decomposition of LTI models.
%
%   [GS,GNS] = STABSEP(G,CONDMAX) decomposes the LTI model G 
%   into its stable and unstable parts
%      G = GS + GNS
%   where GS contains all stable modes that can be separated 
%   from the unstable modes in a numerically stable way, and
%   GNS contains the remaining modes.  GNS is always strictly 
%   proper.
%   
%   Use the optional input CONDMAX to control the condition 
%   number of the decoupling state transformation.  Increasing  
%   CONDMAX helps separate closeby stable and unstable modes 
%   at the expense of accuracy (see BDSCHUR for more details). 
%   By default CONDMAX=1e8.
%
%   [G1,G2] = STABSEP(G,CONDMAX,MODE,TOL) performs more general 
%   stable/unstable decompositions such that G1 includes all  
%   separable eigenvalues lying in one the following regions:
%
%       Mode         Continuous Time          Discrete Time
%        1       Re(s)<-TOL*max(1,|Im(s)|)     |z| < 1-TOL
%        2       Re(s)> TOL*max(1,|Im(s)|)     |z| > 1+TOL
%
%   The default values are MODE=1 and TOL=0.
%
%   See also MODSEP.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2003/01/07 19:32:33 $
clG = class(G);
try
   G = ss(G);
catch
   if isproper(G)
      error(sprintf('Not available for models of class %s.',clG))
   else
      error('Not available for improper models.')
   end
end

try
   % Call ss/stabsep
   [G1,G2] = stabsep(G,varargin{:});
catch
   rethrow(lasterror)
end
G1 = feval(clG,G1);
G2 = feval(clG,G2);