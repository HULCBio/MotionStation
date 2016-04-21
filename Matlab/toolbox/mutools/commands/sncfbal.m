% function [sysnlcf,sig,sysnrcf] = sncfbal(sys,tol)
%
%   Finds a (truncated)  balanced realization of the normalized 
%   left and right coprime factors of the system state-space 
%   model SYS. The state-space models in SYSNLCF and SYSNRCF
%   are both balanced realizations with Hankel singular values 
%   given by SIG.  
% 
%    SYSNLCF = [Nl Ml] and Nl Nl~ + Ml Ml~ = I, SYS = Ml^(-1) Nl.
%    SYSNRCF = [Nr;Mr] and Nr~ Nr + Mr~ Mr = I, SYS = Nr Mr^(-1).
%
%   The results are truncated to retain all Hankel singular values 
%   greater than TOL. If TOL is omitted then it is set to 
%   MAX(SIG(1)*1.0E-12,1.0E-16). A warning message is printed out 
%   if SYS is close to being undetectable, in which case the output 
%   may be unreliable.
%
%   See also: HANKMR, SFRWTBAL, SFRWTBLD, SRELBAL, SYSBAL,
%             SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [sysnlcf,sig,sysnrcf,Ham]  = sncfbal(sys,tol)

   if nargin<1
     disp('usage: [sysnlcf,sig,sysnrcf] = sncfbal(sys,tol)')
     return
   end
   [A,B,C,D]=unpck(sys);
   [systype,p,m,n]=minfo(sys);
   if systype~='syst'
     disp('SYS must be SYSTEM')
     return
   end

 %  Solve the GFARE soln X=S'*S

   Ham = [A' zeros(n); -B*B' -A] - [C'; -B*D']*inv(eye(p)+D*D')*[D*B' C];
   [U,Hamm]=schur(Ham);
   if any(imag(sys)), 
	[U,Hamm]=ocsf(U,Hamm);
   else 
	[U,Hamm]=orsf(U,Hamm,'s'); 
   end
   [S,SS]=schur((U(1:n,1:n)'*U(n+1:2*n,1:n)+U(n+1:2*n,1:n)'*U(1:n,1:n))/2);
    S=S*sqrt(abs(SS))*S';
   [qdr,Dr]=qr([D;eye(m)]);Dr=inv(Dr(1:m,1:m));
   [qdl,Dl]=qr([D';eye(p)]);Dl=inv(Dl(1:p,1:p)');

% change coordinates using U(1:n,1:n)

   nmuinv= norm(inv(U(1:n,1:n)));
   if nmuinv>1e12, 
     disp('Warning from SNCFBAL: SYS is close to being undetectable.');
     disp('                      Results maybe unreliable.')
     % return
   end %if nmuinv>1e12,
   B=U(1:n,1:n)'*B; %temp variable
   Cl=Dl*(C/U(1:n,1:n)');
   C=C*U(n+1:2*n,1:n); %temp variable
   Al=Hamm(1:n,1:n)';
   Bl=(B-C'*D)*Dr*Dr';        
   Hl=-(C'+B*D') *Dl'*Dl;       

% realization of nlcf [N M] is now pck(Al,[Bl Hl],Cl,[Dl*D;Dl])
% Calculate observability Gramian for nrcf [Nl Ml], R*R'

   nm11=n:-1:1;
   R=sjh6(Al(nm11,nm11),Cl(:,nm11));
   R=R(nm11,nm11)';

% calculate the Hankel-singular values of [Nl Ml]

   [W,T,V] = svd(S*R);
   sig = diag(T);

% balancing coordinates

   T = W'*S;
   Cl = Cl*T'; Al = Al*T'; 
   T = R*V; 
   Bl = T'*Bl; Al = T'*Al; Hl = T'*Hl;

% calculate the truncated dimension nn

   if nargin<2, 
	tol=max([sig(1)*1.0E-12,1.0E-16]);
   end
   nn = n;
   for i=n:-1:1, 
	if sig(i)<=tol 
		nn=i-1; 
	end
   end
   if nn==0, 
	sysnrcf = [Dl*D Dl];
	sig=[];
        sysnlcf = [];
   else
	sig = sig(1:nn);
	% diagonal scaling  by sig(i)^(-0.5)
	irtsig = sig.^(-0.5);
	onn=1:nn;
	Al=Al(onn,onn).*(irtsig*irtsig');
	Bl=(irtsig*ones(1,m)).*Bl(onn,:);
	Cl=Cl(:,onn).*(ones(p,1)*irtsig');
	Hl=Hl(onn,:).*(irtsig*ones(1,p));
	sysnlcf=pck(Al,[Bl Hl],Cl,[Dl*D Dl]);
   end %if nn==0,

%now calculate the right coprime factorization if nargout>2.

 if nargout>2,
  if nn==0, 
	sysnrcf = [D*Dr;Dr];
	sig=[];
        sysnlcf = [];
  elseif (sig(1)<0.99)&(nmuinv<=1e12),
	roms2=sqrt(1-sig.^2);
	sysnrcf=[zeros(nn+p+m,nn+m) nn*eye(nn+p+m,1); zeros(1,nn+m), -inf];
	B=(Bl-Hl*D)*Dr;
	sysnrcf(nn+p+1:nn+m+p,1:nn)=...
		-(Dr*B').*(ones(m,1)*(sig./roms2)')...
		-(D'*Dl'*Cl).*(ones(m,1)*roms2');
	sysnrcf(nn+1:nn+p,1:nn)=...
		(Dl\Cl).*(ones(p,1)*roms2')+D*sysnrcf(nn+p+1:nn+m+p,1:nn);
	sysnrcf(1:nn+m+p,nn+1:nn+m)=[B./(roms2*ones(1,m));D*Dr;Dr];
	sysnrcf(1:nn,1:nn)=(Al).*(roms2*(roms2.^(-1))');
  else
	sysnrcf = transp(sncfbal(transp(sys)));
  end %if nn==0, sysnrcf
 end, % if nargout>2
