function accdemo(flag,Lag,minpha)
%ACCDEMO Demo of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  ACCDEMO.M is a script file that demonstrates the designs of
%     1990 ACC benchmark problem.
% ---------------------------------------------------------------
%

% R. Y. Chiang & M. G. Safonov (rev 11/7/97)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.15.4.3 $
% All Rights Reserved.
clc
disp(' ')
disp('                      << Benchmark Problem >>')
disp('  ');
disp('                           |--> x1        |--> x2 = z (measurement)');
disp('         (control)    ------     k   ------');
disp('           u -------> | M1 | -/\/\/\-| M2 | ------> w (disturbance)');
disp('                      ------         ------');
disp('                       0  0           0  0');
disp('   ===============================================================');
disp('                     [ Design Specifications ]');
disp('    ------------------------------------------------------------');
disp('    | Design | Robustness   | Settling Time | Disturbance w(t) |')
disp('    ---------+--------------+---------------+-------------------');
disp('    |   1    | stable for   | Ts ~= 15 sec  |     impulse      |');
disp('    |        | .5 < k < 2   | for nominal   |                  |');
disp('    ---------+--------------+---------------+-------------------');
disp('    |   2    | maximize MSM | Ts ~= 15 sec  |     impulse      |');
disp('    |        | for nominal  | for nominal   |                  |');
disp('    ---------+--------------+---------------+-------------------');
disp('    |   3    | stable for   | Ts ~= 20 sec  | A sin(.5t + phi) |');
disp('    |        | .5 < k < 2   | for all cases | A, phi unknown   |');
disp('    ------------------------------------------------------------');
disp('   ')
disp(' ')
if nargin==0,
   flag = input('Design # 1 (default), 2 or 3 : ');
   if isempty(flag), flag=1; display('Using default (Design #1)'), end
end
% Input Lag,if needed
if flag == 1
   if nargin < 2,
      Lag=input('  Controller type (0 = min phase (default), 1 = non-min phase): ');
      if isempty(Lag),
         Lag = 0;
         display('Using default (min phase)')
      end      
   end
else
   Lag = 0;
end;
spring = [0.5 1  2];
%
clc
disp(' ')
disp('  -----------------------------------------------------------')
disp('    1. Set up the nominal system:');
disp(' ');
disp('       k = 1; m1 = 1; m2 = 1;');
disp('       ag = [0      0     1     0');
disp('             0      0     0     1');
disp('          -k/m1   k/m1    0     0');
disp('           k/m2  -k/m2    0     0];');
disp('       bg = [0 0 1/m1 0]`; cg = [0 1 0 0]; dg = 0;');
disp('  -----------------------------------------------------------')
k = 1; m1 = 1; m2 = 1;
ag = [0      0     1     0
      0      0     0     1
   -k/m1   k/m1    0     0
    k/m2  -k/m2    0     0];
bg = [0 0 1/m1 0]'; cg = [0 1 0 0]; dg = 0;
disp(' ');
disp('       Poles of Plant G(s) - -')
lamg = eig(ag)
disp(' ')
disp('                       (strike a key to continue)')
pause
%---------------------------------------
% Augment Plant for H-Inf Design:
%
clc
if Lag == 0
  if flag == 1 | flag == 3
      disp(' ')
      disp('  -----------------------------------------------------------');
      disp('    2. Set up the augmented plant for H-Inf design:');
      disp(' ')
      disp('       Change the spring to "5/4" with scaling factor "Gam"')
      disp('       (the additive uncertainty is now bounded by +- 1)')
      disp('       k0 = 5/4;')
      disp('       A = [   0       0     1     0')
      disp('               0       0     0     1')
      disp('          -k0/m1   k0/m1     0     0')
      disp('           k0/m2  -k0/m2     0     0];')
      disp('       B1 = [0 0 -1/m1  1/m2]`; B2 = -[0 0 1/m1 0]`;')
      disp('       C1 = Gam*[1 -1 0 0];   C2 = [0 1 0 0];')
      disp('       D11 = 0; D12 = 0; D21 = 0; D22 = 0;')
      disp('       where "Gam" is the robustness level of spring')
      disp('       (Gam = 0.75 for 0.5 <= k <= 2).')
      disp('  ----------------------------------------------------------');
      disp('  ')
      itcha = 4;
      if itcha == 4
         disp(' ')
         if flag == 1
            disp(' Try:  Gam = 0.75, Rho = 0.02...')
            Gam=0.75; Rho=0.02;
         end
         if flag == 2
            disp(' Try:  Gam = 0.75, Rho = 0...')
            Gam=0.75; Rho=0.0;
         end
         if flag == 3
            disp(' Try:  Gam = 0.36,  Rho = 0.009...')
            Gam=0.36; Rho=0.009;
         end
         disp(' ')
         if nargin==0,
            Gam=[];
            while isempty(Gam);
               Gam=input('Assign the fixed robustness level "Gam" of spring constant: ');
            end
            Rho=[];
            while isempty(Rho);
               Rho=input('Assign the fixed bound "Rho" on control signal: ');               
            end
         end
      end
      if itcha == 2
         Gam=[];
         while isempty(Gam),
            Gam=input('Assign the fixed robustness level "Gam" of spring constant: ');
         end     
         Rho = 1;
      end
      if itcha == 1
         Rho=[];
         while isempty(Rho),            
            Rho = input('Assign the fix bound "Rho" on control signal: ');
         end
         Gam = 1;
      end
      k0 = 1.25;
      A  = [   0       0     1     0
               0       0     0     1
          -k0/m1   k0/m1     0     0
           k0/m2  -k0/m2     0     0];
      B1 = [0 0 -1/m1  1/m2]'; B2 = -[0 0 1/m1 0]';
      C1 = Gam*[1 -1 0 0];   C2 = [0 1 0 0];
      D11 = 0; D12 = 0; D21 = 0; D22 = 0;
      if Rho ~= 0
          C1 = [C1;0 0 0 0]; D11 = [D11;0]; D12 = [D12;Rho];
      end
  end
end
if flag == 3
   clc
   disp(' ')
   disp('  ----------------------------------------------------------');
   disp('       Augment the plant with Internal Model:')
   disp('                         (s+1)^2')
   disp('           	  I(s) = -----------')
   disp('                        s^2 + 0.5^2')
   disp('  ----------------------------------------------------------');
   [aint,bint,cint,dint] = tf2ss([1 2 1],[1 0 0.25]);
  if Lag == 0
   [ap,bp,cp,dp] = append(aint,bint,cint,dint,A,B2,[C1;C2],[D12;D22]);
%   [aa,bb,cc,dd]=series(aint,bint,cint,dint,A,B2,[C1;C2],[D12;D22]);
   [r1,c1] = size(dint);   [r2,c2] = size([D12;D22]);
   M = [eye(c1);zeros(c2,c1)];   N = [zeros(r2,r1),eye(r2)];
   F = [zeros(c1,r1) zeros(c1,r2);eye(c2,r1) zeros(c2,r2)];
   [aa,bb,cc,dd] = interc(ap,bp,cp,dp,M,N,F);
   A = aa; B1 = [zeros(size(aint)*[1;0],1);B1]; B2 = bb;
   C1 = cc(1:2,:); C2 = cc(3,:); D12 = dd(1:2,1); D22 = dd(3,1);
  else
   [ag,bg,cg,dg] = series(aint,bint,cint,dint,ag,bg,cg,dg);
  end
   disp('  ')
   disp('  ')
   disp('                    (strike a key to continue)')
   pause
end
if flag == 2
   disp(' ')
   disp('  -----------------------------------------------------------');
   disp('    2. Set up the augmented plant for H-Inf design:');
   disp(' ');
   disp('       A = ag; ');
   disp('       B1 = [0 0 0;0 0 0;-1/m1 1 0; 1/m2 0 1];')
   disp('       B2 = -[0 0 1/m1 0]`; ')
   disp('       C1 = [1 -1 0 0;-k k 0 0;k -k 0 0]; C2 = [0 1 0 0];')
   disp('       D11 = [0 0 0;-1 0 0;1 0 0]; D12 = -[0 1 0]`;')
   disp('       D21 = [0 0 0]; D22 = 0;')
   disp('  ----------------------------------------------------------');
   A = ag; B1 = [0 0 0;0 0 0;-1/m1 1 0; 1/m2 0 1]; B2 = -[0 0 1/m1 0]';
   C1 = [1 -1 0 0;-k k 0 0;k -k 0 0]; C2 = [0 1 0 0];
   D11 = [0 0 0;-1 0 0;1 0 0]; D12 = -[0 1 0]';
   D21 = [0 0 0]; D22 = 0;
   itcha = 1:3;   % iterate on 3 robustness channels
   disp('  ')
   disp('  ')
   disp('                    (strike a key to continue)')
   pause
   clc
end
%
clc
disp(' ')
disp(' ------------------------------------------------------------------')
disp('    3. Transform the plant via a ''pole-shifting'' bilinear transform:')
disp(' ')
disp('       % Select the circle point for mapping ...')
disp('       % Pack the 2-port state-space ...')
disp('       B = [B1 B2]; C = [C1;C2]; D = [D11 D12;D21 D22];')
disp('       [aa,bb,cc,dd] = bilin(A,B,C,D,1,`Sft_jw`,cirpt);')
disp('       % Split the (aa,..) back to 2-port state-space (A,B1,..);')
disp('       % The H-Inf problem is ready to go ..')
disp(' ------------------------------------------------------------------')
disp(' ');
disp(' ');
if Lag == 0
   disp('                  (strike a key to see an example of bilinear mapping)')
   pause
   bilexp
   drawnow
else
   disp('                  (strike a key to continue..)')
   pause
end
disp(' ');
disp(' ');
disp('A class of H-Inf controllers can be found by adjusting the circle point "p1":')
disp(' ')
disp(' ')
if flag == 1
   if Lag == 1
      disp('            (p2 = INF; Try p1 = -0.3)');
      cirpt1=-0.3;
   else
      disp('            (Min. Phase Controller: p1 = -0.35)');
      cirpt1=-0.35;
   end
end
if flag == 2
  cirpt1=-0.25;
  if nargin<3,
%      disp('            (Min. Phase Controller: p1 = -0.465)');
%      disp('            (Non-Min. Phase Controller: p1 = -0.25)');
      disp('            (Try p1 = -0.25)');
%  else
%      if minpha > 0,
%         cirpt1=-0.465;
%      end
  end
end
if flag == 3
      disp('            (Min. Phase Controller: p1 = -0.3)');
      cirpt1=-0.3;
end
if nargin==0,
   cirpt1=[];
   while isempty(cirpt1),
      cirpt1 = input('   Input< the circle point "p1": ');
   end
end
cirpt = [-100 cirpt1];

%
if Lag == 1
   sgm = -cirpt1; itcha = 4;
   [tmp1,tmp2]=size(ag);
   ag = ag + sgm*eye(tmp1,tmp2);
   disp(' ')
   disp('Only impose W2 weighting on control signal - -')
   Rho=0.1;
   if nargin==0,
      Rho=[];
      while isempty(Rho),
         Rho = input('   Assign the fix bound on W2 weight (try 0.1): ');
      end      
   end
   w1 = []; w3 = []; w2 = [Rho;1];
   [A,B1,B2,C1,C2,D11,D12,D21,D22] = augtf(ag,bg,cg,dg,w1,w2,w3);
end
no_u1 = size(B1)*[0;1]; no_u2 = size(B2)*[0;1];
no_y1 = size(C1)*[1;0]; no_y2 = size(C2)*[1;0];
if Lag == 0
   B = [B1 B2]; C = [C1;C2]; D = [D11 D12;D21 D22];
   [aa,bb,cc,dd] = bilin(A,B,C,D,1,'Sft_jw',cirpt);
   A = aa; B1 = bb(:,1:no_u1); B2 = bb(:,no_u1+1:no_u1+no_u2);
   C1 = cc(1:no_y1,:); C2 = cc(no_y1+1:no_y1+no_y2,:);
   D11 = dd(1:no_y1,1:no_u1); D12 = dd(1:no_y1,no_u1+1:no_u1+no_u2);
   D21 = dd(no_y1+1:no_y1+no_y2,1:no_u1);
   D22 = dd(no_y1+1:no_y1+no_y2,no_u1+1:no_u1+no_u2);
end
%
clc
disp(' ')
disp('  -------------------------------------------------------------')
disp('    4. Starting H-Inf Design: ');
disp(' ')
disp('       TSS_ = rct2lti(mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,`tss`));')
if itcha == 4
      disp('       % Regular H-Inf ')
      disp('       [ss_cp,ss_cl,hinfo]=hinf(TSS_);')
else
      disp('       % H-Inf GAMMA-Iteration for maximum MSM')
      disp('       [gamopt,ss_cp,ss_cl]=hinfopt(TSS_);')
end
disp('       [acp,bcp,ccp,dcp] = ssdata(ss_cp);')
disp('       [acl,bcl,ccl,dcl] = ssdata(ss_cl);')
disp('  -------------------------------------------------------------')
disp('  ')
disp('  ')
disp('                    (strike a key to continue)')
pause
%format short e
format short
clc
if itcha == 4
      [acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo] = hinf(...
                              A,B1,B2,C1,C2,D11,D12,D21,D22);
      gamopt=1;
else
      [gamopt,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl] = hinfopt(...
                              A,B1,B2,C1,C2,D11,D12,D21,D22,itcha);
end
disp('  ')
disp('                    (strike a key to continue)')
pause
%
%acceva
%accplt
%ACCEVA Script file for evaluation of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  ACCEVA.M is a script file that evaluates the performance of
%     the ACC Benchmark problem.
% ---------------------------------------------------------------
%

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
   acll = acl - sgm*eye(size(acl)); bcll = bcl; ccll = ccl; dcll = dcl;
   af = acp - sgm*eye(size(acp)); bf = bcp; cf = ccp; df = dcp;
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
disp('         Poles of Controller F(s) - -')
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
% disp(' ')
% disp(' - - Evaluating the disturbance response from w to z - -')
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
%disp(' ')
%disp(' - - Evaluate effect of sensor noise: v(t) = 0.001*sin(100*t) - -');
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
   disp('            to prepare for evaluation of the design')
   disp(' ')
   [af,bf,cf,df] = series(af,bf,cf,df,aint,bint,cint,dint);
end
[nuf,dnf] = ss2tf(af,bf,cf,df,1);
%
disp('')
disp('                     (strike a key to continue)')
pause
clc
disp( 'Evaluate effects of spring constant variations on poles: ')


no_spr = size(spring)*[0;1];
for k0no = 1:no_spr
      k0 = spring(k0no);
      AA = [   0       0     1     0
               0       0     0     1
          -k0/m1   k0/m1     0     0
           k0/m2  -k0/m2     0     0];
      BB2 = -[0 0 1/m1 0]'; CC2 = [0 1 0 0]; dimp = [4 2 1 3 1];
      % dist. at M2
      [aw2zu,bw2zu,cw2zu,dw2zu] = lftf(...
      AA,BB1a,BB2,CC2a,CC2,DD21a,DD22a,DD21,DD22,af,bf,cf,df);
      lamw2zu = eig(aw2zu);
      disp(['Closed-loop Poles for spring constant k = '  num2str(k0) ':'])
      disp(lamw2zu)
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
      %     [gl(:,k0no),pl(:,k0no)] = bode(al,bl,cl,dl,1,w);
      [gla(:,k0no),pla(:,k0no)] = bode(af,bf,cf,df,1,w);
      [glb(:,k0no),plb(:,k0no)] = bode(ag,bg,cg,dg,1,w);
      gl=gla.*glb; 
      pl=pla+plb;
      [gm(k0no,1),pm(k0no,1),wg(k0no,1),wp(k0no,1)] = ...
                     margin(gl(:,k0no),pl(:,k0no),w);
end     % of spring constant loop
disp('')
disp('                     (strike a key to continue)')
pause
clc
disp(' ')

disp(' ')
disp(' - - Examine the results of the design --- ')
disp(' ')
disp('      (strike a key to see next plot) ')
disp(' ')


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


%ACCPLT Script file for plotting the results of 1990 ACC benchmark problem.
%
% ---------------------------------------------------------------
%  ACCPLT.M is a script file that produces the plots for the ACC
%     Benchmark problem.
% ---------------------------------------------------------------
%

clf
if flag == 2
      subplot(1,1,1)
      semilogx(w,[perttw;pertt]);
      title('Cost Function in "s~" and "s"');
      grid on;xlabel('Rad/Sec'); ylabel('PERRON SSV (db)');
      msmw = max(perttw);
      msmw = 1/(10^(msmw/20)/gamopt)*100;
      msm  = max(pertt);
      msm  = 1/(10^(msm/20)/gamopt)*100;
      text(0.2,-5,['ADDITIVE MSM IN s~-DOMAIN: +-',num2str(msmw),' %']);
      text(0.2,-10,['ADDITIVE MSM IN s-DOMAIN : +-',num2str(msm),' %']);
      %prtsc
      disp('')
      disp('                     (strike a key to see more plots)')
      drawnow
      pause
end

if flag ~= 3
   clf
   subplot(2,2,1)
   plot(t,x1_ipw1);grid on;
   title('x1');       xlabel('Sec')
   subplot(2,2,2)
   plot(t,x2_ipw1);grid on;
   title('x2 (z)');   xlabel('Sec');
   subplot(2,2,3)
   plot(t,u_ipw1); grid on;
   title('Control (u)'); xlabel('Sec');
   subplot(2,2,4)
   axis([0 1 0 1])
   text(0.1,0.9,'Impulse Response @ M1','sc');
   text(0.1,0.7,'Sensor Noise: 0.001*sin(100t)','sc')
   text(0.35,0.5,' k = 0.5','sc');
   text(0.35,0.4,' k = 1.0 (nominal)','sc');
   text(0.35,0.3,' k = 2.0','sc');
   hold on
   plot([0.15,0.30],[0.5;0.4;0.3]*[1 1])
   axis off
   %prtsc
   drawnow
   pause
   clf
   subplot(2,2,1)
   plot(t,x1_ipw2);grid on;
   title('x1');  xlabel('Sec');
   subplot(2,2,2)
   plot(t,x2_ipw2);grid on
   title('x2 (z)');   xlabel('Sec');
   subplot(2,2,3)
   plot(t,u_ipw2); grid on;
   title('Control (u)'); xlabel('Sec');
   subplot(2,2,4)
   axis([0 1 0 1])
   text(0.1,0.9,'Impulse Response @ M2','sc');
   text(0.1,0.7,'Sensor Noise: 0.001*sin(100t)','sc')
%  if flag == 1
   text(0.35,0.5,' k = 0.5','sc');
   text(0.35,0.4,' k = 1.0 (nominal)','sc');
   text(0.35,0.3,' k = 2.0','sc');
   hold on
   plot([0.15,0.30],[0.5;0.4;0.3]*[1 1])
   axis off
%  end
%prtsc
   drawnow
   pause
else
   clf
   subplot(2,2,1)
   plot(t,dist_w);grid on
   title('Disturbance: sin(0.5*t) @ M2');
   xlabel('Sec');
   subplot(2,2,2)
   plot(t,u_w2);grid on;
   title('Control Energy (u)');
   xlabel('Sec');
   subplot(2,2,3)
   plot(t,x1_w2);grid on;
   title('x1');
   xlabel('Sensor Noise: 0.001sin(100t)');
   subplot(2,2,4)
   plot(t,x2_w2);grid on;
   title('x2 (z)');
   xlabel('Sec (k = 0.5(- -), 1(-), 2(.))');
   %prtsc
   drawnow
   pause
   clf
   subplot(2,2,1)
   plot(t,dist_w);grid on
   title('Disturbance: sin(0.5*t) @ M1');
   xlabel('Sec');
   subplot(2,2,2)
   plot(t,u_w1);grid on;
   title('Control Energy (u)');   xlabel('Sec');
   subplot(2,2,3)
   plot(t,x1_w1);grid on;
   title('x1');
   xlabel('Sensor Noise: 0.001sin(100t)');
   subplot(2,2,4)
   plot(t,x2_w1);grid on;
   title('x2 (z)');
   xlabel('Sec (k = 0.5(- -), 1(-), 2(.))');
   %prtsc
   drawnow
   pause
end
%
clf
subplot(2,2,1)
semilogx(w,gf);title('Controller F(s)');
xlabel('Rad/Sec'); ylabel('Gain (db)')
subplot(2,2,3)
semilogx(w,pf);xlabel('Rad/Sec');ylabel('Phase (deg)')
subplot(2,2,2)
semilogx(w,gl); title('Loop TF G*F'); xlabel('Rad/Sec');
%if flag == 2
%   text(0.002,-100,['GM: ',num2str(gmin),' db']);
%else
   text(0.002,-50,[num2str(gmin),' < GM < ',num2str(gmax),' db']);
%end
subplot(2,2,4)
semilogx(w,pl);
xlabel('Rad/Sec (k = 0.5(- -), 1(-), 2(.))');ylabel('Phase (deg)')
%if flag == 2
%   text(0.002,min(pl)+100,['PM: ',num2str(pmin),' deg']);
%else
   text(0.002,max(min(pl))+100,[num2str(pmin),' < PM < ',num2str(pmax),' deg']);
%end
%prtsc
drawnow
% plopt the root locus
%accroot
%
clc
disp(' ');
disp(' ');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
disp('  *                                                               *')
disp('  *      Your design is accomplished!                             *');
disp('  *                                                               *');
disp('  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *')
%
% ----------- End of ACCPLT.M % RYC/MGS %
%
% ------------ End of ACCDEMO.M % RYC/MGS %
