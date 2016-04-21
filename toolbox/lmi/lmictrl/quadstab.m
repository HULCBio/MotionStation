% [tau,P] = quadstab(pds,options)
%
% Quadratic stability of polytopic or parameter-dependent
% systems
%
% QUADSTAB seeks a single Lyapunov matrix Q > 0 such that
%
%          A(p)*Q*E(p)' + E(p)*Q*A(p)'  < 0
%
% over the range of values of the parameter vector p.  The
% Lyapunov function
%           V(x) = x'*P*x    with    P = inv(Q)
% then establishes stability over the entire parameter range
% and for arbitrarily fast parameter variations.
%
% The largest quadratic stability box can be computed by
% setting OPTIONS(1) appropriately.
%
% Input:
%  PDS       polytopic or parameter-dependent system (see PSYS)
%  OPTIONS   optional 3-entry vector.
%            OPTIONS(1)=0 :  tests quadratic stability (default)
%                      =1 :  maximizes the stability region by
%                            dilatation of the parameter box
%                            around its center (affine PDS only)
%            OPTIONS(2)=0 :  fast mode (default)
%                      =1 :  least conservative mode
%            OPTIONS(3)   :  bound on the condition number of P
%                            (default = 1e8)
% Output:
%  TAU       Depending on OPTIONS(1), negativity level or quadratic
%            stability region as a percentage of the parameter box
%            specified by PV  (TAU=1 means 100%)
%  P         Lyapunov matrix P = inv(Q)
%
%
% See also  MUSTAB, PDLSTAB, DECAY, QUADPERF.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [tmin,P] = quadstab(pdsys,options)

if nargin<1,
  error('usage: [tmin,P] = quadstab(pdsys,options)');
elseif ~ispsys(pdsys),
  error('PDS is not a polytopic or parameter-dependent system');
elseif nargin<2,
  options=[0 0 0];
elseif length(options)~=3,
  error('OPTIONS should be a 3-entry vector');
end

condp=options(3); if condp==0, condp=1e8; end
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
lmiterm([lmipos 1 1 0],1e-3);
lmiterm([-lmipos 1 1 Q],1,1);

suffcond=0;  % =1 when only sufficient conditions avilable


if options(1)==0,  %    PLAIN QS TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if strcmp(pdtype,'aff'),  %%%% AFFINE

  % multi-convexity constraints
  addc=[];
  if pdsys(7,1)>=100,      % some pj enters both A(p),E(p)
     suffcond=1;
     for j=1:np,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',j+1));
       if norm(a,1)>0 & norm(e,1)>0,  % parameter pj enters both A,E
          multc=newlmi;               % multi-conv. LMI
          dimli=1+options(2)*(ns-1);               % fast/accu mode
          lipos=newlmi;               % li > 0
          li=lmivar(1,[dimli options(2)]);    % li
          lmiterm([-multc 1 1 Q],a,e','s');
          lmiterm([-multc 1 1 li],1,1);
          lmiterm([lipos 1 1 li],-1,1);
          addc=[addc,j];
       end
     end
  end

  % vertex constraints
  for vertx=vmat,
     vertc=newlmi;         % vertex LMI
     [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx));
     if max(max(abs(e-eye(ns))))==0, e=1; end
     if isempty(addc),
        scala=1; scale=1;
     else
        scala=0.01*max(100,max(max(abs(a))));
        scale=0.01*max(100,max(max(abs(e))));
     end
     lmiterm([vertc 1 1 Q],a/scala,e'/scale,'s');

     % add li terms
     lilab=Q+(1:length(addc));      % labels of li vars
     if ~isempty(addc), ind=find(vertx(addc)~=0); else ind=[]; end
     % ind = nonzero parameter values
     for j=addc(ind),               % j -> j-th parameter
        lmiterm([vertc 1 1 lilab(j)],vertx(j),vertx(j));
     end
  end


 else  %%%%%%% POLYTOPIC

  if any(pdsys(7,1)==[1 10 0]),   % Aj or Ej constant

     % vertex constraints
     for i=1:nv,
        vertc=newlmi;          % vertex LMI
        [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
        if max(max(abs(e-eye(ns))))==0, e=1; end
        scala=0.01*max(100,max(max(abs(a))));
        scale=0.01*max(100,max(max(abs(e))));
        lmiterm([vertc 1 1 Q],a/scala,e'/scale,'s');
     end

  else

     suffcond=1;

     for i=1:nv,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
       if max(max(abs(e-eye(ns))))==0, e=1; end
       eval(['a' num2str(i) '=a;']);
       eval(['e' num2str(i) '=e;']);
     end
     struct=zeros(nv);

     for i=1:nv,
      eval(['ai=a' num2str(i) ';ei=e' num2str(i) ';']);
      for j=1:i,
       vertc=newlmi;             % vertex LMI
       tij=lmivar(1,[1 0]);      % tij
       base=base+1; struct(i,j)=base; struct(j,i)=base;
       eval(['aj=a' num2str(j) ';ej=e' num2str(j) ';']);
       lmiterm([vertc 1 1 Q],ai,ej','s');
       lmiterm([vertc 1 1 Q],aj,ei','s');
       lmiterm([-vertc 1 1 tij],1,2);
     end,end

     tcons=newlmi;
     tmat=lmivar(3,struct);
     lmiterm([tcons 1 1 tmat],1,1);  % [tij]<0

  end
 end

 lmis=getlmis;


 % solve feasp problem
 options=[0 300 condp 300 0];
 [tmin,xfeas]=feasp(lmis,options);
 Q=dec2mat(lmis,xfeas,Q); P=inv(Q);

 if tmin > 1e-5 | isempty(tmin),
   if suffcond,
     disp(' Could not establish quadratic stability with available test');
   else
     disp(' This system is not quadratically stable');
   end
 elseif tmin > 0,
   disp(' Marginal quadratic stability: further checking needed');
 else
   disp(' This system is quadratically stable');
 end



elseif options(1)==1,  % STABILITY REGION MAXIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 if strcmp(pdtype,'pol'),    %%%% POLYTOPIC
   error('Option "maximal stability region" not available for polytopic PDS')

 elseif strcmp(pdtype,'aff'),

   if rem(pdsys(7,1),10)==1,
      error('Not tractable when the E matrix depends on p');
   end

   % compute center
   pmed=(range(:,1)+range(:,2))/2;
   [a0,b,c,d,e0]=ltiss(psinfo(pdsys,'eval',pmed));
   if max(max(abs(e0-eye(ns))))==0, e0=1; end

   % negativity at center
   lcent=newlmi;
   lmiterm([lcent 1 1 Q],a0,e0','s');

   % vertex conditions
   for i=1:2^np,
      vertx=vmat(:,i);
      vertc=newlmi;          % vertex LMI
      [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx));
      a=a-a0;
      lmiterm([vertc 1 1 Q],a,e0','s');
      lmiterm([-vertc 1 1 Q],-a0,e0','s');
   end
   nlfc=2^np;

 end

 lmis=getlmis;

 % solve gevp problem
 options=[1e-2 200 condp 0 0];
 [tmin,xopt]=gevp(lmis,nlfc,options);


 if ~isempty(xopt),
   tmin=1/tmin;
   Q=dec2mat(lmis,xopt,Q); P=inv(Q);
   disp([' Quadratic stability established on  ' ...
           num2str(100*tmin) '%  of the']);
   disp(' prescribed parameter box');
 else
   P=[]; tmin=Inf;
   disp(' Optimization failed');
 end

end
