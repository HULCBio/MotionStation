%function [Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,
%		nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF] = rubind(K,I,J);
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function [Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,                nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF] = rubind(K,I,J);


%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<3,	disp('    rubind.m called incorrectly')
		return
end

K = K(:);            I = I(:);               J = J(:);
nK = length(K);      nI = length(I);         nJ = length(J);
nF = nK+nI;

%	Begin OLD CODE, does not work
%	cJ = fix(1000*(rem(J,1)+10*eps))
%	cJ = cJ + (cJ==0).*fix(J)
%	rJ = fix(J)
%	End OLD CODE
%	Begin NEW CODE
rJ = fix(J);
cJ = round(1000*(J-rJ));
%	End NEW CODE

%       vectors to help make index matricies
nc   = [sum(K); sum(I); sum(cJ)];    csc  = [0; cumsum(nc)];
nr   = [sum(K); sum(I); sum(rJ)];    csr  = [0; cumsum(nr)];
                                     csK  = [0; cumsum( K)];
                                     csI  = [0; cumsum( I)] + csc(2);
                                     csJc = [0; cumsum(cJ)] + csc(3);
                                     csJr = [0; cumsum(rJ)] + csr(3);
				     csF  = [0; cumsum([K;I])];

%       initialization of index matricies
Kc  = zeros(1,csc(4));               Ic = Kc;        Jc = Kc;
Kr  = zeros(1,csr(4));               Ir = Kr;        Jr = Kr;
kc  = zeros(nK,csc(4));              kr  = zeros(nK,csr(4));
ic  = zeros(nI,csc(4));              ir  = zeros(nI,csr(4));
jc  = zeros(nJ,csc(4));              jr  = zeros(nJ,csr(4));
fc  = zeros(nF,csc(4));              fr  = zeros(nF,csr(4));
ffc = zeros(csc(3),csc(4));          ffr = zeros(csr(3),csr(4));
kcK = [];    icI = [];       jcJ = [];		sc = [];
fcF = [];                    jrJ = [];		sr = [];

%       putting ones in the index matricies
                            Kc(csc(1)+1:csc(1+1)) = ones(1,nc(1));
                            Kr(csr(1)+1:csr(1+1)) = ones(1,nr(1));
                            Ic(csc(2)+1:csc(2+1)) = ones(1,nc(2));
                            Ir(csr(2)+1:csr(2+1)) = ones(1,nr(2));
                            Jc(csc(3)+1:csc(3+1)) = ones(1,nc(3));
                            Jr(csr(3)+1:csr(3+1)) = ones(1,nr(3));
for k = 1:nK,             kr(k,csK(k)+1:csK(k+1)) = ones(1, K(k));
                          kc(k,csK(k)+1:csK(k+1)) = ones(1, K(k));
end
for i = 1:nI,             ir(i,csI(i)+1:csI(i+1)) = ones(1, I(i));
                          ic(i,csI(i)+1:csI(i+1)) = ones(1, I(i));
end
for j = 1:nJ,           jr(j,csJr(j)+1:csJr(j+1)) = ones(1,rJ(j));
                        jc(j,csJc(j)+1:csJc(j+1)) = ones(1,cJ(j));
end
if nK > 0,
	kcK = kc(:,logical(Kc));
	krK = kr(:,logical(Kr));
end
if nJ > 0,
	jcJ = jc(:,logical(Jc));
	jrJ = jr(:,logical(Jr));
end
if nI > 0,
	icI = ic(:,logical(Ic));
	irI = ir(:,logical(Ir));
end
if (nK+nI)>0
	ffc(1:csc(3),1:csc(3)) = eye(csc(3));
        ffr(1:csr(3),1:csr(3)) = eye(csr(3));
end

sc = [ffc; jc];
sr  = [ffr; jr];
fc = [kc; ic];
fr = [kr; ir];
nF = nK + nI;
Fc = Kc+Ic;
Fr  = Kr+Ir;
csF = [0;cumsum([K;I])];
if nF > 0,
	fcF = fc(:,logical(Fc));
end