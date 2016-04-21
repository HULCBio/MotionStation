% function [X,Y,Z,V] = amiq2sol(q,nx,sizex,xvp,tnvarx,...
%            ny,sizey,yvp,tnvary,nz,sizez,zvp,tnvarz,nv);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [X,Y,Z,V] = amiq2sol(q,nx,sizex,xvp,tnvarx,...
            ny,sizey,yvp,tnvary,nz,sizez,zvp,tnvarz,nv);

    loc = 0;
    if nx>0
        X = allocpim([sizex sizex]);
        for i=1:nx
            X = ipii(X,vec2sm(q(loc+xvp(i):loc+xvp(i+1)-1),sizex(i)),i);
        end
        loc = loc + tnvarx;
    else
        X = [];
    end
    if ny>0
        Y = allocpim([sizey sizey]);
        for i=1:ny
            Y = ipii(Y,vec2ssm(q(loc+yvp(i):loc+yvp(i+1)-1),sizey(i)),i);
        end
        loc = loc + tnvary;
    else
        Y = [];
    end
    if nz>0
        Z = allocpim([sizez]);
        for i=1:nz
            Z = ipii(Z,reshape(q(loc+zvp(i):loc+zvp(i+1)-1),sizez(i,1),sizez(i,2)),i);
        end
        loc = loc + tnvarz;
    else
        Z = [];
    end
    if nv>0
        V = q(loc+1:length(q));
    else
        V = [];
    end