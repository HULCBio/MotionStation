%function [bnds,dc,dri,g,gamc] = ...
% 	dang(M,alpha,bnds,g,gamc,kc,jc,jr,fr,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,sc,sr,
%		csc,csr,numits,contol);
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,dc,dri,g,gamc] = ...
 	dang(M,alpha,bnds,g,gamc,kc,jc,jr,fr,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,                        kcK,fcF,sc,sr,csc,csr,numits,contol);


%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<23,	disp('   dang.m called incorrectly'), return, end

LFc = logical(Fc); LFr = logical(Fr);
LIc = logical(Ic); LIr = logical(Ir);
LJc = logical(Jc); LJr = logical(Jr);
LKc = logical(Kc); LKr = logical(Kr);

Lfr = logical(fr);

% some stuff
ubold	= bnds(1);
beta	= alpha^2;
sizM	= size(M);
dmask	= fcF'*fcF;			gmask = kcK'*kcK;
dc	= eye(sizM(1));			dri = eye(sizM(2));

% change to LMI formulation

galf	= gamc(LKc).^2;
Dk	= diag(galf);
Dc      = dc;
Dc(LKc,LKc) = Dk;
Dr      = eye(sizM(2));
Dr(LFr,LFr) = Dc(LFc,LFc);
dmax    = max(max(Dc));
Dc      = Dc/dmax;                      Dcold = Dc;
Dr      = Dr/dmax;                      Drold = Dr;
ga      = (g*(alpha/dmax)).*galf;
Gk	= diag(ga);			Gkold = Gk;
GM	= ((j*ga)*ones(1,csr(4))).*M(LKc,:);
jG	= zeros(csr(4));
jG(LKr,:)= GM;
jG(:,LKr) = jG(:,LKr) + GM';	% because G is almost hermitian
NL	= M'*Dc*M + jG;

% start iteration
shifac = 0.0001;
ii = 0;				done = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while ii < numits & ~done,					ii = ii + 1;

junk = Dr\NL;
if any(any(junk==NaN))|any(any(abs(junk)==Inf))
	ub = 2*ubold; ii = ii + 1000;
else
	[u,val] = eig(junk);
	val     = real(diag(val));
	beta	= max(val);
	ub      = sqrt(max([beta eps]));
end	% if any(any
if beta<eps
		Dcold = Dc;	Drold = Dr;     Gkold = Gk;     ubold = ub;
		done = 1;
else	% if ub
	if ub < ubold/contol | ii==1
		Dcold = Dc;	Drold = Dr;	Gkold = Gk;	ubold = ub;
		if ub < ubold/1.01,	shifac = 0.00001;		end
	elseif ub < ubold
		Dcold = Dc;	Drold = Dr;	Gkold = Gk;	ubold = ub;
		done = 1;
	else
		done = 1;
	end	% if ub
end	% if ub

if ~done
ind      = find(val>=0.975*beta);
u        = u(:,ind);			val = val(ind);
mind     = find(beta==val);		mind = mind(1);
if length(ind)>5 | length(ind)==0,	done = 1;	end
end

if ~done
%	turn eta into a starting point
eta = ones(length(u(1,:)),1);     eta = eta/norm(eta);
Mu = M*u;	ue = u*eta;
Mue = Mu*eta;	Mueue = Mue(LKc)*ue(LKr)';
Gx = j*(Mueue - Mueue');				Gx = Gx.*gmask;
Dx = Mue(LFc)*Mue(LFc)' - ...
	(beta*ue(LFr))*ue(LFr)';	Dx = Dx.*dmask;
if sum(Jc)
	Dscalx = ...
	jc(:,LJc)*real(Mue(LJc).*conj(Mue(LJc))) ...
	- beta*(jr(:,LJr)*real( ue(LJr).*conj( ue(LJr))));
else
	Dscalx = 0;
end

if length(u(1,:))>1,	 %	iterate towards min(co(del))
for ij = 1:30

	%	find minimizing eta and point in del
	Dcx = zeros(csc(4));        Drx = zeros(csr(4));
	if length(jc)
		Dcx = diag(Dscalx'*jc);
		Drx = diag(Dscalx'*jr);
	end
	Dcx(LFc,LFc) = Dx;
	Drx(LFr,LFr) = Dx;
	uGMu = u(LKr,:)'*Gx*Mu(LKc,:);
	[eta,lam] = eig(Mu'*Dcx*Mu + j*(uGMu - uGMu') - beta*(u'*Drx*u));
		lam = real(diag(lam));
	ipr = min(lam);
	eta = eta(:,min(lam)==lam);	eta = eta(:,1);	eta = eta/norm(eta);
	ue = u*eta;
	Mue = Mu*eta;
	Mueue = Mue(LKc)*ue(LKr)';
	Gy = j*(Mueue - Mueue'); Gy = Gy.*gmask;
	Dy = Mue(LFc)*Mue(LFc)' - (beta*ue(LFr))*ue(LFr)';
        Dy = Dy.*dmask;
	if sum(Jc)
		Dscaly = ...
	  jc(:,LJc)*(Mue(LJc).*conj(Mue(LJc))) ...
	    - beta*(jr(:,LJr)*(ue(LJr).*conj(ue(LJr))));
	else
		Dscaly = 0;
	end

	%	find new point
	Dscalyx = Dscaly - Dscalx;
	Dyx	= Dy - Dx;
	Gyx	= Gy - Gx;
	ixyx  = sum(sum( Dx.*(Dyx.')))+sum(sum( Gx.*(Gyx')))+ Dscalx'*Dscalyx;
	iyxyx = sum(sum(Dyx.*(Dyx.')))+sum(sum(Gyx.*(Gyx')))+Dscalyx'*Dscalyx;
	if iyxyx<=1e-6,		break,		end
	t = min([max([-real(ixyx/iyxyx) 0]) 1]);
	Dscalx = Dscalx + t*Dscalyx;
	Dx = Dx + t*Dyx;
	Gx = Gx + t*Gyx;
end	% for ij
end	% if length(u

Dcx = zeros(csc(4));	Drx = zeros(csr(4));
if sum(Jc)
	Dcx = diag(Dscalx'*jc);
	Drx = diag(Dscalx'*jr);
end
Dcx(LFc,LFc) = Dx;
Drx(LFr,LFr) = Dx;

um      = u(:,mind);
Mum  = Mu(:,mind);
umGMum = um(LKr)'*Gx*Mum(LKc);
gamma	= max(um'*Dr*um,1e-40);
aldot = real(Mum'*Dcx*Mum+j*(umGMum-umGMum')-beta*(um'*Drx*um))/2/ubold/gamma;
delam	= -real(shifac*2*gamma*beta);
if aldot<(100*eps),	done = 1;	end
if ~done
	% eigenvalues for step size
	GxM     = j*Gx'*M(LKc,:);
	jGx     = zeros(csr(4));
	jGx(LKr,:)= GxM;
	jGx(:,LKr) = jGx(:,LKr) + GxM';
	Nt = M'*Dcx*M + jGx;
	junk = (NL-beta*Dr-delam*eye(csr(4)))\(Nt-beta*Drx);
	if any(any(junk==NaN))|any(any(abs(junk)==Inf))
        	t = NaN;
	else
		gam = real(eig(junk));
		gam = [flipud(sort(gam)); 0];
		gam(1) = max([gam(1) 1e-6]);
		gam(2) = max([gam(2) 1e-6]);
		t  = (1/gam(1) + 1/gam(2))/2;
		junk = Dr\Drx;
		if any(any(junk==NaN))|any(any(abs(junk)==Inf))
			tmax = 10*eps;
		else
			tmax = 1/max(real([eig(junk); 1e-9]));
			if tmax < 0,	tmax = 2*t;		end
		end	% if any(any(
	end	% if any(any(
	if (tmax < 100*eps & tmax >= 0) | t == NaN
		done = 1;
	else				% take a step
		t = min([t 0.95*tmax]);
		NL = NL - t*Nt;
		Gk = Gk - t*Gx;
		Dc = Dc - t*Dcx;
		Dr = Dr - t*Drx;
		dmax = max(max(Dr));
		NL = NL/dmax;
		Gk = Gk/dmax;
		Dc = Dc/dmax;
		Dr = Dr/dmax;
	end	% if tmax
end	% if ~done
end	% if ~done
end	% while
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v = zeros(sum(Fr)); 		d = v;
frF = logical(fr(:,LFr));	nF = length(fr(:,1));
kcK = logical(kc(:,LKc));	nK = length(kc(:,1));
if sum(Jc)
        nJ      = length(jc(:,1));
	jcJ     = jc(:,LJc);
	jrJ     = jr(:,LJr);
end	% if nJ

if ~done	% see if last iteration was good
  for ii = 1:nF
	frFi = frF(ii,:);
	Lfri = Lfr(ii,:);
	[v(frFi,frFi),d(frFi,frFi),wib] = svd(Dr(Lfri,Lfri));
  end	% for ii
  d	= sqrt(real(diag(d)));			d = max(1e-40,d);
  vdinv	= zeros(csr(4));
  vdinv(LFr,LFr) = v.*(ones(length(d),1)*(1../d'));
  if sum(Jc)
	vdinv(LJr,LJr)	=  ...
		diag(1../sqrt(diag(Dr(LJr,LJr))));
  end
  ub	= sqrt(max([max(real(eig(vdinv'*NL*vdinv))) eps]));
  if ub < ubold
        Drold = Dr;    Gkold = Gk;    ubold = ub;
  else	% if ub
	done = 1;
  end	% if ub
end	% if ~done

if done
	d = v;
	for ii = 1:nF
	  frFi = frF(ii,:);
	  Lfri = Lfr(ii,:);
	  [v(frFi,frFi),d(frFi,frFi),wib] = svd(Drold(Lfri,Lfri));
	end	% for ii
	d       = sqrt(real(diag(d)));		d = max(1e-40,d);
end     % if done

%	converting back from LMI form

vk = v(1:csc(2),1:csc(2));
dk = d(1:csc(2));
vi = v(csc(2)+1:csc(3),csc(2)+1:csc(3));
di = d(csc(2)+1:csc(3));

Gf	= Gkold;
dvGvd	= (vk'*Gf*vk).*((1../dk)*(1../dk'));
shaft	= norm(dvGvd,'fro');
dvGvd	= dvGvd + shaft*eye(length(dvGvd));
uinv	= eye(sum(Kc));		g 	= zeros(sum(Kc));
for ii = 1:nK
	kcKi = kcK(ii,:);
	[uinv(kcKi,kcKi),g(kcKi,kcKi),wib] = svd(dvGvd(kcKi,kcKi));
end     % for ii
u = inv(uinv);	g = (diag(g) - shaft)/ubold;
gamK	 = (1+g.*g).^(1/4);

 dc(LKc,LKc) = ( u*((dk*ones(1,sum(Kc))).*vk'  )).*(gamK*ones(1,csc(2)));
dri(LKr,LKr) = (vk*(((1../dk)*ones(1,sum(Kc))).*uinv ))./(ones(csc(2),1)*gamK');
if sum(Ic)>0
	 dc(LIc,LIc) = ((di*ones(1,sum(Ic))).*vi');
	dri(LIr,LIr) = (vi.*(ones(sum(Ic),1)*(1../di')));
end
if sum(Jc)
	djs = ...
	 max(jrJ'.*( sqrt(diag(Drold(LJr,LJr)))*ones(1,nJ) ));
	 dc(LJc,LJc) = diag(diag(jcJ'*diag(    djs)*jcJ));
	dri(LJr,LJr) = diag(diag(jrJ'*diag(1../djs)*jrJ));
end

bnds(1) 	= ubold;