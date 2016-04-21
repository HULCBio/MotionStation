function    [mth,lmat,rmat,pmat,qmat,ma,wmat,smat,...
                    mr,hmat,jmat,sizecd,cmat,dmat,tmat] = ...
                mamiscl(mthA,lmatA,rmatA,pmatA,qmatA,maA,wmatA,smatA,...
                    mrA,hmatA,jmatA,sizecdA,cmatA,dmatA,tmatA,...
                    lambda);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

mth=[]; lmat=[]; rmat=[]; pmat=[]; qmat=[]; ma=[]; wmat=[]; smat=[];
mr=[]; hmat=[]; jmat=[]; sizecd=[]; cmat=[]; dmat=[]; tmat=[];

% simple scale
% forms new AMI: newA = lambda A
% test routine test7_15.m

if lambda >= 0
    sl = sqrt(lambda);
    lmat = sl*lmatA;
    rmat = sl*rmatA;
    pmat = sl*pmatA;
    qmat = sl*qmatA;
    wmat = sl*wmatA;
    smat = sl*smatA;
    hmat = sl*hmatA;
    jmat = sl*jmatA;
    cmat = sl*cmatA;
    dmat = sl*dmatA;
    tmat = lambda*tmatA;
    mth = mthA;
    ma = maA;
    mr = mrA;
    sizecd = sizecdA;
elseif lambda < 0
    sl = sqrt(-lambda);
    lmat = sl*rmatA;
    rmat = sl*lmatA;
    pmat = -sl*pmatA;
    qmat = sl*qmatA;
    wmat = sl*smatA;
    smat = sl*wmatA;
    hmat = -sl*hmatA;
    jmat = sl*jmatA;
    cmat = sl*dmatA;
    dmat = sl*cmatA;
    tmat = lambda*tmatA;
    if ~isempty(mthA)
        mth = mthA(:,[2 1 3]);
    else
        mth = [];
    end
    ma = maA;
    mr = mrA;
    if ~isempty(sizecdA)
        sizecd = sizecdA(:,[2 1]);
    else
        sizecd = [];
    end
end