%function [dc,dri,dMd,warflag] = ...
%	newd(dMd,dc,dri,gamc,gamr,nJ,csc,csr,jc,jr,sc,sr,warflag)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [dc,dri,dMd,warflag] = ...
	newd(dMd,dc,dri,gamc,gamr,nJ,csc,csr,jc,jr,sc,sr,warflag)

%	compresses then finds a new DIAGONAL d given an old dc, dri.
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<12,	disp('   newd.m called incorrectly')
		return
end

Ljc = logical(jc); Ljr = logical(jr);

sizM = size(dMd);
dcold = dc;	driold = dri;
sM =  dMd.*(gamc*gamr');
a = (sc*abs(sM.*sM)*sr');
for ii = 1:nJ,
  Ljci = Ljc(ii,:);
  for ij = 1:nJ
        a(ii+csc(3),ij+csr(3)) = norm(sM(Ljci,Ljr(ij,:)))^2;
end,            end
a = a - diag(diag(a));
b = a;
d = ones(1,length(a));
costj = sum(sum(a));
oldcostj = max([2*costj 10*eps]);
j = 0;
while j < 30 & (oldcostj-costj)/oldcostj > 1e-4
        sa = max(sum(a),10*eps);
        sat = max(sum(a'),10*eps);
        d = d.*sqrt(sqrt(sa./sat));
	d = min(max(d,1e-6),1e6);
        a = b.*(d'*(1 ./d));
        j = j+1;
        oldcostj = max([costj 100*eps]);	costj = sum(sum(a));
end     % while j
d = sqrt(d/d(1,1));
dc  = 		      diag(sc'*diag(    d)*sc)*ones(1,sizM(1));
dcm = 		      diag(sc'*diag(    d)*sc)*ones(1,sizM(2));
dri = ones(sizM(2),1)*diag(sr'*diag(1../d)*sr)';
drim= ones(sizM(1),1)*diag(sr'*diag(1../d)*sr)';
dMd = dcm.*dMd.*drim;
dc  = dc.*dcold;
dri =     driold.*dri;

if any(d>=1e6)|any(d<=1e-6),	warflag(3) = 1;	end