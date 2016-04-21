%SQRMTX Script file of LINF minimal realization.
%
% SQRMTX produces a minimal realization of the TF : (T12)'(T11)(T21)',
%      (T12p)'(T11)(T21)', (T12)'(T11)(T21p)', and (T12p)'(T11)(T21p)'
%      for H-inf phase (III) computation.  This will replace the
%      lengthy model reduction work.

% R. Y. Chiang & M. G. Safonov 1/8/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

%      (Ver. 1.1, rewritten on Jan. 8, 1987 for considering the four
%       different cases).
%
asqm  = at11;
%
% -------------------------------------------- Square Case :
%
bsqm1 = bt11;
bsqm2  = [bt12;zeros(rat0,cbt1)];
%
csqm1 = ct11;
csqm2  = [zeros(rct2,rat1) ct21];
%
dsqm11 = dt11;
dsqm12 = dt12;
dsqm21 = dt21;
dsqm22 = zeros(rct2,cbt1);
%
% ---------------------------------------- Nonsquare Cases :
%
if yulacase == 2
   [rbt1p,cbt1p] = size(bt1p);
   bsqm2 = [bt12 bt1p;zeros(rat0,(cbt1+cbt1p))];
   dsqm12 = [dt12 dt1p];
   dsqm22 = zeros(rct2,(cbt1+cbt1p));
end
%
if yulacase == 3
   [rct2p,cct2p] = size(ct2p);
   csqm2 = [csqm2;zeros(rct2p,rat1) ct2p];
   dsqm21 = [dt21;dt2p];
   dsqm22 = zeros((rct2+rct2p),cbt1);
end
%
if yulacase == 4
   [rbt1p,cbt1p] = size(bt1p);
   [rct2p,cct2p] = size(ct2p);
   bsqm2 = [bt12 bt1p;zeros(rat0,(cbt1+cbt1p))];
   csqm2 = [csqm2;zeros(rct2p,rat1) ct2p];
   dsqm12 = [dt12 dt1p];
   dsqm21 = [dt21;dt2p];
   dsqm22 = zeros((rct2+rct2p),(cbt1+cbt1p));
end
%
bsqm = [bsqm1 bsqm2];
csqm = [csqm1;csqm2];
%
[rdsq12,cdsq12] = size(dsqm12);
dsqm12 = dsqm12 + eye(rdsq12);
[rdsq21,cdsq21] = size(dsqm21);
dsqm21 = dsqm21 + eye(rdsq21);
dsqm = [dsqm11 dsqm12;dsqm21 dsqm22];
%
% ------------------------------------------- Block Feedback :
%
fbk = [zeros(rdsq21,rdsq12) eye(rdsq21);...
        eye(rdsq12) zeros(rdsq12,rdsq21)];
minp = [eye(rdsq21);zeros(rdsq12,rdsq21)];
noutp = [eye(rdsq12) zeros(rdsq12,rdsq21)];
[Acl,Bcl,Ccl,Dcl] = interc(asqm,bsqm,csqm,dsqm,minp,noutp,fbk);
%
% --------------------------------------- State Space of Htt :
%
ahtt = Acl;
bhtt = Bcl(:,1:cbt2);
chtt = Ccl(1:rct2,:);
dhtt = dt12'*dt11*dt21';
%
[rDcl,cDcl] = size(Dcl);
[rbt12p,cbt12p] = size(bt1p);
[rct21p,cct21p] = size(ct2p);
%
% ----------------------------------- State Space of G1 & G2 :
%                                     (depends on each case)
%
if yulacase == 2
   ag2 = Acl;
   bg2 = Bcl;
   cg2 = Ccl((rDcl-cbt12p+1):rDcl,:);
   dg2 = dt1p'*dt11*dt21';
end
%
if yulacase == 3
   ag1 = Acl;
   bg1 = Bcl(:,(cDcl-rct21p+1):cDcl);
   cg1 = Ccl;
   dg1 = dt12'*dt11*dt2p';
end
%
if yulacase == 4
   ag2 = Acl;
   bg2 = Bcl(:,1:cbt1);
   cg2 = Ccl((rDcl-cbt12p+1):rDcl,:);
   dg2 = dt1p'*dt11*dt21';
   ag1 = Acl;
   bg1 = Bcl(:,(cDcl-rct21p+1):cDcl);
   cg1 = Ccl(1:rct2,:);
   dg1 = dt12'*dt11*dt2p';
end
%