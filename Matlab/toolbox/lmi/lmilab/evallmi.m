% evalsys = evallmi(lmisys,decvars)
%
% Evaluates the system of LMIs described in LMISYS
% for some particular instance DECVARS of the vector
% of decision variables. Note that DECVARS is typically
% the output of some LMI solver.
%
% Input:
%   LMISYS      array decribing the system of LMIs
%   DECVARS     vector of the decision variable values
%
% Output:
%   EVALSYS     evaluated system of LMIs
%
%
% See also  SHOWLMI, GETLMIS, LMIEDIT.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function EVALsys=evallmi(LMIsys,decvars)

if nargin ~= 2,
  error('usage: EVALsys = evallmi(LMIsys,decvars)');
elseif min(size(decvars))>1,
  error('DECVARS must be a vector');
elseif size(LMIsys,1)<10 | size(LMIsys,2)>1,
  error('LMISYS is an incomplete LMI description');
elseif any(LMIsys(1:8)<0),
  error('LMISYS is not an LMI description');
elseif length(decvars)~=decnbr(LMIsys),
  error('DECVARS does not have the proper length (see DECNBR)');
end

if isempty(decvars), EVALsys=LMIsys; return; end


[LMI_set,LMI_var,LMI_term,data]=lmiunpck(LMIsys);

if isempty(LMI_var),
  error('There is no matrix variable declared in LMISYS');
elseif isempty(LMI_term),
  error('There is no LMI term description in LMISYS');
end


% PHASE1 : evaluate all variables and store them in a single array

maxsize=max(prod(LMI_var(5:6,:)));
vtmp=zeros(maxsize+2,size(LMI_var,2));
ldec=length(decvars); j=0;

for var=LMI_var,
  j=j+1;
  klb=var(1);    % corresponding label
  lmitmp=lmipck([],var,[],[]);
  lmitmp(8)=ldec;

  X=dec2mat(lmitmp,decvars,klb);      % X = Xk
  [rX,cX]=size(X);
  vtmp(3:2+rX*cX,j)=X(:);
  vtmp(1,j)=rX; vtmp(2,j)=cX;
end



% PHASE2 : evaluate all terms LMI by LMI
% NB:      all LMIs will be single block on output

jlmi=0; jnewt=1; jnewd=0;
newt=zeros(6,2*size(LMI_set,2)+length(find(~LMI_term(2,:))));
newd=zeros(1e3,1);


for lmi=LMI_set,

  lmilb=lmi(1); insize=lmi(3); jlmi=jlmi+1;
  blckdims=lmi(7:6+lmi(6)); rangt=lmi(4):lmi(5);

  % fully determine the block sizes and inner size
  % NB: insize~=0 only if forced by outer factor
  ind=find(blckdims<=0); % undetermined block sizes
  lneg=length(ind);
  if insize<=0,          % inner size undetermined
     blckdims(ind)=ones(length(ind),1); insize=sum(blckdims);
     LMI_set(3,jlmi)=insize;
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
  if lneg, LMI_set(6+ind,jlmi)=blckdims(ind); end
  if lmi(2)>0, outsize=lmi(2); else outsize=insize; end

  % get left and right constant terms
  idx=find(abs(LMI_term(1,rangt))==lmilb);
  lmit=LMI_term(:,rangt(idx));
  [Cleft,indx1,indx2]=lmicte(lmit,data,blckdims,insize,lmilb);
  if all(size(Cleft)==[1 1]), Cleft=Cleft*eye(insize); end
  Cright=lmicte(lmit,data,blckdims,insize,-lmilb);
  if all(size(Cright)==[1 1]), Cright=Cright*eye(insize); end

  jdata=jnewd; jnewt0=jnewt; newdata=[];

  % outer factors
  lof=lmit(:,find(lmit(1,:)>0 & ~lmit(2,:)));
  if ~isempty(lof),
    newdata=[newdata;data(lof(5)+1:lof(5)+lof(6))];
    lof(5)=jdata;  jdata=jdata+lof(6);
    newt(:,jnewt)=lof;  jnewt=jnewt+1;
  end

  rof=lmit(:,find(lmit(1,:)<0 & ~lmit(2,:)));
  if ~isempty(rof),
    newdata=[newdata;data(rof(5)+1:rof(5)+rof(6))];
    rof(5)=jdata;  jdata=jdata+rof(6);
    newt(:,jnewt)=rof;  jnewt=jnewt+1;
  end


  % evaluate variable terms
  lmit=lmit(:,find(lmit(4,:)));
  for t=lmit,
    i=t(2); j=t(3); k=t(4);
    [A,B,flag]=lmicoef(t,data);
    l=find(LMI_var(1,:)==abs(k)); rX=vtmp(1,l); cX=vtmp(2,l);
    X=reshape(vtmp(3:2+rX*cX,l),rX,cX);

    if k>0, C=A*X*B; else C=A*X'*B; end
    if i==j & flag==0,  C=C+C';  end
    if all(size(C)==[1 1]), C=C*eye(blckdims(i)); end

    if t(1)>0, % lhs
      Cleft(indx1(i):indx2(i),indx1(j):indx2(j))=...
        Cleft(indx1(i):indx2(i),indx1(j):indx2(j))+C;
      if i~=j,
        Cleft(indx1(j):indx2(j),indx1(i):indx2(i))=...
          Cleft(indx1(j):indx2(j),indx1(i):indx2(i))+C';
      end
    else
      Cright(indx1(i):indx2(i),indx1(j):indx2(j))=...
        Cright(indx1(i):indx2(i),indx1(j):indx2(j))+C;
      if i~=j,
        Cright(indx1(j):indx2(j),indx1(i):indx2(i))=...
          Cright(indx1(j):indx2(j),indx1(i):indx2(i))+C';
      end
    end
  end


  % store result
  ld=insize^2+2;

  if any(any(Cleft)),
    newdata=[newdata;insize;insize;ma2ve(Cleft,2)];
    newt(:,jnewt)=[lmilb;1;1;0;jdata;ld];
    jdata=jdata+ld; jnewt=jnewt+1;
  end

  if any(any(Cright)),
    newdata=[newdata;insize;insize;ma2ve(Cright,2)];
    newt(:,jnewt)=[-lmilb;1;1;0;jdata;ld];
    jdata=jdata+ld; jnewt=jnewt+1;
  end

  dim=length(newd);
  if jdata >= dim,
    news=jdata+min(1e6,5*jdata);
    newd(news,1)=0;
  end
  newd(jnewd+1:jdata)=newdata; jnewd=jdata;


  % update lmis
  LMI_set(1:6+lmi(6),jlmi)=...
      [lmilb;outsize;insize;jnewt0;jnewt-1;1;insize;zeros(lmi(6)-1,1)];

end




newt(:,jnewt:size(newt,2))=[];
newd(jnewd+1:length(newd))=[];
EVALsys=lmipck(LMI_set,[],newt,newd);
