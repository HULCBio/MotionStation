%function prt = unwrapp(rowp,blk)
%
%	Unwraps ROWP from a MU calculation
%	into block diagonal form
%
%	See also: MU and MUUNWRAP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $
%       Authors:  Matthew P. Newlin and Peter M. Young


 function prt = unwrapp(rowp,blk)
if nargin==0 | nargin>=3
	disp('   usage:  prt = unwrapp(rowp,blk)')
	return
end
prt = [];
[ptype,prows,pcols,pnum] = minfo(rowp);
if strcmp(ptype,'syst'), error('   rowp is a system'),  end
if (nargin == 1),	 blk = ones(prows,2);		end
if length(rowp)==0&length(blk)==0, return, end
if length(rowp)==0|length(blk)==0
        error('   ROWP dimensions incompatible with BLK dimensions')
end
if length(blk(1,:))~=2 | any(abs(round(real(blk))-blk) > 1e-6)
        error('   BLK is invalid')
elseif any(round(real(blk(:,1)))) == 0 | any(abs(blk)==NaN)
        error('   BLK is invalid')
else
        blk = round(real(blk));
end
for ii=1:length(blk(:,1))
        if all( blk(ii,:) == [ 1 0] )
        	blk(ii,:)  = [ 1 1] ;
	end
        if all( blk(ii,:) == [-1 1] )
        	blk(ii,:)  = [-1 0] ;
	end
        if all( blk(ii,:) == [-1 -1] )
        	blk(ii,:)  = [-1 0] ;
	end
end
if any(blk(:,2)<0)
	error('   BLK is invalid');
end
if any(blk(:,2)~=0&blk(:,1)<0),
	error('   Real FULL blocks not allowed');
end
if any(abs(blk)>500)
        error('   No blocks larger than 500, please')
end

	[Or,Oc,Ur,Uc,K,I,J] = ...
reindex(blk);
	[Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,                       csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF] = ...
rubind(K,I,J);

pmask = jrJ'*jcJ;

LFc = logical(Fc); LFr = logical(Fr);
LJc = logical(Jc); LJr = logical(Jr);

Lpmask = logical(pmask);

wp  = sum(sum(pmask)) + nF;
wps = nF;
if pcols~=wp,
	error('   ROWP is the wrong size'),
end

if strcmp(ptype,'cons')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANT matrix

prt = zeros(csr(4),csc(4));
pj  = zeros(sum(Jr),sum(Jc));
if sum(Jc),
	pj(Lpmask) = rowp(wps+1:wp);
	prt(LJr,LJc) = pj;
end
if sum(Fc)
	prt(LFr,LFc) = diag(diag(fcF'*diag(rowp(1:wps))*fcF));
end
prt = prt(Ur,Uc);

elseif strcmp(ptype,'vary')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARYING matrix - initialize output matrices
prt = zeros(  pnum*csr(4)+1,csc(4)+1);
        prt(  pnum*csr(4)+1,csc(4)+1) = inf;
        prt(  pnum*csr(4)+1,csc(4)  ) = pnum;
        prt(1:pnum         ,csc(4)+1) = rowp(1:pnum,pcols+1);

tprt = zeros(csr(4),csc(4));
tpj  = zeros(sum(Jr),sum(Jc));

pc =    0:csc(4):pnum*csc(4);
pr =    0:csr(4):pnum*csr(4);

%   main loop on varying matrix
for ii = 1:pnum
        trowp = rowp(ii,1:wp);
        if sum(Jc), tpj(Lpmask) = trowp(wps+1:wp); tprt(LJr,LJc) = tpj; end
        if sum(Fc)
                 tprt(LFr,LFc) = diag(diag(fcF'*diag(trowp(1:wps))*fcF));
        end
        prt(pr(ii)+1:pr(ii+1),1:csc(4)) = tprt(Ur,Uc);
end     % for ii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end     % if srtcmp