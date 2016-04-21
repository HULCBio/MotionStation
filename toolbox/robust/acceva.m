%ACCEVA Script file for evaluation of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  ACCEVA.M is a script file that evaluates the performance of
%     the ACC Benchmark problem.
% ---------------------------------------------------------------
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

clc
disp(' ');
disp('          << Start to Evaluate the Robust Performance >>');
%
w = logspace(-3,3,100);
%w = [w [0.1:0.1:2]];
%[w,wind] = sort(w);
disp(' ')
disp('   -------------------------------------------------------------------')
disp('      Transform the cost & controller from "s~" to "s":')
disp(' ')
disp('      [acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,`Sft_jw`,cirpt);')
disp('      [af,bf,cf,df] = bilin(acp,bcp,ccp,dcp,-1,`Sft_jw`,cirpt);')
disp('   ----------------------------------------------------------------------')

if Lag == 1
   acll = acl - sgm*eye(acl); bcll = bcl; ccll = ccl; dcll = dcl;
   af = acp - sgm*eye(acp); bf = bcp; cf = ccp; df = dcp;
else
   [acll,bcll,ccll,dcll] = bilin(acl,bcl,ccl,dcl,-1,'Sft_jw',cirpt);
   [af,bf,cf,df] = bilin(acp,bcp,ccp,dcp,-1,'Sft_jw',cirpt);
end

if flag == 2
      disp(' ')
      disp('     - - Computing the cost function in s~ - - ')
      perttw = ssv(acl,bcl,ccl,dcl,w); perttw = 20*log10(perttw);
      disp(' ')
      disp('     - - Computing the cost function - -')
      pertt = ssv(acll,bcll,ccll,dcll,w); pertt = 20*log10(pertt);
end
clc
disp(' ')
disp('         Poles of F(s) - -')
format compact
lamf = eig(af)
disp(' ')
disp('         Zeros of F(s) - -')
tzf = tzero(af,bf,cf,df)
disp(' ')
disp('                     (strike a key to continue)')
pause
disp(' ')
disp('         Controller N(s)/D(s) - -')
[nuf,dnf] = ss2tf(af,bf,cf,df,1)
format loose
disp('')
disp('                     (strike a key to continue)')
pause
clc
disp(' ')
disp('      - - Computing the gain/phase of F(s) & L(s) - -');
[gf,pf] = bode(af,bf,cf,df,1,w); gf = 20*log10(gf);
% --------------------------------------------------------------
% Evaluate the disturbance response from u,w,v ---> z
%
disp(' ')
disp('      - - Evaluating the disturbance response from w to z - -')
% ---------------------------------------------------------------
% Including the control energy, disturbance at M1 or M2:
%
BB1a = [0 0 0 1/m2]';         % disturbance at M2
BB1a = [BB1a,[0 0 0 0]'];     % add V(s)
BB1b = [0 0 1/m1 0]';         % disturbance at M1
BB1b = [BB1b,[0 0 0 0]'];     % add V(s)
CC2a = [1 0 0 0;0 1 0 0;0 0 0 0];
DD21a = [0 0;0 0;0 0]; DD22a = [0;0;1];
DD21  = [0 1]; DD22 = 0;
t = 0:0.1:30;
dist_w = sin(0.5*t)';
disp(' ')
disp('      - - Inject the sensor noise: v(t) = 0.001*sin(100*t) - -');
nos_v  = 0.001*sin(100*t)';
[tmp1,tmp2]=size(t);
ipp = zeros(tmp1,tmp2)'; ipp(1) = 2/(t(2)-t(1));
U1 = [ipp nos_v];          % impulse + sensor noise for design # 1,2
U2 = [dist_w nos_v];       % sin disturbance + sensor noise for #3
% -----------------------------------------------------------------------
% Attach the Internal Model I(s) to the controller for
% disturbance rejection in Design # 3:
%
if flag == 3
   disp(' ')
   disp('      - - Attach the internal model to the controller - -')
   disp('  ')
   [af,bf,cf,df] = series(af,bf,cf,df,aint,bint,cint,dint);
end
[nuf,dnf] = ss2tf(af,bf,cf,df,1);
%
no_spr = size(spring)*[0;1];
for k0no = 1:no_spr
      k0 = spring(k0no)
      AA = [   0       0     1     0
               0       0     0     1
          -k0/m1   k0/m1     0     0
           k0/m2  -k0/m2     0     0];
      BB2 = -[0 0 1/m1 0]'; CC2 = [0 1 0 0]; dimp = [4 2 1 3 1];
      % dist. at M2
      [aw2zu,bw2zu,cw2zu,dw2zu] = lftf(...
      AA,BB1a,BB2,CC2a,CC2,DD21a,DD22a,DD21,DD22,af,bf,cf,df);
      lamw2zu = eig(aw2zu)
      % dist. at M1
      [aw1zu,bw1zu,cw1zu,dw1zu] = lftf(...
      AA,BB1b,BB2,CC2a,CC2,DD21a,DD22a,DD21,DD22,af,bf,cf,df);
      if flag ~= 3      % Impulse response for design # 1 & 2
         imp_w2 = lsim(aw2zu,bw2zu,cw2zu,dw2zu,U1,t);
         x1_ipw2(:,k0no) = imp_w2(:,1);
         x2_ipw2(:,k0no) = imp_w2(:,2);
         u_ipw2(:,k0no)  = imp_w2(:,3);
         imp_w1 = lsim(aw1zu,bw1zu,cw1zu,dw1zu,U1,t);
         x1_ipw1(:,k0no) = imp_w1(:,1);
         x2_ipw1(:,k0no) = imp_w1(:,2);
         u_ipw1(:,k0no)  = imp_w1(:,3);
      else              % Sinusodial disturbance for design # 3
         sim_w2 = lsim(aw2zu,bw2zu,cw2zu,dw2zu,U2,t);
         x1_w2(:,k0no) = sim_w2(:,1);
         x2_w2(:,k0no) = sim_w2(:,2);
         u_w2(:,k0no)  = sim_w2(:,3);
         sim_w1 = lsim(aw1zu,bw1zu,cw1zu,dw1zu,U2,t);
         x1_w1(:,k0no) = sim_w1(:,1);
         x2_w1(:,k0no) = sim_w1(:,2);
         u_w1(:,k0no)  = sim_w1(:,3);
      end
      svw2z(:,k0no) = bode(aw2zu,bw2zu,cw2zu(2,:),dw2zu(2,:),1,w);
      svw2z(:,k0no) = 20*log10(svw2z(:,k0no));
      disp(' ')
      ag = [0      0     1     0
            0      0     0     1
       -k0/m1   k0/m1    0     0
        k0/m2  -k0/m2    0     0];
      bg = [0 0 1/m1 0]';
      cg = [0 1 0 0]; dg = 0;
      [al,bl,cl,dl] = series(af,bf,cf,df,ag,bg,cg,dg);
      [at,bt,ct,dt] = feedbk(al,bl,cl,dl,2);
      yt(:,k0no) = step(at,bt,ct,dt,1,t);
      [nul(k0no,:),dnl(k0no,:)] = ss2tf(al,bl,cl,dl,1);
      [gl(:,k0no),pl(:,k0no)] = bode(al,bl,cl,dl,1,w);
      [gm(k0no,1),pm(k0no,1),wg(k0no,1),wp(k0no,1)] = ...
                     margin(gl(:,k0no),pl(:,k0no),w);
end     % of spring constant loop
gm = 20*log10(gm);
gl = 20*log10(gl);
%
gmin = min(gm); pmin = min(pm);
gmax = max(gm); pmax = max(pm);
%
% Peparing root locus plot for the nominal system:
%
%disp(' ')
%disp('       - - - Computing the root locus - - -');
%num2 = nul(2,:); den2 = dnl(2,:);
%[mnum,nnum] = size(num2);
%p = 1;                          % strip out leading zeros of 'NUL(2)'
%while abs(num2(1,p)) < 1.e-5
%    num_l = num2(1,p+1:nnum);
%    p = p+1;
%end
%pole = roots(den2);
%zero = roots(num_l);
%K = 0:0.1:30;
%RL = rlocus(num_l,den2,K);
%
% ----------- End of ACCEVA.M % RYC/MGS %