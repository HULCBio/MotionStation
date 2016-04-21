% function [dl,dr,gl,gm,gr,prt] = muunwrap(in1,in2,in3,in4)
%
%	             [dl,dr] = muunwrap(rowd,blk)       OR
%	    [dl,dr,gl,gm,gr] = muunwrap(rowd,rowg,blk)  OR
%	[dl,dr,gl,gm,gr,prt] = muunwrap(rowd,rowg,rowp,blk)
%
%	Unwraps rowd, rowg and rowp from an rmu calculation
%	into block diagonal form.
%
%	See also: MU and RUNWRAPP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $
%       Authors:  Matthew P. Newlin and Peter M. Young

 function [dl,dr,gl,gm,gr,prt] = muunwrap(in1,in2,in3,in4)

if     nargin==2, rowd = in1;					blk = in2;
elseif nargin==3, rowd = in1;	rowg = in2;			blk = in3;
elseif nargin==4, rowd = in1;	rowg = in2;	rowp = in3;	blk = in4;
elseif nargin==0 | nargin >= 5
	disp('   usage:               [dl,dr] = muunwrap(rowd,blk)       OR')
	disp('   usage:      [dl,dr,gl,gm,gr] = muunwrap(rowd,rowg,blk)  OR')
	disp('   usage:  [dl,dr,gl,gm,gr,prt] = muunwrap(rowd,rowg,rowp,blk)')
	return
end
dl = []; dr = []; gl = []; gm = []; gr = []; prt = [];
[dtype,drows,dcols,mnum] = minfo(rowd);
if (nargin == 1),        blk = ones(drows,2);           end
if length(rowd)==0&length(blk)==0, return, end
if length(rowd)==0|length(blk)==0
        error('   ROWD dimensions incompatible with BLK dimensions')
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

[Or,Oc,Ur,Uc,K,I,J] = reindex(blk);

[Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,...
      csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF] = rubind(K,I,J);

dmask = fcF'*fcF;	wd  = sum(sum(dmask)) + nJ;
			wdf = sum(sum(dmask));
			wg  = sum(K);
pmask = jrJ'*jcJ;	wp  = sum(sum(pmask)) + nF;
			wps = nF;

LKc = logical(Kc); LKr = logical(Kr);
LFc = logical(Fc); LFr = logical(Fr);
LJc = logical(Jc); LJr = logical(Jr);

Ldmask = logical(dmask); Lpmask = logical(pmask);

if strcmp(dtype,'syst'), error('   ROWD is a system'), end
if dcols~=wd, error('   ROWD is the wrong size'), end
if nargin>2 & length(rowg)>0
	[gtype,grows,gcols,gnum] = minfo(rowg);
	if ~strcmp(dtype,gtype), error('   ROWD and ROWG are incompatible'), end
	if drows~=grows|gcols~=wg, error('  ROWG is the wrong size'), end
end
if nargin>3
	[ptype,prows,pcols,pnum] = minfo(rowp);
	if ~strcmp(dtype,ptype), error('   ROWD and ROWP are incompatible'), end
	if drows~=prows|pcols~=wp, error('   ROWP is the wrong size'), end
end
if strcmp(dtype,'cons')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANT matrix

dl = zeros(csc(4));
dr = zeros(csr(4));
df = zeros(csc(3),csc(3));
if sum(Fc),
	df(Ldmask) = rowd(1:wdf);
	dl(LFc,LFc) = df;
	dr(LFr,LFr) = df;
end
if sum(Jc)
        dl(LJc,LJc) = diag(diag(jcJ'*diag(rowd(wdf+1:wd))*jcJ));
        dr(LJr,LJr) = diag(diag(jrJ'*diag(rowd(wdf+1:wd))*jrJ));
end
dl = dl(Uc,Uc);
dr = dr(Ur,Ur);

if nargin>2 & length(rowg)>0
	gl = zeros(csc(4));
	gm = zeros(csc(4),csr(4));
	gr = zeros(csr(4));
	gk = diag(rowg);
	gl(LKc,LKc) = gk;
	gm(LKc,LKr) = gk;
	gr(LKr,LKr) = gk;
	gl = gl(Uc,Uc);
	gm = gm(Uc,Ur);
	gr = gr(Ur,Ur);
end

if nargin>3
	prt = zeros(csr(4),csc(4));
	pj  = zeros(sum(Jr),sum(Jc));
	if sum(Jc),
		pj(Lpmask) = rowp(wps+1:wp);
		prt(LJr,LJc) = pj;
	end
	if sum(Fc)
		 prt(LFr,LFc) = ...
 			diag(diag(fcF'*diag(rowp(1:wps))*fcF));
	end
	prt = prt(Ur,Uc);
end


elseif strcmp(dtype,'vary')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARYING matrix - initialize output matrices

dl =	zeros(  mnum*csc(4)+1,csc(4)+1);
           dl(  mnum*csc(4)+1,csc(4)+1) = inf;
           dl(  mnum*csc(4)+1,csc(4)  ) = mnum;
           dl(1:mnum        ,csc(4)+1) = rowd(1:mnum,dcols+1);

dr =    zeros(  mnum*csr(4)+1,csr(4)+1);
           dr(  mnum*csr(4)+1,csr(4)+1) = inf;
           dr(  mnum*csr(4)+1,csr(4)  ) = mnum;
           dr(1:mnum         ,csr(4)+1) = rowd(1:mnum,dcols+1);

tdl = zeros(csc(4));
tdr = zeros(csr(4));
tdf = zeros(csc(3),csc(3));

if nargin>2 & length(rowg)>0
  gl =	zeros(  mnum*csc(4)+1,csc(4)+1);
           gl(  mnum*csc(4)+1,csc(4)+1) = inf;
           gl(  mnum*csc(4)+1,csc(4)  ) = mnum;
           gl(1:mnum         ,csc(4)+1) = rowd(1:mnum,dcols+1);

  gm =  zeros(  mnum*csc(4)+1,csr(4)+1);
           gm(  mnum*csc(4)+1,csr(4)+1) = inf;
           gm(  mnum*csc(4)+1,csr(4)  ) = mnum;
           gm(1:mnum         ,csr(4)+1) = rowd(1:mnum,dcols+1);

  gr =  zeros(  mnum*csr(4)+1,csr(4)+1);
           gr(  mnum*csr(4)+1,csr(4)+1) = inf;
           gr(  mnum*csr(4)+1,csr(4)  ) = mnum;
           gr(1:mnum         ,csr(4)+1) = rowd(1:mnum,dcols+1);

        tgl = zeros(csc(4));
        tgm = zeros(csc(4),csr(4));
        tgr = zeros(csr(4));

end	% if nargin

if nargin>3
  prt =	zeros(  mnum*csr(4)+1,csc(4)+1);
          prt(  mnum*csr(4)+1,csc(4)+1) = inf;
          prt(  mnum*csr(4)+1,csc(4)  ) = mnum;
          prt(1:mnum         ,csc(4)+1) = rowd(1:mnum,dcols+1);

        tprt = zeros(csr(4),csc(4));
        tpj  = zeros(sum(Jr),sum(Jc));
end	% if nargin

pc = 	0:csc(4):mnum*csc(4);
pr = 	0:csr(4):mnum*csr(4);

%   main loop on varying matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:mnum

trowd = rowd(ii,1:wd);
if sum(Fc),
	tdf(Ldmask) = trowd(1:wdf);
	tdl(LFc,LFc) = tdf;
	tdr(LFr,LFr) = tdf;
end
if sum(Jc)
        tdl(LJc,LJc) = ...
		 diag(diag(jcJ'*diag(trowd(wdf+1:wd))*jcJ));
        tdr(LJr,LJr) = ...
		 diag(diag(jrJ'*diag(trowd(wdf+1:wd))*jrJ));
end
dl(pc(ii)+1:pc(ii+1),1:csc(4)) = tdl(Uc,Uc);
dr(pr(ii)+1:pr(ii+1),1:csr(4)) = tdr(Ur,Ur);

if nargin>2 & length(rowg)>0
	trowg = rowg(ii,1:wg);
        tgk = diag(trowg);
        tgl(LKc,LKc) = tgk;
        tgm(LKc,LKr) = tgk;
        tgr(LKr,LKr) = tgk;
	gl(pc(ii)+1:pc(ii+1),1:csc(4)) = tgl(Uc,Uc);
	gm(pc(ii)+1:pc(ii+1),1:csr(4)) = tgm(Uc,Ur);
	gr(pr(ii)+1:pr(ii+1),1:csr(4)) = tgr(Ur,Ur);
end

if nargin>3
	trowp = rowp(ii,1:wp);
        if sum(Jc),
		tpj(Lpmask) = trowp(wps+1:wp);
		tprt(LJr,LJc) = tpj;
	end
        if sum(Fc)
                 tprt(LFr,LFc) = diag(diag(fcF'*diag(trowp(1:wps))*fcF));
        end
	prt(pr(ii)+1:pr(ii+1),1:csc(4)) = tprt(Ur,Uc);
end
end	% for ii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end	% if srtcmp