function xi = x0est(z,A,B,C,D,K,ny,nu,maxsize)
%X0EST  Private routine for dealing with x0 in 'Backcast' mode

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:20:22 $
ptol = 1e8*eps;
nx = size(A,1);
nz=ny+nu;[Ncap,dum]=size(z);n=nx;
      rowmax=nx+nz;X0=zeros(nx,1);
      M=floor(maxsize/rowmax);
      AKC = A -K*C;
      if ny>1|M<Ncap
         %R=zeros(n,n);Fcap=zeros(n,1);
         R1=[];
         for kc=1:M:Ncap
            jj=(kc:min(Ncap,kc-1+M));
            if jj(length(jj))<Ncap,jjz=[jj,jj(length(jj))+1];else jjz=jj;end
            psitemp=zeros(length(jj),ny);
            psi=zeros(ny*length(jj),n);
            x=ltitr(AKC,[K B-K*D],z); 
            x=ltitr(AKC,[K B-K*D],z(jjz,:),X0); 
                         yh=(C*x(1:length(jj),:)')'; sqrlam=1;%%%LLL
            if ~isempty(D),yh=yh+(D*z(jj,ny+1:ny+nu)')';end
            
            e=(z(jj,1:ny)-yh)*sqrlam;
            [nxr,nxc]=size(x);X0=x(nxr,:)';
            evec=e(:);
            kl=1;
            for kx=1:nx
               if kc==1
                  x0dum=zeros(nx,1);x0dum(kx,1)=1;
               else
                  x0dum=X00(:,kl);
               end
               psix=ltitr(AKC,zeros(nx,1),zeros(length(jjz),1),x0dum);
               [rp,cp]=size(psix);
               X00(:,kl)=psix(rp,:)';
               psitemp=(C*psix(1:length(jj),:)')'*sqrlam;
               psi(:,kl)=psitemp(:);kl=kl+1;   
            end
            if ~isempty(R1), R1=R1(1:n+1,:);end 
            H1=[R1;[psi,evec] ];R1=triu(qr(H1));   
            
         end
         try
            xi=pinv(R1(1:n,1:n),ptol)*R1(1:n,n+1); %%LL%% more tolerance?
         catch
            error('Problem to invert matrix. Check model stability.')
         end
         
      else
         %% First estimate new value of xi
         x=ltitr(AKC,[K B-K*D],z); 
         y0=x*C';if ~isempty(D),y0=y0+(D*z(:,ny+1:ny+nu)')';end
         psix0=ltitr(AKC',C',[1;zeros(Ncap,1)]);psix0=psix0(2:end,:);
         
         xi=pinv(psix0,ptol)*(z(:,1)-y0);  
      end
      %xi

%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:20:22 $
