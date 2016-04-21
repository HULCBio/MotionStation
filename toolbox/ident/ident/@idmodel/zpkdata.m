function [z,p,K,dz,dp,dK]=zpkdata(th,vec)
%IDMODEL/ZPKDATA  Quick access to zero-pole-gain data.
% 
%    [Z,P,K] = ZPKDATA(MODEL) returns the zeros, poles, and gain for
%    each I/O channel of the IDMODEL model MODEL.  The cell arrays Z,P 
%    and the matrix K have as many rows as outputs and as many columns 
%    as inputs, and their (I,J) entries specify the zeros, poles, 
%    and gain of the transfer function from input J to output I.  
%
%    Use poles_IJ = P{I,J} (curly brackets) to retrieve the poles from
%    input J to output I.
%
%    Note that K is the Gain at infinity 
%    G(z) = K*(z-z1)(z-z2)...(z-zn)/[(z-p1)(z-p2)...(z-pn)]
%
%    Other properties of MODEL can be accessed with GET or by direct 
%    structure-like referencing (e.g., MODEL.Ts)
% 
%    For a SISO model MODEL, the syntax
%        [Z,P,K] = ZPKDATA(MODEL,'v')
%    returns the zeros Z and poles P as column vectors rather than
%    cell arrays.       
%
%   [Z,P,K,dZ,dP,dK] = ZPKDATA(MODEL)
%   gives access to the estimated variance of the zeros, poles and gains:
%   dZ{ky,ku}(:,:,k) is the covariance matrix of the zero z{ky,ku}(k),
%   where the 1,1-element is the variance of the real part, the 2,2 element
%   is the variance of the imaginary part, and the 1,2 and 2,1 elements denote the
%   covariance between the imaginary and real parts of the zero.
%   A similar interpretation holds for dP.
%
%   [Z,P,K] = ZPKDATA(MODEL(ky,ku)) gives the poles associated with the indicated
%   output and input channels.
%
%   If MODEL is a time series model (no input), the poles, zeros and
%   gains of transfer function H in the unnormalized representation
%   y = H e is returned. To get the normalized representation,
%   first apply MODEL = NOISECNV(MODEL,'n').
%
%   [Z,P,K] = ZPKDATA(MODEL('Noise')) gives the zeros and poles associated
%   with the noise sources. (That is, the zeros and poles of the
%   transfer function matrix H in y = Gu + He.)


%   L. Ljung 10-1-86, revised 7-3-87,1-16-94.
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.24.4.2 $  $Date: 2004/04/10 23:17:50 $

% *** Set up default values ***
if nargin<2, vec='c';end
if isa(th,'idpoly')
	if pvget(th,'nd')>0&size(th,'Nu')>0
		th = th('m'); % Avoid involving the noise dynamics
	end
end

[a,b,c,d,km]=ssdata(th);
[nx,nu]=size(b);[ny,nx]=size(c);
Nu = nu;
if ~isreal(th) 
	[num,den] = tfdata(th);
    if nu == 0
        nu = size(num,2);
    end
	for ky = 1:ny
		for ku = 1:nu
			z{ky,ku} = roots(num{ky,ku});
			p{ky,ku} = roots(den{ky,ku});
			K(ky,ku) = num{ky,ku}(1);
		end
	end
	if strcmp(lower(vec(1)),'v');
		z = z{1,1}; p = p{1,1};
	end
	if nargout>3
		warning('No covariance info for complex valued models.')
	end
    dp=[];dz=[];dK=[];
	return
end

nny=1:ny;lny=ny; nnu=1:nu; 
if nu==0
	%lam = th.NoiseVariance;
	%L = chol(lam); L = L';
	b=km;%*L;
	d=eye(ny);%L;
	nu=ny;
   nnu=1:nu;
end 
for ku=nnu
	[z1,p1,k1]=ss2zp(a,b,c(nny,:),d(nny,:),ku);  
	if isa(th,'idarx') % Then we remove z&p at the origin
		p1 = p1(find(abs(p1)>0));
	end
	
	for ky=nny
		p{ky,ku}=p1;
        if ~isempty(z1)
		zz1 = z1(:,ky);
		zz1 = zz1(find(~isinf(zz1)));
		if isa(th,'idarx')
			zm = max(abs(zz1));
			zz1 = zz1(find(abs(zz1)>0.00001*zm));
		end
    else
        zz1 =[];
    end
		z{ky,ku}=zz1; 
	end
	K(:,ku)=k1;
end

% THresholds and infs etc %%LL%%

Ts=th.Ts;
if nargout>3
   nosd=0;
	if isa(th,'idpoly')
      Idp = {th};
      polyflag = 1;
   else
      polyflag = 0;
		if Nu>0
			[Idp,th,flag] = idpolget(th,[],'b');
		else
			[Idp,th,flag] = idpolget(th,[],'b');
			Nu = ny;
		end
		if flag
			try
				assignin('caller',inputname(1),th)
			catch
			end
		end
	end
	for ky = nny
		if isempty(Idp)
			P=[];
		else
			th = Idp{ky};
			P = pvget(th,'CovarianceMatrix');
		end
		if isempty(P)|norm(P)==0|ischar(P)
			dK(ky,:)= zeros(1,nu);
			for ku=nnu
				dz{ky,ku}=zeros(2,2,length(z{ky,ku}));  
				dp{ky,ku}=zeros(2,2,length(p{ky,ku})); 
			end
		else
			if nargout >5 % dK required
				[a,b,c,d,f,da,db]=polydata(th);
				nk = pvget(th,'nk');
            for ku = 1:nu
               if polyflag&Nu==0
                  dK(ky,ku) = 0;
               else
                  dK(ky,ku)=db(ku,nk(ku)+1);
               end
               
				end
			end
			
			Novar=0;
			% Sort out the orders of the polynomials
			na=pvget(th,'na');
			nb=pvget(th,'nb');
			nc=pvget(th,'nc');
			nd=pvget(th,'nd');
			nf=pvget(th,'nf');
			ns=2*nu+3;
			Ncum=cumsum([na nb nc nd nf]);
			pars=pvget(th,'ParameterVector'); 
			%nnb=max(nb(nnu));nnf=max(nf(nnu));
			%nzp=max(nnb-1,nnf+na);
			ll=1:na;
			a=[1 pars(ll).'];
			aa=0;
			npa = 0;
			Apoles =[];
            PVA = [];
			if na>0,
				tempP=P(ll,ll);
				[PVA,Apoles] = rotvar(a,tempP);
				npa=size(Apoles,1);
			end
			cc=1;
			for k=nnu            
				if Nu>0,
					llb=Ncum(k)+1:Ncum(k+1);
					llf=Ncum(Nu+2+k)+1:Ncum(Nu+3+k);
					b=pars(llb).';nbb=nb(k);nff=nf(k);
				else
					llb=Ncum(Nu+1)+1:Ncum(Nu+2);
					llf=Ncum(Nu+2)+1:Ncum(Nu+3);
					b=[1 pars(llb).'];nbb=nc;nff=nd;
				end
				f=[1 pars(llf).'];
				if length(b)>1,
					tempP=P(llb,llb);
					[PVB,Bzeros]=rotvar(b,tempP); 
				else
					Bzeros = zeros(0,1);
					PVB = zeros(0,0);
				end
				if length(llf)>0,
					tempP=P(llf,llf);
					[PVF,Fpoles]=rotvar(f,tempP);
				else
					Fpoles=zeros(0,1);
					PVF = zeros(0,1);
				end
                if any(any(isnan(PVF)))|any(any(isinf(PVF)))|any(any(isnan(PVA)))|any(any(isinf(PVA)))
                    nosd = 1;
                end
				zz=z{ky,k};
				nlz = length(zz)-length(Bzeros);
				Bzeros =[Bzeros;zeros(nlz,1)];
				PVB = [[PVB,zeros(size(PVB,1),nlz)];[zeros(nlz,size(PVB,2)+nlz)]];
                if any(any(isnan(PVB)))|any(any(isinf(PVB)))
                    nosd = 1;
                end
				zdsp=[];
				for kz=1:length(zz)
					[dum,ind]=min(abs(zz(kz)-Bzeros));
					if imag(zz(kz))==0
						zdsp(:,:,kz)=zeros(2,2);
						zdsp(1,1,kz)=real(PVB(ind,ind));
					else
						if ind<length(Bzeros)&abs(Bzeros(ind)-conj(Bzeros(ind+1)))<eps
							covind=[ind,ind+1];
						else
							covind=[ind-1,ind];
						end
                        try
						zdsp(:,:,kz) = PVB(covind,covind);
                    catch
                        zdsp(:,:,kz) = zeros(2,2);
                    end
					end
				end
				dz{ky,k}=zdsp;
				pp = p{ky,k};
				zdsp = zeros(2,2,length(pp));
				
				poles=[Apoles;Fpoles];
				nlz = length(pp)-length(poles);
				poles =[poles;zeros(nlz,1)];
				PVF = [[PVF,zeros(size(PVF,1),nlz)];[zeros(nlz,size(PVF,2)+nlz)]];
				for kz=1:length(pp)
					[dum,ind]=min(abs(pp(kz)-poles));
					if imag(pp(kz))==0
						zdsp(:,:,kz)=zeros(2,2);
						if ind<=npa
							zdsp(1,1,kz)=real(PVA(ind,ind));
						else
							zdsp(1,1,kz)=real(PVF(ind-npa,ind-npa));
						end
					else
						if ind<length(poles)&abs(poles(ind)-conj(poles(ind+1)))<eps
							covind=[ind,ind+1];
						else
							covind=[ind-1,ind];
						end
                        try
						if covind(1)<=npa
							zdsp(:,:,kz) = PVA(covind,covind);
						else
							zdsp(:,:,kz) = PVF(covind-npa,covind-npa);
						end
                    catch
                        zdsp(:,:,kz)=zeros(2,2);
                    end
					end
				end
				dp{ky,k}=zdsp;
				
			end
		end
		
	end
    if nosd
    dp={}; dz={};
end

end

if lower(vec(1))=='v'
	z=z{1,1};p=p{1,1}; 
	if nargout>3
		dz=dz{1,1};dp=dp{1,1}; 
	end
end
function [PV,zv] = rotvar(pol,covm)
%ROTVAR computes the covariance matrix of roots to polynomials
%
%   [PV,ZV] = rotvar(POL,COVM)
%
%   POL is the entered polynomial and
%   COVM is the covariance matrix of its coefficients
%   ZV are the zeros and PV is the covariance matrix. For
%   complex conjugate zeros, PV is the covariance matrix of the
%   real and imaginary parts.
 
[dr,dc]=size(covm);lp=length(pol);
r=roots(pol);
zv(:,1)=r;lr=length(r);
if isempty(covm),zv(:,2)=zeros(lr,1);return,end
k=1;
while k<lr+1
	if imag(r(k))==0
		D(k,:)=real(-poly(r([1:k-1,k+1:lr])));
		k=k+1;
	else
		
		D(k,:)=real(-2*poly([r([1:k-1,k+2:lr]);real(r(k))]));
		D(k+1,:)=real([0, 2*imag(r(k))*poly(r([1:k-1,k+2:lr]))]);
		k=k+2;
	end
end
D=inv(D)';
if lr~=dr,
	DZ(:,2:lp)=D/pol(1);
	DZ(:,1)=-D*pol(2:lp)'/(pol(1)^2);
else
	DZ=D;
end
PV=DZ*covm*DZ';
