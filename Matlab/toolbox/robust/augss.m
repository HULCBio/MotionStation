function [a,b1,b2,c1,c2,d11,d12,d21,d22] = augss(varargin)
%AUGSS Augmentation of W1,W2,W3 (state-space form) into two-port plant.
%
%  [TSS_] = AUGSS(SS_G,SS_W1,SS_W2,SS_W3,W3POLY) or
%  [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGSS(AG,BG,CG,DG,AW1,BW1,CW1,DW1,...
%   AW2,BW2,CW2,DW2,AW3,BW3,CW3,DW3,W3POLY) computes the state-space model
%   of a plant augmented with weightings as follows:
%
%       W1 = ss_w1 = mksys(aw1,bw1,cw1,dw1); ---- on 'e', the error signal
%       W2 = ss_w2 = mksys(aw2,bw2,cw2,dw2); ---- on 'u', the control signal.
%       W3 = ss_w3 + w3poly ---- on 'y', the output signal
%    where
%       ss_w3 = mksys(aw3,bw3,cw3,dw3);
%       w3poly := polynomial-matrix in descending powers (optional input)
%               = [w3(n),w3(n-1),...,w3(0)]
%                 with size(w3(i))=size(dw3) for i=0,1,...,n.
%
%    Note: 1) Any of the above weightings can be removed by setting
%             ss_w1 or ss_w2, ss_w3 equal to mksys([],[],[],[]).
%          2) w3poly defaults to [], if omitted.
%
%    The augmented system TSS_=mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss').

% R. Y. Chiang & M. G. Safonov 1/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.12.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

nag1 = nargin;
[emsg,nag1,xsflag,Ts,ag,bg,cg,dg,aw1,bw1,cw1,dw1,aw2,bw2,cw2,dw2,aw3,bw3,cw3,dw3,w3poly]=mkargs5x('ss',varargin); error(emsg);
   % NAG1 may have been changed.

% Set default w3poly to empty
if nag1 == 4 | nag1 == 16, w3poly=[]; end
if norm(w3poly,inf)==0, w3poly=[]; end

%
% ----- Peel off the dimensions of G, W1, W2, W3:
%
xg = size(ag,1);
xw1 = size(aw1,1); xw2 = size(aw2,1); xw3 = size(aw3,1);
[mg,ng]  = size(dg);
[mw1,nw1] = size(dw1);
[mw2,nw2] = size(dw2);
[mw3,nw3] = size(dw3);
mw3 = max([mw3; size(w3poly,1)]);


% ---- If w1,w2,w3 isempty, fix dimensions
if mw1==0, aw1=[]; bw1=zeros(0,mg); cw1=[]; dw1=bw1; end
if xw1==0, cw1=zeros(mw1,0);bw1=zeros(0,mg);end

if mw2==0, aw2=[]; bw2=zeros(0,ng); cw2=[]; dw2=bw2; end
if xw2==0, cw2=zeros(mw2,0);bw2=zeros(0,ng);end

if size(dw3,1)==0, aw3=[]; bw3=zeros(0,mg); cw3=[]; dw3=bw3; end
if xw3==0, cw3=zeros(mw3,0);bw3=zeros(0,mg);end


% compute c-matrix cgb for w3poly(s)*G(s)
% cgb = p(0)*cg+p(1)*cg*ag+...+p(n)*cg*ag^n
%
% compute d-matrix dgb for w3poly(s)*G(s)
%
if isempty(w3poly),
   cgb = zeros(mw3,xg);
   dgb = zeros(mw3,ng);
else
   [mw3poly,nw3poly] = size(w3poly);
   npoly = nw3poly/mg;
   phi=cg;
   temp=cg;
   i = 1;
   while i < npoly
      temp=temp*ag;
      phi=[temp;phi];
      i = i+1;
   end
   cgb=w3poly*phi;
   phi=[phi*bg;dg];
   phi=phi(mg+1:nw3poly+mg,:);
   dgb=w3poly*phi;
   i = 1;
   while i < npoly             % check that w3poly(s)*G(s) is proper
     phi=[phi;zeros(mg,ng)];
     phi=phi(1+mg:nw3poly+mg,:);
     dofsi=w3poly*phi;
     if norm(dofsi,inf) ~= 0
         disp('WARNING:  W3poly*G is an improper transfer function');
         disp('Improper part being discarded');
     end
     i = i+1;
   end
end
%
% ----- A matrix:
%
a = [ag zeros(xg,xw1+xw2+xw3);...
   -bw1*cg aw1 zeros(xw1,xw2+xw3);...
    zeros(xw2,xg+xw1) aw2 zeros(xw2,xw3);...
    bw3*cg zeros(xw3,xw1+xw2) aw3];
%
% ----- B matrix:
%
b1 = [zeros(xg,mg);bw1;zeros(xw2+xw3,mg)];
b2 = [bg;-bw1*dg;bw2;bw3*dg];
%
% ----- C matrix:
%
c1 = [-dw1*cg cw1 zeros(mw1,xw2+xw3);zeros(mw2,xg+xw1) cw2 zeros(mw2,xw3);...
      cgb+dw3*cg zeros(mw3,xw1+xw2) cw3];
c2 = [-cg zeros(mg,xw1+xw2+xw3)];
%
% ----- D matrix:
%
d11 = [dw1;zeros(mw2+mw3,mg)];
d12 = [-dw1*dg;dw2;dgb+dw3*dg];
d21 = eye(mg);
d22 = -dg;
%
if xsflag,
   if ~isa(varargin{1},'lti'), 
      a = mksys(a,b1,b2,c1,c2,d11,d12,d21,d22,Ts,'tss');
   else
      a = mklti(a,b1,b2,c1,c2,d11,d12,d21,d22,Ts,'tss');
   end
end
%
% --------- End of AUGSS.M --- RYC/MGS 10/13/88%