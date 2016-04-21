function [xi,yh] = x0est_f(z,a,b,c,d,k,ny,nu,maxsize,M)
%X0EST  Private routine for dealing with x0 in 'Backcast' mode

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:20:33 $

[nx] = size(a,1);

farg = z(:,end);
Y = z(:,1:ny);
U = z(:,ny+1:ny+nu);
Ux0 = z(:,end-1);
Ncap = length(farg);
R1 = zeros(0,nx+1);
for kc=1:M:Ncap
    
    jj=(kc:min(Ncap,kc-1+M));
    %jjz = jj;
    Njj = length(jj);
    xerr = freqkern(a,b,U(jj,:),farg(jj,:));
    yh = (c*xerr).' + U(jj,:)*d.';
    err =Y(jj,:) - yh; ;
    
    %% Estimate the initial state
    
    R = zeros(Njj*ny,nx);
    idx0 = (0:Njj-1)*ny;
    fd = spdiags(farg(jj,:),0,Njj,Njj);
    fr = mimofr(a,eye(nx),c,[],farg(jj,:));
    for k=1:ny,
        if nx==1,
            R(idx0+k,:) = fd*squeeze(fr(k,:,:));
        else
            R(idx0+k,:) = fd*squeeze(fr(k,:,:)).';
        end
    end
    H = err.';
    H = H(:);
    % Solve LS problem for X0
    Rr = [real(R); imag(R)];
    Hr = [real(H); imag(H)];
    R1 = triu(qr([R1;[Rr,Hr]]));[nRr,nRc]=size(R1);
    R1 = R1(1:min(nRr,nRc),:);
end
xi = pinv(R1(1:nx,1:nx))*R1(1:nx,nx+1:nx+1);%Hr;%Rr\Hr;
%xicorr = R*xi;
%yh = yh + reshape(xicorr.',size(yh,2),size(yh,1)).';


