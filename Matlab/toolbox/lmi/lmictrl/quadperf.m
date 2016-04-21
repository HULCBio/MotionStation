% [perf,P] = quadperf(pds,g,options)
%
% Quadratic RMS gain of an affine or polytopic parameter-dependent
% systems PDS.
%
% If OPTION(1)=0,  QUADPERF estimates the quadratic H-infinity
% performance of PDS if G=0, or tests if the performance G >0
% is robust.
%
% If OPTION(1)=1,  QUADPERF maximizes the parameter region where the
% quadratic H-infinity performance G >0 can be sustained.  The maximal
% region is a dilatation of the prescribed parameter box around its
% center.  This option is only available for affine PDS.
%
% Input:
%  PDS       polytopic or parameter-dependent system (see PSYS)
%  G         prescribed performance    (default=0)
%  OPTIONS   optional 3-entry vector.
%            OPTIONS(1)   :  see above (default=0)
%            OPTIONS(2)=0 :  fast mode (default)
%                      =1 :  least conservative mode
%            OPTIONS(3)   :  bound on the condition number of P
%                            (default = 1e9)
% Output:
%  PERF      if OPTIONS(1)=0, quadratic RMS gain.  Otherwise,
%            percentage of the parameter box PV where the
%            performance G can be guaranteed  (PERF=1 means 100%)
%  P         Lyapunov matrix P
%
%
% See also  MUPERF, QUADSTAB, PSYS.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [gama,P] = quadperf(pdsys,g,options)

if nargin<1,
  error('usage: [perf,P] = quadperf(pdsys,g,options)');
elseif ~ispsys(pdsys),
  error('PDS is not a polytopic or parameter-dependent system');
else
  if nargin<2, g=0; end
  if nargin<3,
    options=[0 0 1e9];
  elseif length(options)~=3,
    error('OPTIONS should be a 3-entry vector');
  end
end

if sum(size(g))~=2, error('G must be a scalar'); end

condp=options(3); if condp==0, condp=1e9; end
[pdtype,nv,ns,ni,no]=psinfo(pdsys);

if strcmp(pdtype,'aff'),
  pv=psinfo(pdsys,'par');
elseif ~strcmp(pdtype,'pol'),
  error('PDS must be a polytopic or parameter-dependent system');
elseif ni==0 | no==0,
  error('This system has no input or no output');
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

% Q > 0
setlmis([]);
[Q,base]=lmivar(1,[ns,1]);    % Q
lmipos=newlmi;
lmiterm([-lmipos 1 1 Q],1,1);
suffcond=0;


if options(1)==0,  %   QUAD PERF MINIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 [gam,base]=lmivar(1,[1 0]);     % gamma
 lilab=[];   % labels of li variables

 if strcmp(pdtype,'aff'),  %%%% AFFINE

  % multi-convexity constraints
  addc=[];
  if pdsys(7,1)>=100,    % some pj enters both A(p),E(p)
     suffcond=1;
     for j=1:np,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',j+1));
       if (norm(b,1) | norm(a,1)>0) & norm(e,1)>0,
                                   % parameter pj enters both A,E or B,E
          multc=newlmi;   % multi-conv. LMI
          if options(2),   % accurate mode
            li=lmivar(1,[ns+no 1]);    % li
            lipos=newlmi;             % li > 0
            lmiterm([lipos 1 1 li],-1,1);
            lilab=[lilab,li];
          else             % fast mode -> li=diag(l1*I,l2*I)
            [li1,nli1]=lmivar(1,[1 0]);
            [li2,nli2]=lmivar(1,[1 0]);
            lipos1=newlmi;      % li1 > 0
            lipos2=newlmi;      % li2 > 0
            li=lmivar(3,diag([nli1*ones(ns,1);nli2*ones(no,1)])); % li
            lmiterm([lipos1 1 1 li1],-1,1);
            lmiterm([lipos2 1 1 li2],-1,1);
            lilab=[lilab,li];
          end
          lmiterm([-multc 1 1 Q],[a;c],[e;zeros(size(c))]','s');
          lmiterm([-multc 1 1 li],1,1);
          addc=[addc,j];
       end
     end
  end


  % vertex constraints
  for vertx=vmat,
     vertc=newlmi;         % vertex LMI
     [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx));
     lmiterm([vertc 1 1 Q],[a;c],[e;zeros(size(c))]','s');
     lmiterm([vertc 1 1 gam],-1,mdiag(zeros(ns),eye(no)));
     lmiterm([vertc 1 2 0],[b;d]);
     lmiterm([vertc 2 2 gam],-1,1);


     % add li terms
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
        vertc=newlmi;      % vertex LMI
        [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
        if max(max(abs(e-eye(ns))))==0, e=1; end
        lmiterm([vertc 1 1 Q],a,e','s');
        lmiterm([vertc 1 2 Q],e,c');
        lmiterm([vertc 1 3 0],b);
        lmiterm([vertc 2 2 gam],-1,1);
        lmiterm([vertc 2 3 0],d);
        lmiterm([vertc 3 3 gam],-1,1);
     end

  else

     suffcond=1;
     for i=1:nv,
       [a,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
       if max(max(abs(e-eye(ns))))==0, e=1; end
       eval(['e' num2str(i) '=e;']);
     end
     struct=zeros(nv);

     for i=1:nv,
      eval(['ei=e' num2str(i) ';']);
      [ai,bi,ci,di,e]=ltiss(psinfo(pdsys,'sys',i));
      for j=1:i,
       vertc=newlmi;                 % vertex LMI
       tij=lmivar(1,[1 0]);           % tij
       base=base+1; struct(i,j)=base; struct(j,i)=base;
       eval(['ej=e' num2str(j) ';']);
       [aj,bj,cj,dj,e]=ltiss(psinfo(pdsys,'sys',j));
       lmiterm([vertc 1 1 Q],ai,ej','s');
       lmiterm([vertc 1 1 Q],aj,ei','s');
       lmiterm([vertc 1 2 Q],ej,ci','s');
       lmiterm([vertc 1 2 Q],ei,cj','s');
       lmiterm([vertc 1 3 0],bi+bj);
       lmiterm([vertc 2 2 gam],-2,1);
       lmiterm([vertc 2 3 0],di+dj);
       lmiterm([vertc 3 3 gam],-2,1);
       lmiterm([-vertc 1 1 tij],1,2);
     end,end

     tcons=newlmi;
     tmat=lmivar(3,struct);
     lmiterm([tcons 1 1 tmat],1,1);  % [tij]<0

  end
 end

 lmis=getlmis;


 % solve mincx problem
 options=[0 200 condp 0 0];
 cobj=zeros(1,decnbr(lmis)); cobj(decinfo(lmis,gam))=1;
 [copt,xopt]=mincx(lmis,cobj,options,[],g);

 if isempty(copt),
   disp(' This system is not quadratically stable'); gama=Inf; P=[];
 else
   Q=dec2mat(lmis,xopt,Q); P=inv(Q);
   gama=copt;
   if suffcond,
     disp(sprintf(' Upper bound on the quadratic RMS gain: %7.3e ',gama));
   else
     disp(sprintf(' Quadratic RMS gain: %7.3e ',gama));
   end
 end



else          %  STABILITY BOX MAXIMIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if g <= 0, error('G must be positive'); end

 if strcmp(pdtype,'pol'),    %%%% POLYTOPIC
   error('Option "maximal stability region" not available for polytopic PDS')

 elseif strcmp(pdtype,'aff'),

   if rem(pdsys(7,1),10)==1,
      error('Not tractable when the E matrix depends on p');
   end

   % compute center
   range=pvinfo(pv,'par');
   pmed=(range(:,1)+range(:,2))/2;
   [a0,b0,c0,d0,e0]=ltiss(psinfo(pdsys,'eval',pmed));
   M0=[e0;zeros(size(c0))]';
   CT0=mdiag(zeros(ns),-g*eye(no));

   % negativity at center
   lcent=newlmi;
   lmiterm([lcent 1 1 Q],[a0;c0],M0,'s');
   lmiterm([lcent 1 1 0],CT0);
   lmiterm([lcent 1 2 0],[b0;d0]);
   lmiterm([lcent 2 2 0],-g);


   % vertex conditions
   for i=1:2^np,
      vertx=vmat(:,i);
      vertc=newlmi;          % vertex LMI
      [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx));
      a=a-a0; b=b-b0; c=c-c0; d=d-d0;
      lmiterm([vertc 1 1 Q],[a;c],M0,'s');
      lmiterm([vertc 1 2 0],[b;d]);

      lmiterm([-vertc 1 1 Q],-[a0;c0],M0,'s');
      lmiterm([-vertc 1 1 0],-CT0);
      lmiterm([-vertc 1 2 0],-[b0;d0]);
      lmiterm([-vertc 2 2 0],g);
   end
   nlfc=2^np;

 end

 lmis=getlmis;


 % solve gevp problem
 options=[1e-2 150 condp 0 0];
 [gama,xopt]=gevp(lmis,nlfc,options);


 if ~isempty(xopt),
   gama=1/gama;
   Q=dec2mat(lmis,xopt,Q); P=inv(Q);
   disp(sprintf('\n\n'));
   disp([' Quadratic stability established on  ' ...
           num2str(100*gama) '%  of the']);
   disp(' prescribed parameter box');
 else
   P=[]; gama=0;
   disp(' Optimization failed');
 end


end
