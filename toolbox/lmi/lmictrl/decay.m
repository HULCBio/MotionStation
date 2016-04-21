%  [rate,P] = decay(pds,options)
%
%  Quadratic decay rate of polytopic or parameter-dependent
%  systems
%
%  DECAY minimizes t over the Lyapunov matrices Q > 0 such
%  that
%
%        A(p)*Q*E(p)' + E(p)*Q*A(p)'  <   t * E(p)*Q*E(p)'
%
%  over the range of values of the parameter vector p.  The
%  system is quadratically stable if tmin < 0.
%
%  Input:
%   PDS       polytopic or parameter-dependent system (see PSYS)
%   OPTIONS   optional 2-entry vector.
%             OPTIONS(1)=0 :  fast mode (default)
%                       =1 :  least conservative mode
%             OPTIONS(2)   :  bound on the condition number of P
%                             (default = 1e9)
%  Output:
%   RATE      decay rate
%   P         Lyapunov matrix P = inv(Q)
%
%
%  See also  QUADSTAB, MUSTAB, PDLSTAB.

%  Author: P. Gahinet  10/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [tmin,P] = decay(pdsys,options)

if nargin<1,
  error('usage: [rate,P] = decay(pdsys,options)');
elseif ~ispsys(pdsys),
  error('PDS is not a polytopic or parameter-dependent system');
elseif nargin<2,
  options=[0 1e9];
elseif length(options)~=2,
  error('OPTIONS should be a 2-entry vector');
end

condp=options(2); if condp==0, condp=1e9; end
[pdtype,nv,ns]=psinfo(pdsys);
if strcmp(pdtype,'aff'),
  pv=psinfo(pdsys,'par');
elseif ~strcmp(pdtype,'pol'),
  error('PDS must be a polytopic or parameter-dependent system');
end


% prepare data

if strcmp(pdtype,'aff'),

  [typ,np]=pvinfo(pv);

  if ~strcmp(typ,'box'),
     pdsys=aff2pol(pdsys); pdtype='pol';
  else
     % generate the matrix of vertices (columns)
     range=pvinfo(pv,'par');
     vmat=[]; ls=1;
     for bnds=range',
       vmat=[vmat vmat;bnds(1)*ones(1,ls) bnds(2)*ones(1,ls)];
       ls=size(vmat,2);
     end
  end

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Treat various cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Q > I
setlmis([]);
[Q,base]=lmivar(1,[ns,1]);  % Q
lmipos=newlmi;
lmiterm([lmipos 1 1 0],1);
lmiterm([-lmipos 1 1 Q],1,1);

suffcond=0;  % =1 when only sufficient conditions avilable



if strcmp(pdtype,'aff'),  %%%%% AFFINE

  % multi-convexity constraints
  addc=[];
  if pdsys(7,1)>=100,         % some pj enters both A(p),E(p)
     suffcond=1;
     for j=1:np,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',j+1));
       if norm(a,1)>0 & norm(e,1)>0,  % parameter pj enters both A,E
          multc=newlmi;               % multi-conv. LMI
          dimli=1+options(1)*(ns-1);  % fast/accu mode
          lipos=newlmi;               % li > 0
          li=lmivar(1,[dimli options(1)]);    % li
          lmiterm([-multc 1 1 Q],a,e','s');
          lmiterm([-multc 1 1 li],1,1);
          lmiterm([lipos 1 1 li],-1,1);
          addc=[addc,[j;-multc]];
       end
     end
  end

  % vertex constraints
  for vertx=vmat,
     vertc=newlmi;          % vertex LMI
     [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx));
     if max(max(abs(e-eye(ns))))==0, e=1; end
     lmiterm([vertc 1 1 Q],a,e','s');
     lmiterm([-vertc 1 1 Q],e,e');

     % add li terms
     lilab=Q+(1:size(addc,2));      % labels of li vars
     if ~isempty(addc),
        aux=addc(1,:); ind=find(vertx(aux)~=0);
     else aux=[]; ind=[]; end
     % ind = nonzero parameter values
     for j=aux(ind),               % j -> j-th parameter
        lmiterm([vertc 1 1 lilab(j)],vertx(j),vertx(j));
     end
  end
  lmis=getlmis;

  % solve gevp problem
  nlfc=2^np;
  options=[1e-2 150 condp 0 0];
  [tmin,xopt]=gevp(lmis,nlfc,options);

  if tmin<0 & rem(pdsys(7,1),10),  % refine estimate
     iter=1;
     disp(' Iterative improvement of the upper estimate');
     while iter<5,
       setlmis(lmis);
       for l=addc,
         [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',l(1)+1));
         lmiterm([l(2) 1 1 Q],-tmin*e,e');
       end
       [t1,x1]=gevp(getlmis,nlfc,options,.9*tmin,xopt);
       if isempty(t1) | t1 >= tmin,
         iter=5;
       else
         if t1 >= 1.1*tmin, iter=5; end
         tmin=t1; xopt=x1;
       end
     end
  end


% left out: using the Aj Q E' + E Q Aj < E Y E' , Y < tP trick
% very slow on Fan's ex.
% See QUADSTAB in /test/robust for the implementation of this option

elseif strcmp(pdtype,'pol'),  %%%%%% POLYTOPIC

  if any(pdsys(7,1)==[1 10 0]),   % Aj or Ej constant

     % vertex constraints
     for i=1:nv,
        vertc=newlmi;          % vertex LMI
        [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
        if max(max(abs(e-eye(ns))))==0, e=1; end
        scal=1e-2*...
          sqrt(max(100,max(max(abs(a))))*max(100,max(max(abs(e)))));
        a=a/scal; e=e/scal;
        lmiterm([vertc 1 1 Q],a,e','s');
        lmiterm([-vertc 1 1 Q],e,e');
     end
     nlfc=nv;

  else

     suffcond=1;
     Amat=[]; Emat=[];
     for i=1:nv,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
       Amat=[Amat;a];  Emat=[Emat;e];
     end
     M=zeros(nv);

     for i=2:nv,for j=1:i-1,
        base=base+1; M(i,j)=base; M(j,i)=base;     % var tij
        tij=lmivar(1,[1 0]);
        tijpos=newlmi;
        lmiterm([-tijpos 1 1 tij],1,1);  % tij > 0
     end,end
     struct=kron(M,eye(ns));

     main=newlmi;
     Tmat=lmivar(3,struct);
     lmiterm([main 1 1 Q],Amat,Emat','s');
     lmiterm([-main 1 1 Q],Emat,Emat');
     lmiterm([-main 1 1 0],1e-5);
     lmiterm([main 1 1 Tmat],1,1);
     nlfc=1;
  end
  lmis=getlmis;

  % solve gevp problem
  options=[1e-2 150 condp 0 0];
  [tmin,xopt]=gevp(lmis,nlfc,options);


end


if ~isempty(xopt),
   Q=dec2mat(lmis,xopt,Q); P=inv(Q);
   if suffcond,
   disp(' Warning: this is only an upper bound on the optimal decay rate');
   end
else
   P=[];
   disp(' Decay rate optimization failed');
end

