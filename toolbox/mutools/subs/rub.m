%function [bnds,pert,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
%     rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,
%         ic,ir,jc,sr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,
%         icI,jcJ,jrJ,fcF,dcb,drib,y,b,ldc,ldri,lg,lal)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,pert,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
 rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF,dcb,drib,y,b,ldc,ldri,lg,lal)

%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin < 39
    disp('   rub.m called incorrectly')
    return
end

warflag = zeros(4,1);

%%%%%%%%%%  balancing
if exist('drib'),   dcbold = dcb;   dribold = drib;
    else        dcbold = 1; dribold = 1;
end
Mold = M;
    [dcb,drib,M,warflag] = ...
deebal(M,dcbold,dribold,Kc,Kr,Fc,Fr,kcK,nK,nJ,nF,csc,csr,csF,jc,jr,sc,sr,opt,           warflag);
scale = max(max(abs(M)))/5; if scale < 10*eps, scale = 1; else, M = M/scale; end
if scale == NaN | scale==Inf,    error('   Data contains Inf or NaN'),  end
%%%%%%%%%%  lower bound
if exist('y')
    ubc = max(norm(M),10*eps);
    [lb,y,b,pert,warflag] = ...
        rublow(M,nK,Kc,Kr,Ic,Ir,Jc,Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,...
            sc,sr,y,b,numits(2),warflag);
else
    if any(opt=='R')
        reptimes = goptvl(opt,'R',1,1);
        [u,s,v] = svd(M);
        ubc = max([max(max(s)) 10*eps]);
        b = v(:,1); y = b;
        [lbbest,ybest,bbest,pertbest,warflagbest] = rublow(M,nK,Kc,Kr,Ic,Ir,Jc,...
            Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,sc,sr,y,b,numits(2),warflag);
        for rreepp=1:reptimes
            b = crand(csr(4),1);    b = b/(norm(b) + 10*eps);
            y = crand(csr(4),1);    y = y/(norm(y) + 10*eps);
            [lb,y,b,pert,warflag] = rublow(M,nK,Kc,Kr,Ic,Ir,Jc,...
                Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,sc,sr,y,b,numits(2),warflag);
            % lb*scale
            if lb>lbbest
                lbbest = lb; pertbest = pert; ybest = y; bbest = b; warflagbest=warflag;
            end
        end
        lb = lbbest; pert = pertbest; y = ybest; b = bbest; warflag = warflagbest;
    else
        [u,s,v] = svd(M);
        ubc = max([max(max(s)) 10*eps]);
        b = v(:,1); y = b;
        [lb,y,b,pert,warflag] = rublow(M,nK,Kc,Kr,Ic,Ir,Jc,...
            Jr,kcK,icI,jcJ,jrJ,ic,ir,jc,jr,sc,sr,y,b,numits(2),warflag);
    end
end % if exist

    if ~sum(Ic+Jc), lbr = lb;   lb = 0;     end
    bnds = [ubc lb];
%%%%%%%%%%
dMd = M;    dc = eye(csc(4));   dri = eye(csr(4));
        dcold = 1;      driold = 1;
if nK==0,   g = []; else,       g = zeros(sum(K),1);    end

for once = 1,   %  so we can break out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if bnds(1)/max([lb 10*eps]) < 1.005 | any(opt=='L'), break, end

if nK>0

    [bnds,g,gamr,gamc,jg] = geestep(dMd,bnds,Kc,Kr,kcK,nK,csc,0.01);
if bnds(1)/max([bnds(2) 10*eps]) < 1.005,   break,      end
if any(opt=='f'),   break,                  end

    astep = (lb - bnds(1))/2;
   [bnds,g,jg,gamc,gamr,dal] = ...
		newga(dMd,astep,bnds(1),bnds,g,jg,gamc,gamr,Kc,Kr);

    alpha = bnds(1) + dal;
    [bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr] = ...
		lamb(bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr,Kc,Kr);

if bnds(1)/max([bnds(2) 10*eps]) < 1.005,   break,      end

    astep = dal/2;
    [bnds,g,jg,gamc,gamr,dal] = ...
		newga(dMd,astep,alpha,bnds,g,jg,gamc,gamr,Kc,Kr);

    [dc,dri,dMd,warflag] = ...
		newd(dMd,dc,dri,gamc,gamr,nJ,csc,csr,jc,jr,sc,sr,warflag);

    astep = dal/1;
    [bnds,g,jg,gamc,gamr,dal] = ...
		newga(dMd,astep,alpha,bnds,g,jg,gamc,gamr,Kc,Kr);
    astep = dal/1;
    [bnds,g,jg,gamc,gamr,dal] = ...
		newga(dMd,astep,alpha,bnds,g,jg,gamc,gamr,Kc,Kr);

    [bnds,alpha,ubflag] = ...
		newub(dMd,jg,gamc,gamr,bnds,csc,csr,-5,1.01,1.01);

    dcold = dc;
    driold = dri;
    [bnds,dc,dri,g,gamc] = ...
		dang(dMd,alpha,bnds,g,gamc,kc,jc,jr,fr,Kc,Kr,Ic,...
			Ir,Jc,Jr,Fc,Fr,kcK,fcF,sc,sr,csc,csr,numits(1),contol);
%%%%%%%%%%%%%%%%%
if exist('lg')
    ldMd    = ldc*M*ldri; ldcold = ldc;     ldriold = ldri;
    lalpha  = lal/scale;
    lbnds   = [ubc lb];
        lg  = real(lg);
        lgamc   = ones(csc(4),1);
        lgamc(logical(Kc)) = (1+lg.*lg).^(-0.25);
        [lbnds,ldc,ldri,lg,lgamc] = ...
    		dang(ldMd,lalpha,lbnds,lg,lgamc,kc,jc,jr,fr,...
			Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kcK,fcF,...
			sc,sr,csc,csr,numits(1),contol);
    if lbnds(1) < bnds(1)
        dc  = ldc;  dcold  = ldcold;
        dri = ldri; driold = ldriold;
        bnds = lbnds;
        g = lg;
    end
end
%%%%%%%%%%%%%%%%%

else    % if nK>0
    g = [];
    if any(opt=='f'),   break,                  end

            dcold = dc;
	    driold = dri;
	    [bnds,dc,dri] = ...
    		dand(dMd,bnds,jc,jr,fr,Ic,Ir,Jc,Jr,Fc,Fr,fcF, sc,sr,csc,...
			csr,numits(1),contol);

    %%%%%%%%%%%%%%%%%
    if exist('lg')
            ldMd    = ldc*M*ldri; ldcold = ldc;     ldriold = ldri;
            lbnds   = [ubc lb];
                    [lbnds,ldc,ldri] = ...
            dand(ldMd,lbnds,jc,jr,fr,Ic,Ir,Jc,Jr,Fc,Fr,fcF,sc,sr,csc,csr,                               numits(1),contol);
            if lbnds(1) < bnds(1)
                    dc  = ldc;      dcold  = ldcold;
                    dri = ldri;     driold = ldriold;
                    bnds = lbnds;
            end
    end
    %%%%%%%%%%%%%%%%%

end % if nK>0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % for once
dc   = dc*dcold;    dri  = driold*dri;
dcd  = dc*dcb;      drid =   drib*dri;
if ~sum(Ic+Jc)
    if lbr<=bnds(1)*(1+1e-5)
        bnds(2) = lbr;
    else
        pert = 1e50*sr'*sc;
        warflag(4) = 1;
    end
end % if ~sum
bnds = bnds*scale;       pert = pert/scale;

%   do all the warnings
if ~any(opt=='w')
  if warflag(1) & ~any(opt=='L')
        disp('   CAUTION:  D becomes illconditioned in deebal.m')
  end
  if warflag(2) & ~any(opt=='L')
        disp('   WARNING:  D becomes severely illconditioned in deebal.m')
  end
  if warflag(3) & ~any(opt=='L')
        disp('   CAUTION:  D becomes illconditioned in newd.m')
  end
  if warflag(4) & ~any(opt=='U')
        disp('   WARNING:  mu lower bound is zero')
        disp('   Perturbation is very large to indicate this')
  end
end