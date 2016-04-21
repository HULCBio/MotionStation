%function [low,y,b,pert,warflag] = ...
%rublow(M,nK,Kc,Kr,Ic,Ir,Jc,Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,sc,sr,y,b,
%numits,warflag)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

 function [low,y,b,pert,warflag] = ...
 rublow(M,nK,Kc,Kr,Ic,Ir,Jc,Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,sc,sr,y,b,              numits,warflag)

%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin < 21
    disp('   rublow.m called incorrectly')
    return
end

LIc = logical(Ic); LIr = logical(Ir);
LJc = logical(Jc); LJr = logical(Jr);
LKc = logical(Kc); LKr = logical(Kr);

krK = kcK;  irI = icI;
%       set up for the power iteration

low = 0;    pinfo = [1 numits]; a = M*b;
qb = ones(nK,1);

scol    = 1;        newscol = [2 3 1];      itno  = 0;
stobeta = [1;1]*(1:length(newscol));
stoazyb = ones(2*sum(size(M)),1)*(1:length(newscol));   tol   = [1e-4 1e-4];

step = length(M)/4; scl = max(max(abs(M)));
%       Remember:  a & z conform to columns of delta; y & b to rows.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   carry out the power iteration

candyt = clock;
while itno > -numits & itno <= 0            itno = itno - 1;

abeta = M*b;    beta = norm(abeta);
if beta <= 1e-6*scl, pinfo = [2 abs(itno)]; break,          end
a = abeta/beta;

ylkr = y(LKr);
ylir = y(LIr);
blkr = b(LKr);
bKbK = sqrt(krK*abs(blkr.^2));
aKaK = sqrt(kcK*abs(a(LKc).^2));
yJyJ = sqrt(jrJ*abs(y(LJr).^2));
aJaJ = sqrt(jcJ*abs(a(LJc).^2));

aKaK = aKaK(:);
bKbK = bKbK(:);
aJaJ = aJaJ(:);
yJyJ = yJyJ(:);
ylkr = ylkr(:);
ylir = ylir(:);
blkr = blkr(:);

if itno == -1,
    qb = real(krK*(conj(blkr).*a(LKc)));
end

yIaI = irI*(conj(ylir).*a(LIc));
yIaI = yIaI + (abs(yIaI)<10*eps);

aKyK = krK*(conj(a(LKc)).*ylkr);

bKbK = bKbK + ((abs(bKbK)<10*eps)&(abs(aKaK)<10*eps));
aKaK = aKaK + (abs(aKaK)<10*eps).*bKbK;

yJyJ = yJyJ + ((abs(yJyJ)<10*eps)&(abs(aJaJ)<10*eps));
aJaJ = aJaJ + (abs(aJaJ)<10*eps).*yJyJ;

if any(Kr)>0
        qz = sign(qb).*bKbK./aKaK + step*real(aKyK);
        qz = qz./(max(abs(qz),1));
else,   qz = zeros(0,1);
end
z = [              (krK'*qz).*ylkr ;   % QK'.*yK
    (irI'*(yIaI./abs(yIaI))).*ylir ;   % QI'.*yI
         (jcJ'*(yJyJ./aJaJ)).*a(LJc) ];  % DJc.*aJ

ybeta = M'*z;   bety = norm(ybeta);
if bety <= 1e-6*scl, pinfo = [2 abs(itno)]; break,          end
y = ybeta/bety;

aKyK = krK*(conj(a(LKc)).*ylkr);
aIyI = irI*(conj(a(LIc)).*ylir);
    aIyI = aIyI + (abs(aIyI)<10*eps);
aJaJ = sqrt(jcJ*abs(a(LJc).^2));
yJyJ = sqrt(jrJ*abs(y(LJr).^2));
    aJaJ = aJaJ + ((abs(aJaJ)<10*eps)&(abs(yJyJ)<10*eps));
    yJyJ = yJyJ + (abs(yJyJ)<10*eps).*aJaJ;
if any(Kr)>0
        qb = sign(qz).*bKbK./aKaK + step*real(aKyK);
        qb = qb./(max(abs(qb),1));
else,   qb = zeros(0,1);
end
b = [              (krK'*qb).*a(LKc) ;       %  QK.*aK
    (icI'*(aIyI./abs(aIyI))).*a(LIc) ;       %  QI.*aI
             (jrJ'*(aJaJ./yJyJ)).*y(LJr) ];      % DJr.\yJ

stobeta(:,scol) = [beta; bety];
stoazyb(:,scol) = [a;z;y;b];            scol = newscol(scol);

low = max(beta,bety);  %returns this even if not converged

[nrss,ncss] = size(newscol);
if max(max(1 - stobeta./(max(stobeta')'*ones(nrss,ncss)) )) <= tol(1)*scl
        if max(max(abs(stoazyb - stoazyb(:,1)*ones(nrss,ncss)))) <= tol(2)
                itno  = -itno;
        pinfo = [0 abs(itno)];
end,    end

end     % while
candyt2 = clock;
etime(candyt2,candyt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   now compute a valid lower bound and perturbation

if (all(Ic==0)) & (all(Jc==0))
    if (pinfo(1)~=0) | (low<10*eps),    low = 0;
    else,                   pert = diag(krK'*qb);
    end
elseif all(Kc==0)
    [vcs,egs] = eig(rupert(b,a,ic,ir,jc,jr,'unitary')*M);
    [low,ind] = max(abs(diag(egs)));    vcs = vcs(:,ind(1));
    if low > 10*eps
        veca = M*vcs/low;       vecb = vcs;
        [pert,np] = rupert(vecb,veca,ic,ir,jc,jr,'dyad');
        low = low/np;
    end
else    % (all(Ic
     nk = sum(Kc);  LCc = LIc | LJc; LCr = LIr | LJr;
     icC = []; irC = []; jcC = []; jrC = [];
     if sum(Ic),    icC = ic(:,LCc); irC = ir(:,LCr);  end
     if sum(Jc),    jcC = jc(:,LCc); jrC = jr(:,LCr);  end
     pert = zeros(length(M(1,:)),length(M(:,1)));
     pertu = rupert(b(LCr),a(LCc),icC,irC,jcC,jrC,'unitary');
     if low <= 10*eps
    [vcs,egs] = eig(pertu*M(LCc,LCr));
    [low,ind] = max(abs(diag(egs)));    vcs = vcs(:,ind(1));
    if low > 10*eps
        [pert(LCr,LCc),np] = ...
            rupert(vcs,M(LCc,LCr)*vcs/low,icC,irC,jcC,jrC,'dyad');
        low = low/np;
    end
     elseif abs(det(eye(nk)-(( (krK'*(qb/low))*ones(1,nk) ).*M(LKc,LKr))))<1e-100
    pert(LKr,LKc) = diag(krK'*qb);
     else   % if low <= 10*eps
    pertr = diag(krK'*qb);      lowr = low;
    G = M;      G(LKc,:) = pertr/lowr*M(LKc,:);
    fu  = G(LCc,LCr) + ...
		 G(LCc,LKr)*((eye(nk) - ...
		 G(LKc,LKr))\G(LKc,LCr));
    [vcs,egs] = eig(pertu*fu);
    [lowc,ind] = max(abs(diag(egs)));   vcs = vcs(:,ind(1));
    low = min(lowr,lowc);
    lowd = abs(lowr-lowc);
    if (lowd >= (0.025*lowr))
        if low < 10*eps
            lowr2 = 0.1*lowr;
        else
            lowr2 = low + lowd*max(0.1,min(0.5,1-lowd/low));
        end % if low
        G(LKc,:) = (lowr/lowr2)*G(LKc,:);
        if abs(det(eye(nk) - G(LKc,LKr))) > 1e-100
            fu2 = G(LCc,LCr) + ...
			G(LCc,LKr)*((eye(nk) - ...
			G(LKc,LKr))\G(LKc,LCr));
            [vcs2,egs2] = eig(pertu*fu2);
            [lowc2,ind2] = max(abs(diag(egs2)));
            vcs2 = vcs2(:,ind2(1));
            low2 = min(lowr2,lowc2);
            if low2 > low
                fu   = fu2; vcs  = vcs2;
                lowr = lowr2;   lowc = lowc2;   low = low2;
            end % if low2
        else,   low = lowr2;    clear fu
        end
    end % if lowd
    if (low > 10*eps) & (exist('fu'))
        [pert(LCr,LCc),np] = ...
		rupert(vcs,fu*vcs/lowc,icC,irC,jcC,jrC,'dyad');
        lowc = lowc/np;
        low = min(lowr,lowc);
        pert(LCr,LCc) = pert(LCr,LCc)*(low/lowc);
        pert(LKr,LKc) = pertr*(low/lowr);
    elseif low > 10*eps
        pert(LKr,LKc) = pertr;
    end % if (low
     end % if low
end  % if (all(Ic

% now normalize the almost unitary perturbation if valid

if low <= 10*eps
    pert = 1e50*sr'*sc;
    warflag(4) = 1;
else
    pert = pert/low;
end