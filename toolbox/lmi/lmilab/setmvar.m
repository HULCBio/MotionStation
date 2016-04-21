% newsys = setmvar(lmisys,k,X)
%
% Sets the K-th matrix variable Xk to X and evaluates all
% LMI terms involving Xk. The constant terms are updated
% accordingly.
%
% For convenience, set K to the identifier returned by
% LMIVAR.  Since SETMVAR does not alter the variable
% identifiers, the remaining matrix variables can still
% be referred to by their original identifier.
%
% Input:
%   LMISYS       array describing the system of LMIs
%   K	         identifier of the variable matrix to be
%                set to X
%   X            matrix value assigned to Xk  (a scalar t
%                is interpreted as t*I)
% Output:
%   NEWSYS       updated description of the LMI system
%
%
% See also  LMIVAR, DELMVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function NEWsys=setmvar(LMIsys,k,X)

if nargin ~= 3,
  error('usage: newsys = setmvar(lmisys,k,X)');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
elseif any(size(k)~=[1 1]),
  error('The variable identifier K must be a scalar');
end

[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);

nlmis=size(LMI_set,2); nvars=size(LMI_var,2);
nterms=size(LMI_term,2);
if ~nvars,
  error('No matrix variable defined in LMISYS');
elseif ~nlmis | ~nterms,
  error('No LMI or term is described in LMISYS');
elseif k<=0 | k>max(LMI_var(1,:)),
  error('K is out of range');
end



% retrieve record describing Xk
krk=find(LMI_var(1,:)==k);   % column of LMI_var describing Xk
vark=LMI_var(:,krk);
typek=vark(2);
basek=vark(3);
lastk=vark(4);
rowk=vark(5);
colk=vark(6);
scalbool=(rowk==1 & colk==1);   % scalar var?
ndec=decnbr(LMIsys);


% check dimensioning X / Xk is consistent
%----------------------------------------
[rX,cX]=size(X);
if rX==1 & cX==1,            % Xk = scalar
  if rowk==colk,    X=X*eye(rowk);
  elseif X==0,      X=zeros(rowk,colk);
  else            error('X cannot be of the form t*I'); end
elseif rX~=rowk | cX~=colk,
  error('X is not properly dimensioned');
end


% fully determine the block sizes and inner size
%-----------------------------------------------
j=0; dreflmi=zeros(1,max(abs(LMI_set(1,:)))); % dereferencing of LMI labels

for lmi=LMI_set,
  lmilb=lmi(1); j=j+1; dreflmi(lmilb)=j;
  insize=lmi(3); blckdims=lmi(7:6+lmi(6));

  % fully determine the block sizes and inner size
  % NB: insize>0 only if forced by outer factor
  ind=find(blckdims<=0); % undetermined block sizes
  lneg=length(ind);
  if insize<=0,      % inner size undetermined
     blckdims(ind)=ones(length(ind),1); insize=sum(blckdims);
     LMI_set(3,j)=insize;
  elseif lneg==1,    % one scalar block
     blckdims(ind)=insize-sum(blckdims(find(blckdims>0)));
  elseif lneg,       % several scalar blocks -> ambiguous
     blckdims(ind)=ones(length(ind),1);
     if sum(blckdims) ~= insize,
       error(sprintf(...
        ['LMI #%d: ambiguous block dimensioning (multiple scalar terms)\n' ...
         '        please dimension the relevant coefficient matrices'],lmilb))
     end
  elseif sum(blckdims)~=insize,
     error(sprintf(...
     'LMI #%d: the inner and outer factors have incompatible dimensions',...
     lmilb));
  end
  if lneg, LMI_set(6+ind,j)=blckdims(ind); end
end



% (1) form the list of dec. vars. known from Xk and set
%     corresponding portion of DECVARS.
%----------------------------------------------------------------
decvars=zeros(1,ndec);

if typek==1,
  listdec=basek+1:lastk;
  dec=[]; rcb=0;
  for l=1:vark(7),
     bsize=vark(6+2*l);
     btype=vark(7+2*l);
     if btype==1,      % block type = 1
        dec=[dec;ma2ve(X(rcb+(1:bsize),rcb+(1:bsize)),1)];
     elseif btype==0,
        dec=[dec;X(rcb+1,rcb+1)];
     end
     rcb=rcb+bsize;
  end
  decvars(listdec)=dec;
elseif typek==2,
  listdec=basek+1:lastk;
  decvars(listdec)=ma2ve(X,2);
else
  struct=vark(7:6+rowk*colk);
  %%% v4 code
  % Xvec(:)=X';

  %%% v5 code
  tmpX = X';
  Xvec = tmpX(:);

  listdec=[];
  for t=[struct,Xvec]',
    n=abs(t(1));
    if n>0,
      decvars(n)=sign(t(1))*t(2);
%%% v4 code
%      if isempty(find(listdec==n)), listdec=[listdec,n]; end

%%% v5 code
       if isempty(listdec), listdec = n;
       elseif isempty(find(listdec==n)), listdec=[listdec,n]; end

    end
  end
end


% check structure consistency
lmitmp=lmipck([],vark,[],[]);
lmitmp(8)=ndec;
Xs=dec2mat(lmitmp,decvars,vark(1));
if norm(X-Xs,1) > 0,
   error(['The argument X',num2str(k),' is not properly structured']);
end


% (2) build list of the matrix variables involving some
%     of the decision vars in Xk
%-------------------------------------------------------------

% vars Xm involving some of Xk's dec. vars
rg=[1:krk-1,krk+1:nvars];
ivars=rg(find(LMI_var(3,rg) < max(listdec) & LMI_var(4,rg) >= min(listdec)));
X=X(:); nzX=any(X); dvars=krk;
svars=[k;1;nzX]; if nzX, svars=[svars;rX;cX;X]; end
% svars(2,:)=1 -> var is to be deleted
% svars(3,:)=1 -> cte is nonzero

for m=ivars,
  mlb=LMI_var(1,m);            % label of Xm
  struct=decinfo(LMIsys,mlb);  % var. struct
  [rs,cs]=size(struct);
  Xct=zeros(rs,cs);            % ct term coming from the known dec vars
  struct=struct(:);
  modif=0;                     % flag for structure modification

  for d=listdec,
    ind=find(abs(struct)==d);
    if ~isempty(ind),
       modif=1;
       Xct(ind)=decvars(d)*sign(struct(ind)).*ones(size(ind));
       struct(ind)=zeros(size(ind));
    end
  end

  if modif,    % structure of Xm is modified
    nzcte=any(any(Xct)); del=~any(struct);
    tmp=[mlb;del;nzcte];
    if nzcte, tmp=[tmp;size(Xct)';Xct(:)]; end
    svars(1:length(tmp),size(svars,2)+1)=tmp;

    if del,              % delete Xm (no free vars left in Xm)
      dvars=[dvars,m];
    else                 % update its description in LMI_var
      struct=reshape(struct,rs,cs);
      if isymm(struct), type=31; else type=32; end
%%% v4 code
%      vec(:)=struct';

%%% v5 code
      tmpstruct = struct';
      vec = tmpstruct(:);

      first=min(abs(vec(find(vec))))-1;
      last=max(abs(vec));
      LMI_var(1:6+rs*cs,m)=[mlb;type;first;last;rs;cs;vec];
    end
  end
end

% now:  dvars -> columns of LMI_var to be deleted
%       svars -> info to update variable terms A*Xm*B where Xm
%                involves some instantiated dec. vars





% (3) create list of blocks where constant term needs updating,
%     allocate corresponding space, and relocate scalar constant
%     terms
% --------------------------------------------------------------

uvars=svars(1,find(svars(3,:)));  % Xm's generating a ct term
mblck=[];                         % blocks affected
lnewd=0;

% generate list of blocks needing updating, sort by LMI
for vlb=uvars,
  % extract terms involving this variable
  mblck=[mblck,LMI_term(1:3,find(abs(LMI_term(4,:))==vlb))];
end

if ~isempty(mblck),
  [xx,perm]=sort(abs(mblck(1,:)));
  mblck=mblck(:,perm);
  % list of LMIs involved
  lmilist=abs(mblck(1,find(diff([0 abs(mblck(1,:))]))));
else
  lmilist=[];
end

creat=[]; delt=[];  % cte to be created/scalar ct to be relocated

% eliminate redundancies/get allocation requirement
for lmi=lmilist,
  lmirec=LMI_set(:,dreflmi(lmi));
  nb=lmirec(6); blckdims=lmirec(7:6+nb);
  blcks=mblck(:,find(abs(mblck(1,:))==lmi)); % all affected blocks

  lhsb=blcks(:,find(blcks(1,:)>0));
  if ~isempty(lhsb),
    [aux,perm]=sort(lhsb(2,:)+nb*lhsb(3,:));   % sort blocks
    lhsb=lhsb(:,perm(find(diff([0 aux])))); % eliminate redundancies
  end

  rhsb=blcks(:,find(blcks(1,:)<0));
  if ~isempty(rhsb),
    [aux,perm]=sort(rhsb(2,:)+nb*rhsb(3,:));   % sort blocks
    rhsb=rhsb(:,perm(find(diff([0 aux])))); % eliminate redundancies
  end

  indt=lmirec(4):lmirec(5); lmit=LMI_term(:,indt);
  for t=[lhsb,rhsb],
    l=find(lmit(1,:)==t(1) & lmit(2,:)==t(2) & lmit(3,:)==t(3) & ~lmit(4,:));
    if isempty(l),
      rs=blckdims(t(2)); cs=blckdims(t(3)); ld=2+rs*cs;
      creat=[creat,[t(1:3);0;lnewd;ld;rs;cs;0]]; %last 3=dims+value
      lnewd=lnewd+ld;
    elseif lmit(6,l)==3,   % existing scalar cte in this block
      rs=blckdims(t(2)); ld=2+rs^2;
      creat=[creat,[t(1:3);0;lnewd;ld;rs;rs;data(lmit(5,l)+3)]];
      lnewd=lnewd+ld;
      delt=[delt,indt(l)]; % col. of LMI_term to be deleted
    end
  end
end

% allocate and store new data and terms
LMI_term(:,delt)=[];   % delete relocated scalar ctes
if ~isempty(creat),
  blt=size(LMI_term,2); bdt=length(data);
  LMI_term(6,blt+size(creat,2))=0;
  data(bdt+sum(creat(6,:)))=0;
  creat(5,:)=creat(5,:)+bdt;
end

for t=creat,
  blt=blt+1; LMI_term(:,blt)=t(1:6); ld=t(7)*t(8);
  if t(9), C=diag(t(9)*ones(1,t(8))); else C=zeros(ld,1); end
  data(bdt+1:bdt+2)=t(7:8);
  data(bdt+3:bdt+2+ld)=C(:); % OK here, either sym or 0
  bdt=bdt+2+ld;
end



% (4) reset the constant terms and keep track of the
%     segments of data to be deleted
%-------------------------------------------------------------
indc=find(LMI_term(2,:) & ~LMI_term(4,:));
lmic=LMI_term(:,indc)';
deldat=[];

for v=svars,
  vlb=v(1); del=v(2); nzct=v(3);
  % extract terms involving this variable
  indv=find(abs(LMI_term(4,:))==vlb); lmitv=[];

  % deleted data
  if del,lmitv=LMI_term(:,indv);deldat=[deldat,[indv;lmitv(5:6,:)]];end

  % update constant terms
  if nzct,
    X=reshape(v(6:5+v(4)*v(5)),v(4),v(5));
    if ~del, lmitv=LMI_term(:,indv); end
  else
    lmitv=[];
  end

  for t=lmitv,
    i=t(2); j=t(3);
    [A,B,flag]=lmicoef(t,data);
    if t(4)>0, C=A*X*B; else C=A*X'*B; end
    if i==j & flag==0,  C=C+C';  end
    [rC,cC]=size(C);

    % search for a constant term in same block
    l=find(lmic(:,1)==t(1) & lmic(:,2)==i & lmic(:,3)==j);
    bdt=lmic(l,5); ldt=lmic(l,6);
    if rC==1 & cC==1, C=C*eye(data(bdt+1)); end
    data(bdt+3:bdt+ldt)=data(bdt+3:bdt+ldt)+ma2ve(C,2);

  end
end



% (5) update LMI_term and data
%-----------------------------
LMI_term(:,deldat(1,:))=[]; j=0;
% update LMI_term(5),
for t=LMI_term,
  j=j+1;
  LMI_term(5,j)=LMI_term(5,j)-sum(deldat(3,find(deldat(2,:)<t(5))));
end

%nterms=size(LMI_term,2); shft=zeros(1,nterms);
%for t=LMI_term,
%  j=j+1; shft(j)=sum(deldat(3,find(deldat(2,:)<t(5))));
%end
%LMI_term(5,:)=LMI_term(5,:)-shft;

% update data
delrg=[];
for r=deldat,
  delrg=[delrg , r(2)+1:r(2)+r(3)];
end
data(delrg)=[]; ldt=length(data);


% (6) update LMI_var and relabel the decision variables
%------------------------------------------------------

LMI_var(:,dvars)=[];

if ~isempty(LMI_var)

  % virtual array of new labels
  vlb=1:basek;
  for i=basek+1:decnbr(LMIsys),
     vlb(i)=i-length(find(listdec <= i));
  end
  vlb=vlb(:);

  ind=find(LMI_var(4,:) > basek);  % vars needing relabeling

  for j=ind,
     var=LMI_var(:,j);
     LMI_var(3,j)=vlb(var(3));
     LMI_var(4,j)=vlb(var(4));

     if var(2)>2,       % type 3
        rs=var(5); cs=var(6);
        struct=var(7:6+rs*cs);
        ind=find(abs(struct)>basek);
        tmp=struct(ind);
        tmp=sign(tmp).*vlb(abs(tmp));
        LMI_var(6+ind,j)=tmp;
     end
  end
end


% (7) update LMI_set
%-------------------


if isempty(LMI_term),
  LMI_set(4:5,:)=zeros(2,nlmis);
else
  dref=zeros(2,max(abs(LMI_set(1,:))));j=0;
  for t=LMI_term,
    j=j+1; lmi=abs(t(1));
    if ~dref(1,lmi), dref(1,lmi)=j; end
    dref(2,lmi)=j;
  end
  for j=1:nlmis,
    LMI_set(4:5,j)=dref(:,LMI_set(1,j));
  end
end

%%% end


NEWsys=lmipck(LMI_set,LMI_var,LMI_term,data);
