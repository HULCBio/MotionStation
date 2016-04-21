%  function [izs,dzs]=nnsetup(lmisys)
%
%  Converts LMI data from MATLAB representation to the
%  representation used in Nesterov/Nemirovskii's solvers
%
%  Input:
%
%   LMI_SET     integer array specifying the dimensions and structure
%	        of each LMI
%   LMI_VAR     integer array describing the VARIABLE matrices
%	        X1,...,Xn
%   LMI_TERM    array containing the coefficients of all the terms
%	        in the LMI set
%
%  Output:
%   IZS,DZS     input to Nesterov/Nemirovsky's solvers
%
%

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function [izs,dzs]=nnsetup(lmisys)

[LMI_set,LMI_var,LMI_term,data]=lmiunpck(lmisys);

ldt=lmisys(7);  % length of data segment

NLMI=size(LMI_set,2); NV=size(LMI_var,2);

%%% v5 code
nentries = [];
skipped = [];



% preallocation (warning: extra 0 cell upfront)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IZS:

izs=zeros(7+NLMI+6*NV,1);

% DZS:

lcte=1; izsplus=0; j=0;
for lmi=LMI_set,
  lmilb=lmi(1); insize=lmi(3); j=j+1;
  blckdims=lmi(7:6+lmi(6)); rangt=lmi(4):lmi(5);

  % fully determine the block sizes and inner size
  % NB: insize>0 only when forced by outer factor
  ind=find(blckdims<=0); % undetermined block sizes
  lneg=length(ind);
  if insize<=0,          % inner size undetermined
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
  if lmi(2)<=0, LMI_set(2,j)=insize; end  % set outsize if undetermined

  ctsize=insize*(insize+1)/2-1;
  lmit2=LMI_term([1 4],rangt);
  lmit1=lmit2(2,find(lmit2(1,:)==lmilb));   % lhs terms
  lmit2=lmit2(2,find(lmit2(1,:)==-lmilb));  % rhs terms
  lcte=lcte+2+ctsize*((~all(lmit1))+(~all(lmit2)));
  izsplus=izsplus+16+2*lmi(6)+12*...
          (length(find(lmit1))+length(find(lmit2)));    % # var. terms
end


dzs=zeros(lcte+ldt-2*size(LMI_term,2),1);

%disp(sprintf('guessed length of DZS: %d',lcte+ldt-2*size(LMI_term,2)))



% fill IZS array
%%%%%%%%%%%%%%%%

izs(4)=max(LMI_var(4,:));
izs(5)=NV; izs(6)=NLMI;

ilast=6+3*NV+NLMI; % current base for 1st available cell
dlast=0;

% VARIABLE description: for j=1:NV,

j=0;

for var=LMI_var,

  j=j+1; j3=3*j; vtype=var(2);

  % fill r+1 .. r+3
  if all(var(5:6)==[1;1]),     % scalar variable
     izs(j3+(4:6))=[0;0;ilast];
     if vtype > 30,
        vtype=1;
        var(7:9)=[1;1;0];
     end
  else
     izs(j3+(4:6))=[var(5:6);ilast];
  end

  % additional var info

  if vtype > 30,              % special VAR

	izs(2+ilast)=-2;
	coldim=var(6); struct=var(7:6+var(5)*coldim);
	nonzero=find(struct~=0);
	izs(3+ilast)=length(nonzero);
	ilast=ilast+3;     izs(1+ilast)=0;
        % no global base used, each dec. var. is
        % indexed directly by #3 in triple

	for t=nonzero',
           it=floor(t/coldim);  jt=t-coldim*it;
           if jt==0,
	     izs(2+ilast)=it;   izs(3+ilast)=coldim;
           else
	     izs(2+ilast)=it+1;   izs(3+ilast)=jt;
           end
	   ilast=ilast+3; izs(1+ilast)=struct(t);
	end

  elseif vtype==2,	% full rect.

	izs(2+ilast)=2;
	izs(3+ilast)=var(5)*var(6);
	ilast=ilast+3; izs(1+ilast)=var(3);

  else			% block diag

	nblocks=var(7);

	if nblocks==1,	% symm, one block
           if var(9),             % full block
	      izs(2+ilast)=1;
	      izs(3+ilast)=var(5)*var(6);
           else                   % scalar block
	      izs(2+ilast)=0;
	      izs(3+ilast)=var(5);
           end
	   ilast=ilast+3; izs(1+ilast)=var(3);
	else
	   izs(2+ilast)=-2;
	   skipped=2+ilast;
	   ilast=ilast+3; izs(1+ilast)=var(3);
	   rowbase=0; colbase=0; varindx=0; nentries=0;

	   for k=1:nblocks,
	      b_size=var(6+2*k);
	      if var(7+2*k)==1,	      % full block

		nentries=nentries+b_size^2;
  		for i1=1:b_size, for j1=1:i1;
		   izs(2+ilast)=rowbase+i1;
		   izs(3+ilast)=colbase+j1;
		   ilast=ilast+3; varindx=varindx+1;
		   izs(1+ilast)=varindx;
		   if i1>j1,
		   	izs(2+ilast)=colbase+j1;
		   	izs(3+ilast)=rowbase+i1;
		   	ilast=ilast+3; izs(1+ilast)=varindx;
		   end
		end,end

	      elseif var(7+2*k)==0,    % scalar block

		varindx=varindx+1; nentries=nentries+b_size;
  		for i1=1:b_size,
		   r1=rowbase+i1;
		   izs(2+ilast)=r1; izs(3+ilast)=r1;
		   ilast=ilast+3; izs(1+ilast)=varindx;
		end

	      end

	      rowbase=rowbase+b_size;	 colbase=colbase+b_size;

	   end 		%for

	end	%if

	izs(1+skipped)=nentries;

  end

end

% END VAR description



%%%%%%%%%%%%%%%%%%%%%%%%%
% LMI description STARTS
%%%%%%%%%%%%%%%%%%%%%%%%%

% reallocate space for IZS
izs(length(izs)+izsplus)=0;
shift=5+3*NV; free_entries=0; j=0;


%disp(sprintf('guessed length of IZS: %d',length(izs)))

%for j=1:NLMI,

for lmi=LMI_set,

  j=j+1; jlb=lmi(1);      % label of this LMI as known in LMI_term
  rangt=lmi(4):lmi(5);

  lmit=LMI_term(:,rangt);
  lmit=lmit(:,find(abs(lmit(1,:))==jlb));

  lhscte=0; rhscte=0;
  nblocks=lmi(6); blckdims=lmi(7:6+nblocks);
  insize=lmi(3);  outsize=lmi(2);


  izs(1+shift+j)=ilast;
  izs(2+ilast)=nblocks;
  izs(3+ilast)=insize;
  newent=round(outsize*(1+outsize)/2);
  izs(4+ilast)=newent;
  izs(5+ilast)=free_entries;    free_entries=free_entries+newent;

  % lhs constant term

  izs(6+ilast)=dlast;
  C=lmicte(lmit,data,blckdims,insize,jlb);

  if max(max(abs(C)))==0, 	% C = 0
     izs(7+ilast)=1; dzs(dlast+2)=0;  dlast=dlast+1;
  else
     lC=size(C,1); lC=lC*(lC+1)/2;
     izs(7+ilast)=2;   dzs(dlast+2:dlast+1+lC)=ma2ve(C,1);
     dlast=dlast+lC;   lhscte=1;
  end

  % rhs constant term

  izs(8+ilast)=dlast;
  C=lmicte(lmit,data,blckdims,insize,-jlb);

  if max(max(abs(C)))==0, 	% C = 0
     izs(9+ilast)=-1;  dzs(dlast+2)=0;  dlast=dlast+1;
  else
     lC=size(C,1); lC=lC*(lC+1)/2;
     izs(9+ilast)=-2;  dzs(dlast+2:dlast+1+lC)=ma2ve(C,1);
     dlast=dlast+lC;   rhscte=1;
  end

  %

  ilast=ilast+9; skip1=ilast; skip2=ilast+1;
  nlhsc=0; nrhsc=0; nrows=0;	% total number of lhs and rhs coefficients

  for i=1:nblocks,
    newrows=blckdims(i);
    izs(1+ilast+2*i)=newrows;
    izs(2+ilast+2*i)=nrows; nrows=nrows+newrows;
  end

  ilast=ilast+1+2*nblocks;



  % VARIABLE TERMS: STORE LMI COEFFICIENTS

  % rk(m+l*(l-1)/2,k) counts the number of terms involving
  % Xk in the block (l,m) of the LMI
  rk=zeros(nblocks*(nblocks+1)/2,size(LMI_var,2));

  for t=lmit(:,find(lmit(4,:))),  % all var. terms in this LMI

     l=t(2);  m=t(3);  % the term t belongs block (l,m), l >= m
     signt=sign(t(1)); % side of the LMI

     % get rank of the variable in t among the NV vars
     nvar=t(4);
     nvar=sign(nvar)*find(LMI_var(1,:)==abs(nvar));
     npair=rk(m+l*(l-1)/2,abs(nvar))+1;  % increment the rk counter
     rk(m+l*(l-1)/2,abs(nvar))=npair;


     % A -> left coeff of block l,m and B -> left coeff of block m,l

     izs(ilast+2)=nvar; 	izs(ilast+8)=-nvar;
     izs(ilast+3)=npair;	izs(ilast+9)=npair;
     izs(ilast+4)=l; 	izs(ilast+5)=m;
     izs(ilast+10)=m; 	izs(ilast+11)=l;

     if all(LMI_var(5:6,abs(nvar))==[1;1]),  % SCALAR VARIABLE

        [A,B,flag]=nncoeff(t,data,1);
        % return A*B for terms A*x*B

        % the left coeff is declared to be A, the right I
        if length(A)==1, izs(ilast+6)=signt; else izs(ilast+6)=signt*2; end
        izs(ilast+12)=signt;             % B = I

	lA=length(A);
        vartype=LMI_var(2,abs(nvar));

% modif 11/93	  if l==m & (vartype==1 | vartype==31) & flag==1,
% to account for scalar vars of type 2

	if l==m & flag==1,  % selfconjugated diagonal terms  t.A X A'

	   izs(ilast+7)=dlast;	dzs(dlast+2:dlast+1+lA)=A/2;
	   dlast=dlast+lA;
	   izs(ilast+13)=dlast; dlast=dlast+1; dzs(dlast+1)=1;
	else
	   izs(ilast+7)=dlast;	dzs(dlast+2:dlast+1+lA)=A;
	   dlast=dlast+lA;
	   izs(ilast+13)=dlast; dlast=dlast+1; dzs(dlast+1)=1;
	end


      else                  % NON SCALAR VARIABLE TERM  A*X*B

	[A,B,flag]=nncoeff(t,data,0); % returns A and B'

	lA=length(A);	lB=length(B);
	if lA==1, izs(ilast+6)=signt; else izs(ilast+6)=signt*2; end
	if lB==1, izs(ilast+12)=signt;else izs(ilast+12)=signt*2;end

        vartype=LMI_var(2,abs(nvar));

	if l==m & (vartype==1 | vartype==31) & flag==1,
			% selfconjugated diagonal terms  t.A X A'

	   izs(ilast+7)=dlast;	    dzs(dlast+2:dlast+1+lA)=A/2;
	   dlast=dlast+lA;
	   izs(ilast+13)=dlast;	    dzs(dlast+2:dlast+1+lB)=B;
	   dlast=dlast+lB;

	else

	   izs(ilast+7)=dlast;	    dzs(dlast+2:dlast+1+lA)=A;
	   dlast=dlast+lA;
	   izs(ilast+13)=dlast;	    dzs(dlast+2:dlast+1+lB)=B;
	   dlast=dlast+lB;

	  end
        end

      if t(1)>0, nlhsc=nlhsc+2; else nrhsc=nrhsc+2; end
      ilast=ilast+12;

  end %END for t=lmit(find..


  izs(1+skip1)=nlhsc; 	izs(1+skip2)=nrhsc;


  % description OUTER FACTORS

  izs(ilast+2)=outsize;		izs(ilast+5)=outsize;


  % LHS outer factor
  lhsoutf=lmit(:,find(lmit(1,:)==jlb & lmit(2,:)==0));

  if isempty(lhsoutf),		% NL unspecified
    if lhscte==0 & nlhsc==0,	% LMI's LHS = 0
	izs(ilast+3)=0;    izs(ilast+4)=dlast;
	dlast=dlast+1; 	   dzs(dlast+1)=0;
    elseif insize==outsize,     % NL = Identity
	izs(ilast+3)=1;    izs(ilast+4)=dlast;
	dlast=dlast+1; 	   dzs(dlast+1)=1;
    else			% NL rect. + nonzero LHS
	error(sprintf(...
        'LMI #%d: nonsquare l.h.s. outer factor is missing',jlb));
    end
  else
    N=nncoeff(lhsoutf,data,2); % returns N' in ma2ve form
    lN=length(N);
    if lN==1, izs(ilast+3)=1; else izs(ilast+3)=2; end
    izs(ilast+4)=dlast;
    dzs(dlast+2:dlast+1+lN)=N;
    dlast=dlast+lN;
  end



  % RHS outer factor
  rhsoutf=lmit(:,find(lmit(1,:)==-jlb & lmit(2,:)==0));

  if isempty(rhsoutf),		% NR unspecified
    if rhscte==0 & nrhsc==0,	% LMI's RHS = 0
	izs(ilast+6)=0;	   izs(ilast+7)=dlast;
	dlast=dlast+1; 	   dzs(dlast+1)=0;
    elseif insize==outsize,	% NR = Identity
	izs(ilast+6)=1;    izs(ilast+7)=dlast;
	dlast=dlast+1; 	   dzs(dlast+1)=1;
    else			% NR rect. + nonzero RHS
	error(sprintf(...
        'LMI #%d: nonsquare r.h.s. outer factor is missing',jlb));
    end
  else
    N=nncoeff(rhsoutf,data,2);
    lN=length(N);
    if lN==1, izs(ilast+6)=1; else izs(ilast+6)=2; end
    izs(ilast+7)=dlast;
    dzs(dlast+2:dlast+1+lN)=N;
    dlast=dlast+lN;
  end

  ilast=ilast+6;


end


izs(7+3*NV+NLMI)=ilast;
izs(2)=ilast;
izs(3)=dlast;

dzs(dlast+2:length(dzs))=[];

%disp(sprintf('true lengths of DZS,IZS: %d  %d',length(dzs),length(izs)))
