function g = gram(a,b)
%GRAM  Controllability and observability gramians.
%
%   Wc = GRAM(SYS,'c') computes the controllability gramian of 
%   the state-space model SYS (see SS).  
%
%   Wo = GRAM(SYS,'o') computes its observability gramian.
%
%   In both cases, the state-space model SYS should be stable.
%   The gramians are computed by solving the Lyapunov equations:
%
%     *  A*Wc + Wc*A' + BB' = 0  and   A'*Wo + Wo*A + C'C = 0 
%        for continuous-time systems        
%               dx/dt = A x + B u  ,   y = C x + D u
%
%     *  A*Wc*A' - Wc + BB' = 0  and   A'*Wo*A - Wo + C'C = 0 
%        for discrete-time systems   
%           x[n+1] = A x[n] + B u[n] ,  y[n] = C x[n] + D u[n].
%
%   For arrays of LTI models SYS, Wc and Wo are double arrays 
%   such that 
%      Wc(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'c') .  
%      Wo(:,:,j1,...,jN) = GRAM(SYS(:,:,j1,...,jN),'o') .  
%
%   Rc = GRAM(SYS,'cf') and Ro = GRAM(SYS,'of') return the Cholesky
%   factors of gramians (Wc = Rc'*Rc and Wo = Ro'*Ro).
%
%   See also SS, BALREAL, CTRB, OBSV.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%GRAM   Controllability and observability gramians.
%   GRAM(A,B) returns the controllability gramian:
%
%       Gc = integral {exp(tA)BB'exp(tA')} dt
%
%   GRAM(A',C') returns the observability gramian:
%
%       Go = integral {exp(tA')C'Cexp(tA)} dt
%
%   See also DGRAM, CTRB and OBSV.

%   J.N. Little 3-6-86
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2002/09/01 23:06:57 $

%   Laub, A., "Computation of Balancing Transformations", Proc. JACC
%     Vol.1, paper FA8-E, 1980.

g = gram(ss(a,b,[],[]),'c');
