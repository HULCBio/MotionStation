function [mu,ascaled,log_d,x] = muoptold(T,K);
%MUOPT Mixed real/complex structured singular value.
%
% [MU,ASCALED,LOGD,X] = MUOPTOLD(A) or MUOPTOLD(A,K) produces the scalar
% upper bound MU on the real or complex structured singular value (ssv)
% computed via the generalized Popov multiplier method of Safonov and Lee
% (1993 IFAC World Congress).
% Input:
%     A  -- a pxq complex matrix whose ssv is to be computed
% Optional input:
%     K  -- an nx1 or nx2 matrix whose rows are the uncertainty block sizes
%           for which the ssv is to be evaluated; K must satisfy
%           sum(K) == [q,p]. Real uncertainty is indicated by multiplying the
%           corresponding row of K by minus one, e.g., if the second
%           uncertainty is real then set K(2,:)=[-1,-1]. If only the first
%           column of K is given then the uncertainty blocks are taken
%           to be square, as if K(:,2)=K(:,1).
% Outputs:
%     MU      -- an upper bound on the structured singular value of A
%     ASCALED -- mu*(I-X)/(I+X) where X=D(mu*I-A)/(mu*I_A)*inv(D')
%     LOGD    -- an n-vector containing the log of the square-root of
%                the diagonal elements of the optimal generalized
%                Popov multiplier M=D'*D
%           x -- the normalized eigenvector associated with the smallest
%                eigenvalue of X+X'>0 .

% Authors: Penghin Lee and M. G. Safonov 7/92
%
% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

[n,c] = size(T);

[junk,T,logdpsv]=psv(T,abs(K));

if nargin<2,
   K=2*ones(n,1);
elseif max(abs(K))==1,
   K=.5*K(:,1)+1.5*ones(n,1);     % used by MIXEDALG.M
else
   error('The present version of muopt.m requires 1x1 uncertainties')
end

k_eps = 1e-02; k_low = 1e-14; k_upp = 1e+14;
kjw = 1; zp = 6; g = 1; knogood = 0; y = 1;

	while zp > 5;
         kpres(g,1) = kjw;
	 Tt =  ( (eye(n) - kjw*T ) )/(eye(n) + kjw*T);
% Tt is sectf(kjw*T,[-1,1],[0,inf])

% Initial guess. Any x with norm one
xr = rand(n,1); xqi = xr / norm(xr);

[mult,xqo] = mixedalg(Tt,xqi,K);

if kjw <= 1;
  if knogood == 0 & norm(mult) == 0;
    kjw = 0.5 * kjw;
  end
end;

  if kjw < 1;
        if norm(mult) > 0 ;
         k_yes(y,1) = kjw;
         knogood = kpres (g,1);

           if kpres(g,1) < kpres (g-1,1);
            knogood1 = kpres(g-1,1);
           end;

         kjw = 0.5 * ( knogood1 - kpres(g,1) ) + knogood;

         mult_yes = mult; Tt_yes = Tt;
         x_yes = xqo; y = y+1;
        end;

    if norm(mult) == 0 & knogood >0;
       kjw = 0.5 * ( kpres(g,1) - knogood ) + knogood;
    end;

  end; % if kjw< ..

  if kjw > 1;
        if norm(mult) ==  0;
         knogood = kpres(g,1);
            if kpres(g,1) > kpres(g-1,1);
             knogood1 = kpres(g-1,1);
            end;

         kjw = 0.5 * (kpres(g,1)-knogood1) + knogood1;
        end;

	  if norm(mult) > 0 & knogood > 0;
           k_yes(y,1) = kjw;
           kjw = kpres(g,1) + 0.5*(knogood - kpres(g,1));

           mult_yes = mult; Tt_yes = Tt;
           x_yes = xqo; y = y+1;
  	  end;

  end; % If kjw>..

if y > 2;
        if ( abs( k_yes(y-1,1)-k_yes(y-2,1) ) < k_eps * k_yes(y-2,1) )
         zp = zp-2;
        end;

	if (k_yes(y-1,1) > k_upp) | (k_yes(y-1,1) < k_low);
     	 break,
       	end;

end;

  if norm(mult) > 0 & knogood == 0;
   k_yes(y,1) = kjw; kjw = 2 * kjw;  mult_yes = mult;
   x_yes = xqo; Tt_yes = Tt; y = y+1;
  end

g = g+1;
        end; %while z

% Outputs
mu = 1 / k_yes(y-1,1) ;

 for my = 1: 2*n;
   if mult_yes(my,1) == 0;
     mult_yes(my,1) = 1e-100;
   end;
 end;

multip=mult_yes(n+1:2*n)+sqrt(-1)*mult_yes(1:n);
log_d = 0.5 * log(multip) + logdpsv;
d=diag(sqrt(multip));
T_sectf=d*Tt_yes/d';
ascaled=mu*(eye(n)-T_sectf)/(eye(n)+T_sectf);
x = x_yes;
%
% ------- End of MUOPTOLD.M % PHL/MGS
