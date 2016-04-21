%function [bnds,rowd,sens,rowp,rowg] = mu(matin,blk,opt)
%
%   Calculates mixed (real and complex) structured
%   singular value (mu) of a CONSTANT/VARYING matrix.
%
%   Inputs: MATIN - input matrix, CONSTANT/VARYING
%       BLK   - block structure
%       OPT   - optional argument, character string
%           containing any of the following (DEFAULT = 'lu'):
%         'l' lower bound, power iteration
%         't' increase iterations in lower bound
%         'R' start lower bound with RANDOM vectors
%         'R7' restart lower bound 7 times with RANDOM vectors (use 1-9),
%               larger number typically gives better lower bound, but involves
%               additional (and hence slower) computation
%         'u' upper bound, balanced/LMI technique
%         'c' upper bound to greater accuracy
%         'C' upper bound to even greater accuracy
%         'C1' same as 'C'
%         'C9' upper bound to greatest accuracy (use any number 1-9, larger
%              number gives better bound, but slower computation)
%         'f' fast but crude upper bound
%         'r' restart computation at EACH independent variable
%         's' suppress progress information
%         'w' suppress warnings
%         'L' only compute lower bound
%         'U' only compute upper bound
%
%   Outputs:    BNDS  - upper and lower bounds
%       SENS  - sensitivity of || D M D^{-1} || to D scaling
%       ROWP  - perturbation from lower bound
%       ROWD  - D scaling from upper bound
%       ROWG  - G scaling from upper bound
%           ROWD, SENS, ROWP, ROWG are in compressed form
%
%   See also:  UNWRAPD, UNWRAPP, MUUNWRAP, DYPERT, WCPERF, RANDEL

%       Authors:  Matthew P. Newlin, Peter M. Young and MUSYN INC
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [bnds,rowd,sens,rowp,rowg] = mu(matin,blk,opt,mdata)

if nargin < 1 | nargin > 4
    disp('   usage:  [bnds,rowd,sens,rowp,rowg] = mu(matin,blk,opt)')
    return
end
rowd = []; sens = []; rowp = []; rowg = [];
if nargin<=3
    mdata = rand(1,2);
end

[mtype,mrows,mcols,mnum] = minfo(matin);
if mtype == 'syst'
        disp('   mu for SYSTEM matrices is not implemented yet')
        return
end
if  (nargin < 2)        % a default
    if mrows==mcols
        blk = ones(mrows,2);
    else
        disp('   usage:  [bnds,rowd,sens,rowp,rowg] = mu(matin,blk,opt)')
        disp('   Nonsquare matin must have blk specified')
        return
    end % if mrows
end %if nargin

if length(matin)==0&length(blk)==0
        bnds = []; rowp = []; rowg = []; rowd = []; sens = [];
        return
end
if length(matin)==0|length(blk)==0
        error('   MATIN dimensions incompatible with BLK dimensions')
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
end
for ii=1:length(blk(:,1))
    if blk(ii,:) == [-1 -1]
        blk(ii,:) = [-1 0];
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

%%%%%%%%%%%%%%%%%

numits = [10; 50];      contol = 1.01;
if nargin < 3
    opt = 'lu';
end
if any(opt=='C')
    mumexstatus1 = exist('amevlp');
    mumexstatus2 = exist('amibndv');
    mumexstatus3 = exist('amilowxy');
    mumexstatus4 = exist('amiuppxy');
    if mumexstatus1~=3 | mumexstatus2~=3 | mumexstatus3~=3 | mumexstatus4~=3
    oldopt = opt;
    locbigc = find(opt=='C');
    opt(locbigc) = setstr('c'*ones(1,length(locbigc)));
    disp(['mu Warning: MEX functions are unavailable.  Changing option from ' oldopt ' to ' opt]);
    end
    opt = [opt 'c'];
end
if any(opt=='c'), numits(1)  = 30;  contol = 1.001;     end
if any(opt=='t'), numits(2)  = 200;             end
if any(opt=='U'), numits(2)  = 2;               end

[nblk,dum] = size(blk);

    [Or,Oc,Ur,Uc,K,I,J] = reindex(blk);
if any([length(Oc),length(Or)]~=[mrows,mcols]);
    error('   MATIN dimensions incompatible with BLK dimensions')
    return
end
    [Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,...
        csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF] = rubind(K,I,J);

LFr = logical(Fr); LFc = logical(Fc);
LJr = logical(Jr); LJc = logical(Jc);

if ~sum(Ic+Jc)
    if ~any(opt=='w')
        disp('   CAUTION:  this is a pure-real mu problem:')
        disp('             If there are convergence difficulties,')
                disp('             see Manual 4-72 through 4-78')
    end
    numits(2) = 1.5*numits(2);
end

pmask = jrJ'*jcJ;       ps = [];    wp = sum(sum(pmask)) + nF;
dmask = fcF'*fcF;       ds = [];    wd = sum(sum(dmask)) + nJ;

Lpmask = logical(pmask); Ldmask = logical(dmask);

rowg = [];                  wg = sum(K);

%   AMI stuff
dratio = 0.1;
diagnose = goptvl(opt,'d',1,0);
clevel = goptvl(opt,'C',1,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(mtype,'cons')
% CONSTANT matrix
M = matin(Oc,Or);
    [bnds,prt,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
        rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,...
                jc,jr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,icI,...
                jcJ,jrJ,fcF);
    if sum(Fc)
        ps = sum(fcF'.*(diag(prt(LFr,LFc))...
                *ones(1,nF)))./sum(fcF');
        df = dcd(LFc,LFc); rowd = df(Ldmask);
    end
    if sum(Jc)
        ds = max(jcJ'.*(diag(dcd(LJc,LJc))*ones(1,nJ)));
        pj = prt(LJr,LJc);
        rowp = pj(Lpmask);
    end
    rowp = [ps(:); rowp(:)].';
    rowd = [rowd(:); ds(:)].';
    rowg = g.';

    nrm = norm(matin);
    nogo = 0;
    if bnds(1,1)<1e-5 & nrm>1e-3
        nogo = 1;
    end
%   Break apart for AMI solver
    if any(opt=='C') & ~nogo
        blkp = ptrs(abs(blk));
        beta = bnds(1,1);
        [dynl,dynr,gynl,gynm,gynr,...
            dfl,dfr,gfm,gfr,...
            dar,dac,garc,gacr] = ynftdami(rowd,rowg,blk,beta);
        dl = dar;
        gl = gacr;
        exg = 1;

        Dinit = allocpim([1 1 1 1],3);
        Ginit = allocpim([1 1 1 1],3);
        for i=1:size(blk,1)
          if blk(i,1)>1 & blk(i,2)==0     % repeated complex
            dmat = dl(blkp(i,2):blkp(i+1,2)-1,blkp(i,2):blkp(i+1,2)-1);
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
          elseif blk(i,1)<-1 & blk(i,2)==0     % repeated real
            dmat = dl(blkp(i,2):blkp(i+1,2)-1,blkp(i,2):blkp(i+1,2)-1);
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
            gmat = gl(blkp(i,1):blkp(i+1,1)-1,blkp(i,2):blkp(i+1,2)-1);
            ng = norm(gmat)+exg;
            Ginit = ipii(Ginit,gmat,1,i);
            Ginit = ipii(Ginit,gmat-2.5*ng*eye(abs(blk(i,1))),2,i);
            Ginit = ipii(Ginit,gmat+2.5*ng*eye(abs(blk(i,1))),3,i);
          elseif blk(i,1)==-1                 % scalar real
            dmat = dl(blkp(i,2),blkp(i,2));
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
            gmat = gl(blkp(i,1),blkp(i,2));
            ng = abs(gmat)+exg;
            Ginit = ipii(Ginit,gmat,1,i);
            Ginit = ipii(Ginit,gmat-2.5*ng*eye(abs(blk(i,1))),2,i);
            Ginit = ipii(Ginit,gmat+2.5*ng*eye(abs(blk(i,1))),3,i);
          else
            dmat = dl(blkp(i,2),blkp(i,2));
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
          end
        end
        if diagnose>0
            x1=clock;
            [newu,var,dac,dar,gacr,garc] = bubd(matin,blk,Dinit,Ginit,bnds(1,2),diagnose,clevel);
            x2=clock;
        else
            [newu,var,dac,dar,gacr,garc] = bub(matin,blk,Dinit,Ginit,bnds(1,2),diagnose,clevel);
        end
        [rowd,rowg] = a2ynrow(dar,dac,garc,gacr,blk,newu);
        bnds(1,1) = newu;
        if diagnose==1
            if beta>bnds(1,2)
                percimp = (newu-bnds(1,2))/(beta-bnds(1,2));
                disp([num2str(beta) ' ' num2str(newu) ' ' num2str(bnds(1,2))])
                disp(['% Improvement in Gap: ' num2str(100-100*percimp)]);
                disp(['Time to compute: ' num2str(etime(x2,x1))]);
            end
        end
    end
    nrmbigm = norm(M);
    if bnds(1,1) > nrmbigm
        [rowd,rowg] = sigmaub(blk);
        bnds(1,1) = nrmbigm;
    end
    sens = zeros(1,nblk);
    [dl,dr] = unwrapd(rowd,blk);
    [rmatin,cmatin] = size(matin);
    sm = dl*matin/dr;
    blkp = ptrs(abs(blk));
    for i=1:nblk
        sensrow = [sm(blkp(i,2):blkp(i+1,2)-1,1:blkp(i,1)-1) ...
         sm(blkp(i,2):blkp(i+1,2)-1,blkp(i+1,1):cmatin)];
        senscol = [sm(1:blkp(i,2)-1,blkp(i,1):blkp(i+1,1)-1) ; ...
         sm(blkp(i+1,2):rmatin,blkp(i,1):blkp(i+1,1)-1)];
        sens(i) = norm(sensrow) + norm(senscol);
    end


elseif strcmp(mtype,'vary')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARYING matrix - initialize output matrices

    bnds =  zeros(  mnum+1,3);
     bnds(  mnum+1,3) = inf;
     bnds(  mnum+1,2) = mnum;
     bnds(1:mnum  ,3) = matin(1:mnum,mcols+1);
    rowp =  zeros(  mnum+1,wp+1);
     rowp(  mnum+1,wp+1) = inf;
     rowp(  mnum+1,wp  ) = mnum;
     rowp(1:mnum  ,wp+1) = matin(1:mnum,mcols+1);
    rowd =  zeros(  mnum+1,wd+1);
         rowd(  mnum+1,wd+1) = inf;
         rowd(  mnum+1,wd  ) = mnum;
         rowd(1:mnum  ,wd+1) = matin(1:mnum,mcols+1);
    sens =  zeros(   mnum+1,nblk+1);
     sens(   mnum+1,nblk+1) = inf;
     sens(   mnum+1,nblk  ) = mnum;
     sens(1:mnum  ,nblk+1) = matin(1:mnum,mcols+1);
    if wg
        rowg = zeros(  mnum+1,wg+1);
            rowg(  mnum+1,wg+1) = inf;
            rowg(  mnum+1,wg  ) = mnum;
            rowg(1:mnum  ,wg+1) = matin(1:mnum,mcols+1);
    end % if wg

pm = 0:mrows:mnum*mrows;
count = 0;
if ~any(opt=='s'),  fprintf('points completed....\n'),  end

%   main loop on varying matrix

density = mdata(2);
pcnt = 1;
for ii = 1:mnum
    M = matin(pm(ii)+1:pm(ii+1),1:mcols);
    mtmp = M;
    M = M(Oc,Or);
    if any(opt=='r') | ii==1    % note: works with any(opt=='c')
            [tbnds,prt,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF);
    elseif any(opt=='c')
            [tbnds,prt,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF,dcb,drib,y,b,dc,dri,g,tbnds(1));
    else
            [tbnds,prt,dc,dri,dcb,drib,dcd,drid,g,y,b] = ...
rub(M,K,I,J,opt,numits,contol,Kc,Kr,Ic,Ir,Jc,Jr,Fc,Fr,kc,kr,ic,ir,jc,jr,fc,fr,sc,sr,csc,csr,csF,nK,nI,nJ,nF,nc,nr,kcK,icI,jcJ,jrJ,fcF,dcb,drib,y,b);
    end
    trowd = []; trowp = [];
    if sum(Fc)
        ps = sum(fcF'.*(diag(prt(LFr,LFc))*ones(1,nF)))./sum(fcF');
        df = dcd(LFc,LFc); trowd = df(Ldmask);
    end
    if sum(Jc)
        ds = max(jcJ'.*(diag(dcd(LJc,LJc))*ones(1,nJ)));
        pj = prt(LJr,LJc); trowp = pj(Lpmask);
    end
    trowp = [ps(:); trowp(:)].';
    trowd = [trowd(:); ds(:)].';
    trowg = g.';

    nrm = norm(mtmp);
    nogo = 0;
    if tbnds(1,1)<1e-5 & nrm>1e-3
        nogo = 1;
    end
%   Break apart for AMI solver
    if any(opt=='C') & ~nogo
        blkp = ptrs(abs(blk));
        beta = tbnds(1,1);
        [dynl,dynr,gynl,gynm,gynr,...
            dfl,dfr,gfm,gfr,...
            dar,dac,garc,gacr] = ynftdami(trowd,trowg,blk,beta);
        dl = dar;
        gl = gacr;
        Dinit = allocpim([1 1 1 1],3);
        Ginit = allocpim([1 1 1 1],3);
        for i=1:size(blk,1)
          if blk(i,1)>1 & blk(i,2)==0     % repeated complex
            dmat = dl(blkp(i,2):blkp(i+1,2)-1,blkp(i,2):blkp(i+1,2)-1);
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
          elseif blk(i,1)<-1 & blk(i,2)==0     % repeated real
            dmat = dl(blkp(i,2):blkp(i+1,2)-1,blkp(i,2):blkp(i+1,2)-1);
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
            gmat = gl(blkp(i,1):blkp(i+1,1)-1,blkp(i,2):blkp(i+1,2)-1);
            ng = norm(gmat)+40;
            Ginit = ipii(Ginit,gmat,1,i);
            Ginit = ipii(Ginit,gmat-2.5*(ng)*eye(abs(blk(i,1))),2,i);
            Ginit = ipii(Ginit,gmat+2.5*(ng)*eye(abs(blk(i,1))),3,i);
          elseif blk(i,1)==-1                 % scalar real
            dmat = dl(blkp(i,2),blkp(i,2));
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
            gmat = gl(blkp(i,1),blkp(i,2));
            ng = abs(gmat)+40;
            Ginit = ipii(Ginit,gmat,1,i);
            Ginit = ipii(Ginit,gmat-2.5*ng*eye(abs(blk(i,1))),2,i);
            Ginit = ipii(Ginit,gmat+2.5*ng*eye(abs(blk(i,1))),3,i);
          else
            dmat = dl(blkp(i,2),blkp(i,2));
            Dinit = ipii(Dinit,dmat,1,i);
            Dinit = ipii(Dinit,dratio*dmat,2,i);
            Dinit = ipii(Dinit,dmat/dratio,3,i);
          end
        end
        if diagnose>0
            x1=clock;
            [newu,var,dac,dar,gacr,garc] = bubd(mtmp,blk,Dinit,Ginit,tbnds(1,2),diagnose,clevel);
            x2=clock;
        else
            [newu,var,dac,dar,gacr,garc] = bub(mtmp,blk,Dinit,Ginit,tbnds(1,2),diagnose,clevel);
        end
        [trowd,trowg] = a2ynrow(dar,dac,garc,gacr,blk,newu);
        tbnds(1,1) = newu;
    end

    nrmbigm = norm(M);
    if tbnds(1,1) > nrmbigm
        [trowd,trowg] = sigmaub(blk);
        tbnds(1,1) = nrmbigm;
    end

    bnds(ii,1:2) = tbnds;
    rowp(ii,1:wp) = trowp;
    rowd(ii,1:wd) = trowd;
    if wg,  rowg(ii,1:wg) = trowg;  end

    if any(opt=='g')
        if ii/density >= pcnt
            set(mdata(1),'string',[int2str(ii) '/' int2str(mnum)]);
            drawnow;
            pcnt = pcnt+1;
        end
    end

    if ~any(opt=='s')
        count = count + 1;
        if count < 18
            fprintf([int2str(ii) '.'])
        else
            fprintf('\n')
            fprintf([int2str(ii) '.'])
            count = 0;
        end
    end

    [tdl,tdr] = unwrapd(trowd,blk);
    sm = tdl*mtmp/tdr;
    tblkp = ptrs(abs(blk));
    if nblk == 1
        sens(ii,1) = 1;
    else
        for ib=1:nblk
            sensr = sm([tblkp(ib,2):tblkp(ib+1,2)-1],[1:tblkp(ib,1)-1 tblkp(ib+1,1):mcols]);
            sensc = sm([1:tblkp(ib,2)-1 tblkp(ib+1,2):mrows],[tblkp(ib,1):tblkp(ib+1,1)-1]);
            sens(ii,ib) = norm(sensr) + norm(sensc);
        end
    end

   end  % for ii
   if ~any(opt=='s'),  fprintf('\n'),  end
end