% function [dc,dri,dMd,warflag] = ...
%	deebal(M,dcbold,dribold,Kc,Kr,Fc,Fr,kcK,nK,nJ,nF,csc,csr,csF,jc,jr,sc,sr,
%		opt,warflag);
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

 function [dc,dri,dMd,warflag] = ...
	deebal(M,dcbold,dribold,Kc,Kr,Fc,Fr,kcK,nK,nJ,...
		nF,csc,csr,csF,jc,jr,sc,sr,opt,warflag);

%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<19,	disp('   deebal.m called incorrectly')
	return
end

LFc = logical(Fc); LFr = logical(Fr);
LKc = logical(Kc); LKr = logical(Kr);
Ljc = logical(jc); Ljr = logical(jr);
LkcK = logical(kcK);

dMd = dcbold*M*dribold;
sizM = size(dMd);			frotd = eye(sum(Fc));
if length(dcbold)~=sizM(1) | length(dribold)~=sizM(2)
	dc = eye(sizM(1));		dri = eye(sizM(2));
else
	dc = dcbold;			dri = dribold;
end	% if length
dacc = ones(1,length(sc(:,1)));
costk = norm(dMd,'fro');		oldcostk = max([2*costk 10*eps]);
ik = 0;					illflag = 0;
fronum = 9 + 20*(any(opt=='c') & nK==0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while ik < 1 + fronum*(nF~=0) & (oldcostk-costk)/oldcostk > 0.002, ik = ik + 1;

if nF>0	% this is kinda dumb
	a = dMd(LFc,:)*dMd(LFc,:)' ...
		- dMd(:,LFr)'*dMd(:,LFr);
	a = a + norm(a,'fro')*eye(length(a));
	for i = 1:nF
       		ind = (csF(i)+1):csF(i+1);
       	 	[frotd(ind,ind),lam,wib]     = svd(a(ind,ind));
	end
	 dc(LFc,:) =         frotd'* dc(LFc,:);
	dri(:,LFr) =                dri(:,LFr)*frotd;
	if any(opt=='c')
		dMd =            dc*M*dri;
	else
		dMd(LFc,:) = frotd'*dMd(LFc,:);
		dMd(:,LFr) =        dMd(:,LFr)*frotd;
	end	% if any
end	% if nF
        %%%%%%%%%% above is rotation; below is balancing %%%%%%%%%%%%%%%%%%%%%%

checkandy = 0;
if checkandy
minfo(sc)
sc
minfo(dMd)
minfo(sr)
sr
end

a = sc*real(conj(dMd).*dMd)*sr';
for ii = 1:nJ,
  Ljci = Ljc(ii,:);
  for ij = 1:nJ
  a(ii+csc(3),ij+csr(3)) = norm(dMd(Ljci,Ljr(ij,:)))^2;
end,            end
a = a - diag(diag(a));			b = a;
d = ones(1,length(a));
costj = sum(sum(a));			oldcostj = max([2*costj 10*eps]);
ij = 0;
while (ij < (30+120*(nF==0))) & (oldcostj-costj)/oldcostj > 1e-4
        sa = max(sum(a),10*eps);
        sat = max(sum(a'),10*eps);
        d = d.*sqrt(sqrt(sa./sat));
	if nF>0
		d = min(max(d,1e-8),1e8);
	else	% if nF
		d = min(max(d,1e-80),1e80);
	end	% if nF
        a = b.*(d'*(1 ./d));
        ij = ij+1;
        oldcostj = max([costj 10*eps]);		costj = sum(sum(a));
end     % while ij
d = sqrt(d/d(1,1));
dacc = dacc.*d;
jdcs = 		       diag(sc'*diag(    d)*sc)*ones(1,sizM(1));
jdc  = 		       diag(sc'*diag(    d)*sc)*ones(1,sizM(2));
jdris= ones(sizM(2),1)*diag(sr'*diag(1../d)*sr)';
jdri = ones(sizM(1),1)*diag(sr'*diag(1../d)*sr)';
dMd = jdc.*dMd.*jdri;
dc  = jdcs.*dc;
dri =      dri.*jdris;
oldcostk = max([costk 10*eps]);			costk = norm(dMd,'fro');
end     % while ik
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dcond = max(dacc)/max(min(dacc),10*eps);
if dcond>1e12;	warflag(1) = 1;		end
if dcond>1e60,	warflag(2) = 1;		end
if sum(Kc)
	G = dMd(LKc,LKr).*(kcK'*kcK);
	G = (G - G')/2/j;
	G = G + norm(G,'fro')*eye(length(G));
	u = zeros(csc(2));
	for ii = 1:nK
	  LkcKi = LkcK(ii,:);
	  [u(LkcKi,LkcKi),junk,wib] = svd(G(LkcKi,LkcKi));
	end
	dc(LKc,LKc)  = u'*dc(LKc,LKc);
	dri(LKr,LKr) =    dri(LKr,LKr)*u;
end	% sum
dMd = dc*M*dri;