function [af,bf,cf,df,svl] = ltry(varargin)
%LTRY Continuous LQG/LTR control synthesis (at plant output).
%
% [ss_f,svl] = ltry(ss_,Kf,Q,R,q,w,svk) or
% [af,bf,cf,df,svl] = ltry(A,B,C,D,Kf,Q,R,q,w,svk) produces
%    LQG/LTR at inputs of the plant, such that the LQG loop TF
%    will converge to KBF's loop TF as the state wt. goes to INF:
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> C(Is-A) Kf   (as q ---> INF)
%
%  Inputs: (A,B,C,D) -- system, or ss_ -- system matrix (built by "mksys")
%          Kf -- Kalman filter gain
%  (optional) svk(MIMO) -- SV of (C inv(Is-A)Kf)
%  (optional) svk(SISO) -- [re im;re(reverse order) -im(reverse order)]
%                          of the complete Nyquist plot
%          w -- frequency points
%          Q -- state weighting, R -- control weighting
%          q -- a row vector containing a set of recovery gains
%               (nq: length of q). At each iteration, Q <-- Q + q*C'*C;
%  Outputs: svl -- singular value plots of all the recovery points
%           svl(SISO) -- Nyquist loci svl = [re(1:nq) im(1:nq)]
%           final state-space controller (af,bf,cf,df)
%

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ---------------------------------------------------------------------
%
A=[];B=[];C=[];D=[];Kf=[];Q=[];R=[];q=[];w=[];svk=[];
nag1 = nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,Kf,Q,R,q,w,svk]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end
    % NAG1 may have changed after the expansion

nq = length(q);
[md,nd] = size(D);
%
if (md == 1) & (nd == 1)
  for i = 1:nq
    disp('  ')
    disp('  ')
    disp(['   LQG/LTR ---> recovery gain = ' num2str(q(1,i)) ' ..']);
    Q = Q + q(1,i)*C'*C;
    qrnc = diagmx(Q,R);
    Kc = lqrc(A,B,qrnc);
    af = A - B*Kc - Kf*C + Kf*D*Kc;
    bf = Kf; cf = Kc; df = zeros(size(Kc)*[1;0],size(Kf)*[0;1]);
    [al,bl,cl,dl] = series(af,bf,cf,df,A,B,C,D);
    [re,im] = nyquist(al,bl,cl,dl,1,w);
    lenw = length(w);
    re = [re;re(lenw:-1:1,:)]; im = [im;-im(lenw:-1:1,:)];
    if i == 1
          rel = re;          iml = im;
    else
          rel = [rel re];    iml = [iml im];
    end
    disp(' ')
    disp('(strike a key to see the plots .... hit <RET> again to continue)')
    pause
    if nag1 == 10
       plot(svk(:,1),svk(:,2),rel,iml)
    else
       plot(rel,iml)
    end
    title(['NYQUIST LOCI -- LQG/LTR (recov. gain ---> ' num2str(q(1,i)) ')'])
    xlabel('REAL')
    ylabel('IMAG')
    grid on
    pause
  end
  svl = [rel iml];
end
%
if (md > 1) | (nd > 1)
  for i = 1:nq
    disp('  ')
    disp('  ')
    disp(['   LQG/LTR ---> recovery gain = ' num2str(q(1,i)) ' ..']);
    Q = Q + q(1,i)*C'*C;
    qrnc = diagmx(Q,R);
    Kc = lqrc(A,B,qrnc);
    af = A - B*Kc - Kf*C + Kf*D*Kc;
    bf = Kf; cf = Kc; df = zeros(size(Kc)*[1;0],size(Kf)*[0;1]);
    [al,bl,cl,dl] = series(af,bf,cf,df,A,B,C,D);
    sv = sigma(al,bl,cl,dl,1,w); sv = 20*log10(sv);
    if i == 1
          svl = sv;
    else
          svl = [svl;sv];
    end
    disp(' ')
    disp('(strike a key to see the plots ..... hit <RET> again to continue)')
    pause
    if nag1 == 10
      semilogx(w,svk,w,svl)
    else
      semilogx(w,svl)
    end
    title(['SV BODE PLOT --- LQG/LTR (recov. gain --->' num2str(q(1,i)) ')'])
    xlabel('Frequency - Rad/Sec')
    ylabel('SV - db')
    grid on
    pause
  end
end
%
if xsflag
   af = mksys(af,bf,cf,df);
   bf = svl;
end
%
% ------- End of LTRY.M -- RYC %