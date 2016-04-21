%function rat_pert = dypert(pvec,blk,bnds,blks)
%
%	Creates rational, stable perturbation which
%	interpolates the frequency varying perturbation, PVEC,
%	at the peak value of the lower bound in BNDS (frequency
%	where the perturbation is the smallest).  PVEC is
%	perturbation vector generated from MU, BLK is the
%	block structure, BNDS is the upper and lower bounds
%	generated from MU, BLKS is the optional numbers of
%	the blocks which are to be included in the rational
%	perturbation output.
%
%	See also: MU, MUUNWRAP, UNWRAPP, and SISORAT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function rat_pert = dypert(pvec,blk,bnds,blks)
if (nargin<3) | (nargin>4)
        disp('   usage:  rat_pert = dypert(rowp,blk,bnds)')
        return
end

[ptype,prows,pcols,pnum] = minfo(pvec);
if ptype ~= 'vary'
        disp('   PVEC is not a VARYING matrix')
        return
end

[btype,brows,bcols,bnum] = minfo(bnds);
if btype ~= 'vary'
        disp('   BNDS is not a VARYING matrix')
        return
end

if pnum~=bnum|prows~=1|brows~=1
        error('   ROWP dimensions incompatible with BNDS dimensions')
        return
end

if length(blk)==0
        error('   BLK is empty')
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

pmask = jrJ'*jcJ;       wp  = sum(sum(pmask)) + nF;
                        wps = nF;
if pcols~=wp, error('   PVEC is the wrong size'), end

[peak,peakind] = max(bnds(1:bnum,2));
wpk	= pvec(peakind,pcols+1);
pvec	= pvec(peakind,1:pcols);
bndp	= bnds(peakind,1:2);

prt	= zeros(csr(4),csc(4));
pj	= zeros(sum(Jr),sum(Jc));
if sum(Jc),
	pj(logical(pmask)) = pvec(wps+1:wp);
        prt(logical(Jr),logical(Jc)) = pj;
end
if sum(Fc)
        prt(logical(Fr),logical(Fc)) = diag(diag(fcF'*diag(pvec(1:wps))*fcF));
end
prt	= prt(Ur,Uc);
blk	= abs(blk);
pvec	= [];
pr	= 1;
pc	= 1;
for ii = 1:length(blk(:,1))
	if blk(ii,2)==0
		pvec = [pvec prt(pr,pc)];
		pr = pr + blk(ii,1);
		pc = pc + blk(ii,1);
	else
		junk = prt(pr:pr+blk(ii,1)-1,pc:pc+blk(ii,2)-1)';
		pvec = [pvec junk(:)'];
		pr = pr + blk(ii,1);
		pc = pc + blk(ii,2);
	end	% if blk
end	% for ii

pvec = vpck(pvec,wpk);
bnds = vpck(bndp,wpk);
if nargin == 4
	rat_pert = dypertsb(pvec,blk,bnds,blks);
else
	rat_pert = dypertsb(pvec,blk,bnds);
end