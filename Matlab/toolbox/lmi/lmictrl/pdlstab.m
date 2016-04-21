% [tau,Q0,Q1,...] = pdlstab(pds,options)
%
% Robust stability of polytopic or affine parameter-dependent
% systems (P-system)
%
% For affine systems,  PDLSTAB seeks a Lyapunov matrix Q(p)
% affine in p and such that the Lyapunov function
%
%       V(x) = x'*P(p)*x    with    P(p) = inv(Q(p))
%
% establishes stability along all parameter trajectories.
%
% For time-invariant polytopic systems where either A or E is
% constant, PDLSTAB seeks vertex Lyapunov matrices Q0, Q1,...
% such that the Lyapunov function
%
%     V(x)=x'*inv(Q)*x   with  Q = c0*Q0 + ... + cn*Qn
%
% proves stability for the entire polytope of systems
% (A,E)=(c0*A0+...+cn*An,E) or (A,E)=(A,c0*E0+...+cn*En).
%
% Input:
%  PDS       polytopic or parameter-dependent system (see PSYS)
%  OPTIONS   optional 2-entry vector.
%            OPTIONS(1)=0 :  tests robust stability   (default)
%                      =1 :  maximizes the stability region by
%                            dilatation of the parameter box
%                            around its center (affine PDS only)
%            OPTIONS(2)=0 :  fast mode (default)
%                      =1 :  least conservative mode
% Output:
%  TAU       Depending on OPTIONS(1),  negativity level or
%            stability region as a percentage of the parameter
%            box specified by PV  (TAU=1 means 100%)
%  Q0,Q1,..  For affine PDS,
%                    Q(p) = Q0 + p1*Q1 + ... + pn*Qn
%            For polytopic PDS,  Q0,Q1,... are the values of Q
%            for the vertex systems (A0,E), (A1,E),...
%
%
% See also  MUSTAB, QUADSTAB, PSYS.

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $


function [tmin,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,...
          Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20] = ...
                                  pdlstab(pds,options,flag)


if nargin<1,
  error('usage: [tmin,Q0,Q1,...] = pdlstab(pds,options)');
elseif ~ispsys(pds),
  error('PDS is not a polytopic or parameter-dependent system');
elseif nargin<2,
  options=[0 0];
elseif ~any(length(options)==[2 3]),
  error('OPTIONS should be a 2-entry vector');
end

pdsys=pds;


condp=1e7;
if nargin<3, flag=1; end
[pdtype,nv,ns]=psinfo(pdsys);
if strcmp(pdtype,'aff'),
  pv=psinfo(pdsys,'par');
elseif ~strcmp(pdtype,'pol'),
  error('PDS must be a polytopic or parameter-dependent system');
end



% prepare data

if strcmp(pdtype,'aff'),
  [typ,np]=pvinfo(pv);
  if ~strcmp(typ,'box'), pdsys=aff2pol(pdsys); pdtype='pol'; end
end


if strcmp(pdtype,'aff'),

  [range,rate]=pvinfo(pv,'par');
  ctpar=(norm(rate,1)==0) & flag;

  if any(rate(:,1)>zeros(np,1)) |  any(rate(:,2)<zeros(np,1)),
    error('0 must be an admissible rate of variation');
  end

  % test nominal stability
  if max(real(spol(psinfo(pdsys,'eval',(range(:,1)+range(:,2))/2)))) >=0,
    disp('The system is unstable for the median parameter values');
    tmin=Inf; return
  end

  % shift RANGE so that 0 is a vertex
  s0=psinfo(pdsys,'eval',range(:,1));
  pdsys(1:size(s0,1),2+(1:size(s0,2)))=s0;
  range=[zeros(np,1) range(:,2)-range(:,1)];
  nonzerpi=[];
  for j=1:np,
    if rate(j,1)~=-Inf | rate(j,2)~=Inf, nonzerpi=[nonzerpi,j]; end
    if rate(j,1)==-Inf & rate(j,2)~=Inf, rate(j,1)=-1e6;
    elseif rate(j,2)==Inf & rate(j,1)~=-Inf, rate(j,2)=1e6;
    end
  end
  npvar=length(nonzerpi);
  if npvar==0,
    error('Use QUADSTAB when all parameters vary arbitrarily fast');
  end
  rate=rate(nonzerpi,:);

  % generate the matrix of vertices (columns)
  vmat=[]; ls=1;
  for bnds=range',
     vmat=[vmat vmat;bnds(1)*ones(1,ls) bnds(2)*ones(1,ls)];
     ls=size(vmat,2);
  end
  for bnds=rate',
     if bnds(1)~=bnds(2),
        vmat=[vmat vmat;bnds(1)*ones(1,ls) bnds(2)*ones(1,ls)];
     else
        vmat=[vmat;bnds(1)*ones(1,ls)];
     end
     ls=size(vmat,2);
  end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Treat various cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(pdtype,'aff') & options(1)==0,  % AFFINE PDS, PLAIN QS TEST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 setlmis([]);

 Q0=lmivar(1,[ns,1]);   % Q0
 for k=1:npvar,
   lmivar(1,[ns,1]);    % Qk, k>1
 end

 % positivity constraint  Q0 > 1e-2 * I
 lmiterm([1 1 1 0],1e-2);
 lmiterm([-1 1 1 Q0],1,1);


 % multi-convexity constraints
 addc=[];
 for i=1:np,
   [ai,bi,ci,di,ei]=ltiss(psinfo(pdsys,'sys',i+1));
   pilb=find(nonzerpi==i);
   boolp=~isempty(pilb);
   boola=max(max(abs(ai)))>0;
   boole=max(max(abs(ei)))>0;

   % construct the vertex set for the multi-convexity constr.
   if boolp | (boole & (boola | norm(rate,1)>0)), % hay i-th m.c.
      addc=[addc,i];

      % get vertices of mult. constr.
      vertxi=[]; ls=1;
      for j=1:np,
        [aj,bj,cj,dj,ej]=ltiss(psinfo(pdsys,'sys',j+1));
        if (boola & boolp & max(max(abs(ej)))>0) |...
           (boola & boole & ~isempty(find(nonzerpi==j))) |...
           (boole & boolp & max(max(abs(aj)))>0),   % pj enters the m.c.
           vertxi=[vertxi vertxi;...
                   range(j,1)*ones(1,ls) range(j,2)*ones(1,ls)];
        else
           vertxi=[vertxi ;  range(j,1)*ones(1,ls)];
        end
        ls=size(vertxi,2);
      end
      if boole, ratei=rate; else ratei=[]; end
      for bnds=ratei',
         if bnds(1)==bnds(2),
           vertxi=[vertxi ;  bnds(1)*ones(1,ls)];
         else
           vertxi=[vertxi vertxi;bnds(1)*ones(1,ls) bnds(2)*ones(1,ls)];
         end
         ls=size(vertxi,2);
      end

      % add the mult. constr.
      dimli=1+options(2)*(ns-1);               % fast/accu mode
      lipos=newlmi;                       % li > 0
      li=lmivar(1,[dimli options(2)]);    % li
      lmiterm([lipos 1 1 li],-1,1);
      for v=vertxi,
        multc=newlmi;             % multi-conv. LMI
        lmiterm([-multc 1 1 li],1,1);
        [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',v(1:np)));
        if max(max(abs(e-eye(ns))))==0, e=1; end
        % Ai Pi E(p)'
        if boola & boolp,
          lmiterm([-multc 1 1 Q0+pilb],ai,e','s');
        end
        % A(p) Pi Ei'
        if boole & boolp,
          lmiterm([-multc 1 1 Q0+pilb],a,ei','s');
        end
        % Ai P(p) Ei'
        if boole & boola,
          lmiterm([-multc 1 1 Q0],ai,ei','s'); % Q0 term
          auxi=find(v(nonzerpi)~=0);
        else auxi=[]; end
        for k=auxi(:)',
          lmiterm([-multc 1 1 Q0+k],...
                            v(nonzerpi(k))*ai,ei','s');  % Qk term
        end
        % -dpk/dt Ei Pk Ei'
        if boole, auxi=find(v(np+1:np+npvar)~=0); else auxi=[]; end
        for k=auxi(:)',
          lmiterm([-multc 1 1 Q0+k],(-v(np+k))*ei,ei');
        end
      end
   end % if boolp..
 end % for i=1:np

 lilab=npvar+1+(1:length(addc));      % labels of li vars

 % vertex constraints
 for vertx=vmat,
    vertc=newlmi;         % vertex LMI
    [a,b,c,d,e]=ltiss(psinfo(pdsys,'eval',vertx(1:np)));
    if max(max(abs(e-eye(ns))))==0, e=1; end
    lmiterm([vertc 1 1 0],1e3*eps*condp*norm(a,1)*norm(e,1));
    lmiterm([vertc 1 1 Q0],a,e','s');

    ind = find(vertx(nonzerpi)~=0);
    for j=ind(:)',
       lmiterm([vertc 1 1 Q0+j],vertx(nonzerpi(j))*a,e','s');
    end
    ind = find(vertx(np+1:np+npvar)~=0);
    for j=ind(:)',
       lmiterm([vertc 1 1 Q0+j],(-vertx(np+j))*e,e');
    end

    % add li terms
    if ~isempty(addc), ind=find(vertx(addc)~=0); else ind=[]; end
    % ind = nonzero parameter values
    for j=ind(:)',
       jpar = addc(j);    % parameter #
       lmiterm([vertc 1 1 lilab(j)],vertx(jpar),vertx(jpar));
    end
 end

 lmis=getlmis;


 % solve feasp problem
 opts=[0 150 condp 15 0];
 [tmin,xfeas]=feasp(lmis,opts);


 for j=1:np,
   if ~isempty(find(nonzerpi==j)),
      Qj=dec2mat(lmis,xfeas,Q0+j);
   else
      Qj=zeros(ns);
   end
   eval(['Q' num2str(j) '=Qj;']);
 end
 Q0=dec2mat(lmis,xfeas,Q0);
 for j=np+1:20,
   eval(['Q' num2str(j) '=[];']);
 end


 if tmin < 0,
   disp(' This system is stable for the specified parameter trajectories');
 elseif ctpar,
   disp(' Trying for the transposed system... ');
   [tmin,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,...
          Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20] = ...
                                  pdlstab(stransp(pds),options,0);
 else
   disp(' Robust stability could not be established.');
 end



elseif strcmp(pdtype,'pol') & options(1)==0,


  if ~any(pdsys(7,1)==[0 1 10]),
     error('A or E must be constant');
  end

  setlmis([]);

  % define vars Qj > I
  for i=1:nv,
     [Qlj,base]=lmivar(1,[ns,1]);
     lmiterm([-i 1 1 Qlj],1,1);  % Qj > I
     lmiterm([i 1 1 0],0.01);
  end

  struct=zeros(nv);  % for tij...


  if any(pdsys(7,1)==[0 10]),        % E constant

     % store Ai's and E
     [a1,b,c,d,e]=ltiss(psinfo(pdsys,'sys',1));
     if max(max(abs(e-eye(ns))))==0, e=1; end
     for i=2:nv,
        [a,b,c,d,etmp]=ltiss(psinfo(pdsys,'sys',i));
        eval(['a' num2str(i) '=a;']);
     end

     for i=1:nv,
        eval(['ai=a' num2str(i) ';']);
        for j=1:i,
          eval(['aj=a' num2str(j) ';']);
          tij=lmivar(1,[1 0]);       % tij
          base=base+1; struct(i,j)=base; struct(j,i)=base;
          vertc=newlmi;
          lmiterm([vertc 1 1 j],ai,e','s');
          lmiterm([vertc 1 1 i],aj,e','s');
          lmiterm([-vertc 1 1 tij],1,2);
     end,end

  else                    % A cte

     % store Ei's and A
     [a,b,c,d,e1]=ltiss(psinfo(pdsys,'sys',1));
     if max(max(abs(e1-eye(ns))))==0, e1=1; end
     for i=2:nv,
        [atmp,b,c,d,e]=ltiss(psinfo(pdsys,'sys',i));
        if max(max(abs(e-eye(ns))))==0, e=1; end
        eval(['e' num2str(i) '=e;']);
     end

     for i=1:nv,
        eval(['ei=e' num2str(i) ';']);
        for j=1:i,
          eval(['ej=e' num2str(j) ';']);
          tij=lmivar(1,[1 0]);       % tij
          base=base+1; struct(i,j)=base; struct(j,i)=base;
          vertc=newlmi;
          lmiterm([vertc 1 1 j],a,ei','s');
          lmiterm([vertc 1 1 i],a,ej','s');
          lmiterm([-vertc 1 1 tij],1,2);
     end,end

  end

  tcons=newlmi;
  tmat=lmivar(3,struct);
  lmiterm([tcons 1 1 tmat],1,1);  % [tij]<0
  lmis=getlmis;


  % solve feasp problem
  opts=[0 150 condp 0 0];
  [tmin,xfeas]=feasp(lmis,opts);

  for j=1:nv,
    Qj=dec2mat(lmis,xfeas,Qlj);
    eval(['Q' num2str(j-1) '=Qj;']);
  end
  for j=nv:20,
    eval(['Q' num2str(j) '=[];']);
  end

  if tmin < 0,
    disp(' This system is stable in the specified parameter range');
  elseif flag
    disp(' Trying for the transposed system...');
     [tmin,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,...
          Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20] = ...
                                  pdlstab(stransp(pds),options,0);
  else
    disp(' Robust stability could not be established.');
  end


elseif options(1),

  error('Sorry, not implemented yet');

end
