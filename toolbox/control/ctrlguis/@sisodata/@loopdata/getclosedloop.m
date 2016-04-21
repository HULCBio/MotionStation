function CL = getclosedloop(LoopData)
%GETCLOSEDLOOP  Gets the closed-loop model.
%
%   Returns the closed-loop model from [r,dy,du,n] to [y,u]
%   using 
%     * the current compensator C
%     * the normalized filter F (F.gain.mag = 1) or the current filter F
%  depending on the loop configuration.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%   Revised:   K. Subbarao
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.23 $  $Date: 2002/05/11 17:35:59 $

% Closed-loop model from [r,dy,du,n] to [y,u]

% Quick exit if closed-loop model is uptodate
CL = LoopData.ClosedLoop;
if isempty(LoopData.Plant.Model) | ~isequal(CL,[])
   return
end

% Recompute closed loop if not available
G = LoopData.Plant.Model;
H = LoopData.Sensor.Model;
C = zpk(LoopData.Compensator);

switch LoopData.Configuration  
case {1,2}
   % Filter is not inside closed-loop therefore keep gain seperate to allow lightweight updates
   F = zpk(LoopData.Filter,'norm');
case {3,4}
   % Filter is inside closed-loop therefore include gain in calculations, cant do lightweight updates
   F = zpk(LoopData.Filter);
end

% Take feedback sign into account
e = LoopData.FeedbackSign;

try
   % Try state-space approach first (will fail for improper or algebraic loop)
   switch LoopData.Configuration
      case 1
         % C and F are in forward path
         ICmat = [0 1 0 0 0 0 1 0;0 0 e 1 0 0 0 e;1 0 0 0 0 1 0 0;0 0 0 0 1 0 0 0];
      case 2
         % C is in feedback path, F is in the forward path
         ICmat = [0 e 0 1 0 0 1 0;0 0 1 0 0 0 0 1;1 0 0 0 0 1 0 0;0 0 0 0 1 0 0 0];
      case 3
         % C and F are in forward path
         ICmat = [0 1 0 1 0 0 1 0;0 0 e 0 1 0 0 e;1 0 0 0 0 1 0 0;0 0 0 0 1 0 0 0];
      case 4
         % C is in forward path and F is in feedback path
         ICmat = [0 1 0 1 0 0 1 0;0 0 e 0 1 0 0 e;1 0 0 0 0 1 0 0;0 0 1 0 0 0 0 1];
   end
   ICmat = [ICmat ; ICmat([3 1],:)];
   % Derive closed-loop model
   CL = LocalBuildClosedLoop(ss(LoopData.Plant),C,ss(LoopData.Sensor),F,ICmat);
   %       M = append(ss(LoopData.Plant),ss(C),ss(LoopData.Sensor),ss(F));
   %       CL = lft(M,ICmat);
catch
   % Try ZPK format if state-space failed
   try
      F = zpk(LoopData.Filter);   % Ensure that filter gain is included
      G = zpk(LoopData.Plant);  
      H = zpk(LoopData.Sensor);
      % Build closed-loop map
      switch LoopData.Configuration
         case 1
            % C is in forward path
            H = (-e)*H;
            [S,GS,CS,CGS,CHS] = LocalGetTransfers(G,C,H,F);
            CL = [F*CGS S GS e*CGS;F*CS -CHS S e*CS];
         case 2
            % C is in feedback path
            C = (-e)*C;
            [S,GS,CS,CGS,CHS] = LocalGetTransfers(G,C,H,F);
            CL = [F*GS S GS -CGS;F*S -CHS S -CS];
         case 3
            % C and F are in forward path
            H = (-e)*H;
            [S,GS,CS,CGS,CHS] = LocalGetTransfers(G,C,H,F);
            % e is not used here so pass it as unity
            [ytf,utf] = LocalGetTransferSums(GS,CGS,CS,S,F,1);
            CL = [ytf S GS e*CGS; utf -CHS S e*CS];
         case 4
            % C is in forward path F is in feedback path
            CL = LocalGetTransferSumsConfig4(G,C,H,F,e);
      end
   catch
      % Hard algebraic loop (e.g., sisotool(1,-1))
      CL = ss(repmat(NaN,[2 4]));
   end
end

% Update ClosedLoop property (compute it only once)
LoopData.ClosedLoop = CL;

%-------------------------Internal Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalGetTransfers %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate closed-loop transfer functions
function [S,GS,CS,CGS,CHS] = LocalGetTransfers(G,C,H,F)
S   = feedback(1,C*G*H);
CGS = feedback(G*C,H);
CHS = feedback(H*C,G);
GS  = feedback(G,C*H);
CS  = feedback(C,G*H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalGetTransferSums %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate closed-loop transfer functions that involve a sum term (case 3)
function [ytf,utf] = LocalGetTransferSums(GS,CGS,CS,S,F,e)

[GSnum,  GSden]  = tfdata(GS,'v');
[CGSnum, CGSden] = tfdata(CGS,'v');
[CSnum,  CSden]  = tfdata(CS,'v');
[Snum,   Sden]   = tfdata(S,'v');
[Fnum,   Fden]   = tfdata(F,'v');

ytfnum = LocalPolyPlus(conv(GSnum, Fnum),conv(CGSnum, e*Fden));
ytfden = conv(Sden, Fden);
ytf = tf(ytfnum,ytfden);

utfnum = LocalPolyPlus(conv(CSnum, Fden),conv(Snum, e*Fnum));
utf = tf(utfnum,ytfden);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalGetTransferSums %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate closed-loop transfer functions that involve a sum term (case 4)
function CL = LocalGetTransferSumsConfig4(G,C,H,F,e)

[zg,    pg,   kg] = zpkdata(G,'v');
[zc,    pc,   kc] = zpkdata(C,'v');
[zh,    ph,   kh] = zpkdata(H,'v');
[zf,    pf,   kf] = zpkdata(F,'v');
%
% The characteristic polynomial is given by
% D(s) = dc*df*dg*dh + (nc*df + e*nf*dc)*ng*nh
% where numerator polynomial of any system denoted by 'a' -> na 
% and the denominator polynomial is denoted by -> da
%
DEN_temp = conv(LocalPolyPlus(poly([zc;pf])*kc,e*poly([zf;pc])*kf),     poly([zg;zh])*kg*kh);
DEN   = LocalPolyPlus(poly([pc;pf;pg;ph]),DEN_temp);      % Characteristic Polynomial
[gain_DEN,roots_DEN] = LocalFactor(DEN);

NUM_ytf_fac  = LocalPolyPlus(poly([zf;pc])*kf,e*poly([zc;pf])*kc); % Computes the transfer ytf
[gain_ytf,roots_ytf] = LocalFactor(NUM_ytf_fac);
[gain_utf,roots_utf] = LocalFactor(LocalPolyPlus(poly([zc;pf])*kc,e*poly([zf;pc])*kf)); % Computes transfer utf

% Computing the numerator factors for the Loop Transfers
CLNUM = {[zg;zc;ph;pf] [pc;pg;ph;pf] [zg;pc;ph;pf] [zg;ph;roots_ytf];...
      [zc;pg;ph;pf] [roots_utf;zh;pg] [pc;pg;pf;ph] [zc;pg;pf;ph]};

% Computing the gains for the Loop Transfers
CLGAIN = [kg*kc 1 kg kg*gain_ytf;kc -kh*gain_utf 1 e*kc]/gain_DEN;

% Denominator of all the transfers
CLDEN = repmat({roots_DEN},size(CLNUM));

% Computing the Loop Transfers
CL = zpk(CLNUM,CLDEN,CLGAIN);


function p = LocalPolyPlus(p1,p2)                % Adds polynomials
p = [zeros(1,(length(p2)-length(p1))) p1]...
   + [zeros(1,(length(p1)-length(p2))) p2];


function [pgain,proots] = LocalFactor(p)      % Returns the roots and the gain - the leading coefficient of the polynomial
pgain = p(1);
proots = roots(p);
   

function CL = LocalBuildClosedLoop(G,C,H,F,ICmat)
% Fast implementation of 
%         M = append(G,C,H,F);
%         CL = lft(M,ICmat);
[nr,nc] = size(ICmat);
[ag,bg,cg,dg] = ssdata(G);
[ac,bc,cc,dc,Ts] = ssdata(C);
[ah,bh,ch,dh] = ssdata(H);
[af,bf,cf,df] = ssdata(F);

% Build append(G,C,H,F)
A = blkdiag(ag,ac,ah,af);
B = blkdiag(bg,bc,bh,bf);
C = blkdiag(cg,cc,ch,cf);
D = blkdiag(dg,dc,dh,df);
nx = size(A,1);

% LU factorize direct feedthrough matrix and test for singularity
% (algebraic loop)
M = [eye(4) -D;-ICmat(1:4,1:4) eye(4)];
[L,U,P] = lu(M);
if rcond(U)<eps,
   error('Algebraic loop.')
end
M = blkdiag(A,ICmat(5:nr,5:nc)) + ...
   [zeros(size(B,1),4) B;ICmat(5:nr,1:4) zeros(nr-4,4)] * (U\(L\...
   (P*blkdiag(C,ICmat(1:4,5:end)))));

% Build closed-loop model
CL = ss(M(1:nx,1:nx),M(1:nx,nx+1:end),M(nx+1:end,1:nx),M(nx+1:end,nx+1:end),Ts);


