function [A,B,C,D,K,L] = idsample(a,b,c,d,k,T,inters,sample,dfract)
%IDSAMPLE  Sample/unsample linear systems
%
%   [As,Bs,Cs,Ds,Ks,Ls] = IDSAMPLE(A,B,C,D,K,T,InterSample,Mode,Delay)
%
%   A,B,C,D,K are the matrices of the system to be sampled/unsampled.
%   T is the sampling interval.
%   InterSample is 'zoh' or 'foh'
%   Mode = 1 (default) means sampling and Mode = 0 means unsample.
%   Delay is the input delay in time units. This does not have to be
%       an integer multiple of T. Delay is only applicable for the
%       sampling case.
%
%   As,Bs,Cs,Ds,Ks are the resulting system matrices.
%   Ls is the adjustment of the covariance matrix in case of 'foh'
%   sampling, so that the covariance of the new innovations is
%   Ls*Lambda*Ls' where Lambda is the T-adjusted covariance of the
%   noise of the original system.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.3.6.3 $ $Date: 2003/12/04 01:30:13 $

[nxr,nxc] = size(a);
if nxr~=nxc
    error('A must be a square matrix.')
end
[nx,nu]=size(b);
if nxr~=nx
    error('A and B must have the same number of rows.')
end
ny=size(d,1);
[nxy,nyk]=size(k);
if nxy~=nx
    error('B and K must have the same number of rows.')
end
b = [b k];
d = [d eye(nyk)];
L = eye(nyk);
if nargin < 9
    dfract = 0;
end
if nargin <8
    sample = 1;
end
if dfract==0
    if sample == 1 
        switch lower(inters(1))
            case 'z'
                s = expm([[a b]*T; zeros(nu+nyk,nx+nu+nyk)]);
                A = s(1:nx,1:nx);
                B = s(1:nx,nx+1:nx+nu);
                K = s(1:nx,nx+nu+1:nx+nu+nyk);
                C = c;
                D = d(:,1:nu);
            case 'f'
                
                nuy = nu+nyk;
                s = expm([[a b zeros(nx,nuy)]*T;[zeros(nuy,nx+nuy),T*eye(nuy)];...
                        zeros(nuy,nx+2*nuy)]);
                if any(any(isnan(s)))
                    A = NaN;B=NaN;C=NaN;D=NaN;K=NaN;L=NaN;
                    return
                end
                A = s(1:nx,1:nx);
                gtil = s(1:nx,nx+nuy+1:nx+2*nuy);
                BK = s(1:nx,nx+1:nx+nuy)+(A-eye(nx))*gtil/T;
                B = BK(:,1:nu); K = BK(:,nu+1:nuy);
                C = c;
                D = d(:,1:nu)+c*gtil(:,1:nu)/T;
                if nyk>0
                    L = eye(nyk) + c*gtil(:,nu+1:nuy)/T;
                    K = K*pinv(L);
                end
            otherwise
                error('Only ''Zero-order'' hold and ''First-order-hold'' sampling is supported')
        end
        
    else %Unsample
        switch lower(inters(1))
            
            case 'z'
                s = logm([[a b]; [zeros(nu+nyk,nx) eye(nu+nyk,nu+nyk)]])/T;
                if isreal([a b]), s = real(s); end
                A = s(1:nx,1:nx);
                B = s(1:nx,nx+1:nx+nu);
                K = s(1:nx,nx+nu+1:nx+nu+nyk);
                C = c;
                D = d(:,1:nu);
            case 'f'
                
                nuy = nu+nyk;
                Ac = logm(a)/T;%%LL traps for bad results
                if any(any(isnan(Ac)))
                    error('Conversion failed. Eigenvalues of A in the origin.')
                end
                if isreal(a), Ac = real(Ac); end
                s = expm([[Ac eye(nx) zeros(nx,nx)]*T;[zeros(nx,2*nx),T*eye(nx)];...
                        zeros(nx,3*nx)]);
                Gt = s(1:nx,2*nx+1:3*nx);
                Bgen = pinv(s(1:nx,nx+1:2*nx)+(a-eye(nx))*Gt/T);
                
                BK = Bgen*b;
                B = BK(:,1:nu);
                K = BK(:,nu+1:nu+nyk);
                D = d(:,1:nu) - c*Gt*B/T;
                A = Ac; 
                C = c;
                if nyk>0
                    L = eye(nyk) - c*Gt*K/T;
                    K = K*pinv(L);
                end
            otherwise
                error('Only ''Zero-order'' hold and ''First-order-hold'' sampling is supported')
            end
        end
    else % fractional delay
        if sample==0
            error('IDSAMPLE does not support unsampling with fractional delay.')
        end
        if length(dfract)==nu
            dfract = [dfract,zeros(1,nyk)];
        end
        nuk = nu + nyk;
        %%LL check more
        tolint = 1e4*eps;
        Ts = T;
        dfract = dfract/T;
        nk = floor(dfract);
        dfract = dfract - nk;
        try
            [a,b,c,junk,Ttrf] = abcbalance(a,b,c,[],Inf,'noperm','scale');
        catch 
            Ttrf = eye(size(a));
        end
        dTtrf = diag(Ttrf);
        zid = (dfract<=tolint);
        chdel = find(~zid);
        nid = length(chdel);
        switch lower(inters(1))  
            case 'z'
                Tmat = [a , b ; zeros(nuk,nx+nuk)];  % transition mat.
                cd = [c , d];
                
                E = blkdiag(eye(nx),zeros(nuk,nid));
                E(nx+chdel,nx+1:nx+nid) = eye(nid);
                F = [zeros(nx,nuk) ; double(diag(zid))];
                G = [c d(:,~zid)];
                H = zeros(ny,nuk);
                H(:,zid) = d(:,zid); 
                
                Events = sort([0 dfract 1]);
                Events(:,diff([-1,Events])<=tolint) = [];
                
                for j=1:length(Events)-1,
                    t0 = Events(j);
                    t1 = Events(j+1);
                    
                    h = (t1-t0)*T;
                    ehTmat = expm(h*Tmat);
                    E(1:nx,:) = ehTmat(1:nx,:) * E;
                    F(1:nx,:) = ehTmat(1:nx,:) * F;
                    iu = find(abs(dfract-t1)<=tolint);
                    E(nx+iu,:) = 0;    
                    F(nx+iu,iu) = eye(length(iu));
                end
                    xkeep = [1:nx , nx+chdel];
                    E = E(xkeep,:);
                    F = F(xkeep,:); 
                    
            case 'f'
                 Tmat = [a , b , zeros(nx,nuk)  ; ...
                        zeros(nuk,nx+nuk)  eye(nuk)/Ts ; ...
                        zeros(nuk,nx+2*nuk)];      % transition matrix
                cd = [c , d];
                
                nxaug = nx+nid;
                E = blkdiag(eye(nx),zeros(2*nuk,nid));
                E(nx+chdel,nx+1:nxaug) = diag(dfract(~zid));
                E(nx+nuk+chdel,nx+1:nxaug) = -eye(nid);
                F1 = [zeros(nx,nuk) ; diag(1-dfract) ; diag(~zid)];
                F2 = [zeros(nx+nuk,nuk) ; diag(zid)];
                H2 = zeros(ny,nuk);
                G = [c , d*E(nx+1:nx+nuk,nx+1:nxaug)];
                H1 = d * F1(nx+1:nx+nuk,:);
                Events = sort([0 dfract 1]);
                Events(:,diff([-1,Events])<=tolint) = [];
                
                for j=1:length(Events)-1,
                    t0 = Events(j);
                    t1 = Events(j+1);
                     h = (t1-t0)*T;
                    ehTmat = expm(h*Tmat);
                    ehTmat = ehTmat(1:nx+nuk,:);
                    E(1:nx+nuk,:) = ehTmat * E;
                    F1(1:nx+nuk,:) = ehTmat * F1;
                    F2(1:nx+nuk,:) = ehTmat * F2;
                    iu = find(abs(dfract-t1)<=tolint);
                    liu = length(iu);
                    E([nx+iu,nx+nuk+iu],:) = 0;    
                    F1([nx+iu,nx+nuk+iu],iu) = [eye(liu) ; zeros(liu)];
                    F2(nx+nuk+iu,iu) = eye(liu);
                end
                
                E = E([1:nx , nx+chdel],:);
                F1 = [F1(1:nx,:) ; zeros(nid,nuk)];
                F1(nx+1:nxaug,~zid) = eye(nid);
                F2 = [F2(1:nx,:) ; zeros(nid,nuk)]; 
                 F = F1 + E*F2 - F2;
                H = G*F2 + H1;
        end
        
        dTtrf = dTtrf(:);  
        dTi = 1./dTtrf;
        nxaug = size(E,1);
        E(1:nx,:) = repmat(dTi,[1 nxaug]) .* E(1:nx,:);
        F(1:nx,:) = repmat(dTi,[1 nuk]) .* F(1:nx,:);
        E(:,1:nx) = E(:,1:nx) .* repmat(dTtrf.',[nxaug 1]);
        G(:,1:nx) = G(:,1:nx) .* repmat(dTtrf.',[ny 1]);
        ms.a=E; ms.b = F(:,1:nu);ms.k=F(:,nu+1:nu+nyk); ms.c = G; ms.d = H(:,1:nu);
        ms.x0 = zeros(length(E),1);
        ms = addnk(ms,nk([1:nu]) +1,'par');
        A = ms.a;B=ms.b;C=ms.c;D=ms.d;K = ms.k;
    end

   