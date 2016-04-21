%function [bnds,dc,dri] = ...
%	dand(M,bnds,jc,jr,fr,Ic,Ir,Jc,Jr,Fc,Fr,fcF,sc,sr,csc,csr,numits,contol);
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,dc,dri] = ...
 	dand(M,bnds,jc,jr,fr,Ic,Ir,Jc,Jr,Fc,Fr,fcF,sc,sr,csc,csr,numits,contol);

%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<16,	disp('   dand.m called incorrectly'), return, end

Lfr = logical(fr);
LIc = logical(Ic); LIr = logical(Ir);
LJc = logical(Jc); LJr = logical(Jr);
LFc = logical(Fc); LFr = logical(Fr);

d = []; v = [];
% some stuff
ubold	= bnds(1);
beta	= ubold^2;
sizM	= size(M);
dc	= eye(sizM(1));			dri = eye(sizM(2));
if sum(Ic),	dmask	= fcF'*fcF;	end

% change to LMI formulation

Dc      = dc;
Dr      = dri;
Dcold	= Dc;
Drold	= Dr;
NL	= M'*Dc*M;

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
		Dcold = Dc;	Drold = Dr;     ubold = ub;
		done = 1;
else	% if ub
	if ub < ubold/contol | ii==1
		Dcold = Dc;	Drold = Dr;	ubold = ub;
		if ub < ubold/1.01,	shifac = 0.00001;		end
	elseif ub < ubold
		Dcold = Dc;	Drold = Dr;	ubold = ub;
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
Mu = M*u;	ue = u*eta;		Mue = Mu*eta;
if sum(Ic)
	Dx = Mue(LFc)*Mue(LFc)' - (beta*ue(LFr))*ue(LFr)';		Dx = Dx.*dmask;
else
	Dx = 0;
end
if sum(Jc)
	Dscalx = 		jc(:,LJc)*real(Mue(LJc).*conj(Mue(LJc))) ...
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
	if sum(Ic)
		Dcx(LFc,LFc) = Dx;        Drx(LFr,LFr) = Dx;
	end
	[eta,lam] = eig(Mu'*Dcx*Mu - beta*(u'*Drx*u));
		lam = real(diag(lam));
	ipr = min(lam);
	eta = eta(:,min(lam)==lam);	eta = eta(:,1);	eta = eta/norm(eta);
	ue = u*eta;             Mue = Mu*eta;
	if sum(Ic)
		Dy = Mue(LFc)*Mue(LFc)'-(beta*ue(LFr))*ue(LFr)'; Dy = Dy.*dmask;
	else
		Dy = 0;
	end
	if sum(Jc)
		Dscaly =	        jc(:,LJc)*(Mue(LJc).*conj(Mue(LJc))) ...
				- beta*(jr(:,LJr)*(ue(LJr).*conj(ue(LJr))));
	else
		Dscaly = 0;
	end

	%	find new point
	Dscalyx = Dscaly - Dscalx;
	Dyx	= Dy - Dx;
	ixyx  = sum(sum( Dx.*(Dyx.'))) +  Dscalx'*Dscalyx;
	iyxyx = sum(sum(Dyx.*(Dyx.'))) + Dscalyx'*Dscalyx;
	if iyxyx<=1e-6,		break,		end
	t = min([max([-real(ixyx/iyxyx) 0]) 1]);
	Dscalx = Dscalx + t*Dscalyx;
	Dx = Dx + t*Dyx;
end	% for ij
end	% if length(u

Dcx = zeros(csc(4));	Drx = zeros(csr(4));
if sum(Jc)
	Dcx = diag(Dscalx'*jc);
	Drx = diag(Dscalx'*jr);
end
if sum(Ic)
	Dcx(LFc,LFc) = Dx; Drx(LFr,LFr) = Dx;
end

um      = u(:,mind);    Mum  = Mu(:,mind);
gamma	= max(um'*Dr*um,1e-40);
aldot = real(Mum'*Dcx*Mum - beta*(um'*Drx*um))/2/ubold/gamma;
delam	= -real(shifac*2*gamma*beta);
if aldot<(100*eps),	done = 1;	end
if ~done
	% eigenvalues for step size
	Nt = M'*Dcx*M;
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
		Dc = Dc - t*Dcx;
		Dr = Dr - t*Drx;
		dmax = max(max(Dr));
		NL = NL/dmax;
		Dc = Dc/dmax;
		Dr = Dr/dmax;
	end	% if tmax
end	% if ~done
end	% if ~done
end	% while
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if sum(Ic)
	v = zeros(sum(Fr));		d = v;
	frF = logical(fr(:,LFr));	nF = length(fr(:,1));
end
if sum(Jc)
        nJ      = length(jc(:,1));
	jcJ     = jc(:,logical(Jc));	 jrJ     = jr(:,logical(Jr));
end	% if nJ

if ~done	% see if last iteration was good
  if sum(Ic)
    for ii = 1:nF
	frFi = frF(ii,:);
        Lfri = Lfr(ii,:);
	[v(frFi,frFi),d(frFi,frFi),wib] = ...
			svd(Dr(Lfri,Lfri));
    end	% for ii
  end	% if sum(Ic)
  d	= sqrt(real(diag(d)));			d = max(1e-40,d);
  vdinv	= zeros(csr(4));
  if sum(Ic)
   	vdinv(LFr,LFr)	= v.*(ones(length(d),1)*(1../d'));
  end	% if sum(Ic)
  if sum(Jc)
	vdinv(LJr,LJr)	= diag(1../sqrt(diag(Dr(LJr,LJr))));
  end
  ub	= sqrt(max([max(real(eig(vdinv'*NL*vdinv))) eps]));
  if ub < ubold
        Drold = Dr;    ubold = ub;
  else	% if ub
	done = 1;
  end	% if ub
end	% if ~done

if done
	d = v;
	if sum(Ic)
	  for ii = 1:nF
	    frFi = frF(ii,:);
            Lfri = Lfr(ii,:);
  	    [v(frFi,frFi),d(frFi,frFi),wib] = ...
			svd(Drold(Lfri,Lfri));
	  end	% for ii
	end	% if sum(Ic)
	d       = sqrt(real(diag(d)));		d = max(1e-40,d);
end     % if done

%	converting back from LMI form

vi = v(csc(2)+1:csc(3),csc(2)+1:csc(3));
di = d(csc(2)+1:csc(3));

if sum(Ic)
	 dc(LIc,LIc) =  (    (di*ones(1,sum(Ic))          ).*vi');
	dri(LIr,LIr) =  (vi.*(   ones(sum(Ic),1)*(1../di'))     );
end
if sum(Jc)
	djs	   = max(jrJ'.*( sqrt(diag(Drold(LJr,LJr)))*ones(1,nJ) ));
	idx        = find(djs~=0);
	djs        = djs(idx);
	dc(LJc,LJc)  = diag(diag(jcJ'*diag(    djs)*jcJ));
	dri(LJr,LJr) = diag(diag(jrJ'*diag(1../djs)*jrJ));
end

bnds(1) 	= ubold;