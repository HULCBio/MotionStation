%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [nx,ny,nz,nv,sizex,nvarx,xvp,tnvarx,...
            sizey,nvary,yvp,tnvary,...
            sizez,nvarz,zvp,tnvarz,...
            tnvar] = var2sep(vardata)

    nx = vardata(1);
    ny = vardata(2);
    nz = vardata(3);
    nv = vardata(4);
    if nx>0
        sizex = vardata(5:4+nx);
        nvarx = sizex.*(sizex+1)/2;
        tnvarx = sum(nvarx);
        xvp = cumsum([1;nvarx]);
    else
        sizex = [];
        nvarx = [];
        xvp = [];
        tnvarx = 0;
    end
    if ny>0
        sizey = vardata(5+nx:4+nx+ny);
        nvary = sizey.*(sizey-1)/2;
        tnvary = sum(nvary);
        yvp = cumsum([1;nvary]);
    else
        sizey = [];
        nvary = [];
        tnvary = 0;
        yvp = [];
    end
    if nz>0
        sizez = reshape(vardata(5+nx+ny:4+nx+ny+2*nz),nz,2);
        nvarz = sizez(:,1).*sizez(:,2);
        tnvarz = sum(nvarz);
        zvp = cumsum([1;nvarz]);
    else
        sizez = [];
        nvarz = [];
        tnvarz = 0;
        zvp = [];
    end
    tnvar = tnvarx + tnvary + tnvarz + nv;