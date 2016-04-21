% lmiterm(termID,A,B,flag)
%
% Adds one term to some LMI in the LMI system currently described.
% A term is either an outer factor, a constant matrix, or a
% variable term  A*X*B  or A*X'*B  where X is a matrix variable.
%
% IMPORTANT: Because the OFF-DIAGONAL blocks (i,j) and (j,i) are
% *********  transposed of one another, specify the term content
%            of ONLY ONE of these two blocks.
%
% Input:
%  TERMID    4-entry vector specifying the term location and nature
%            Which LMI?
%		TERMID(1) = +n  ->  left-hand side of the n-th LMI
%		TERMID(1) = -n  ->  right-hand side of the n-th LMI
%            Which block?
%		For outer factors, set  TERMID(2:3) = [0 0].
%		Otherwise, set  TERMID(2:3) = [i j]  if the term
%              belongs to the (i,j) block of the LMI
%            What type of term?
%		TERMID(4) =  0  ->  constant term
%		TERMID(4) =  X  ->  variable term A*X*B
%		TERMID(4) = -X  ->  variable term A*X'*B
%                where X is the variable identifier returned by
%                LMIVAR
%  A         value of the outer factor, constant term, or left
%            coefficient in variable terms A*X*B or A*X'*B
%  B         right coefficient in variable terms A*X*B or A*X'*B
%  FLAG      quick way of specifying the expression  A*X*B+B'*X'*A'
%            in a DIAGONAL block.  Set  FLAG='s'  to specify it
%            with only one LMITERM command
%
%
% See also  SETLMIS, LMIVAR, GETLMIS, LMIEDIT, NEWLMI.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function lmiterm(termID,A,B,flag)

global GLZ_HEAD GLZ_LMIS GLZ_LMIV GLZ_LMIT GLZ_DATA

if nargin < 2,
  error('usage: lmiterm(termid,A,B,flag)');
elseif length(termID)~=4,
  error('TERMID must be a vector of length 4');
elseif nargin == 2 & termID(2)~=0 & termID(4)~=0,
  error('Both A and B must be specified for variable terms');
elseif any(size(GLZ_HEAD)~=[10 1]),
  error('Use SETLMIS to initialize the LMI system');
elseif nargin == 2,
  B=1;
end

Mv=[A(:);B(:)];
if isstr(A) | isstr(B),
   error('A and B must be matrices');
elseif any(any([imag(Mv) Mv==NaN  abs(Mv)==Inf])),
  error('Complex numbers, NaN, or Inf not allowed in A,B');
elseif isempty(GLZ_LMIV),
   error('The LMI variables are undefined');
end
Mv=[];


nlmi=GLZ_HEAD(1); nvar=GLZ_HEAD(2); nterm=GLZ_HEAD(3); ldt=GLZ_HEAD(7);
lmi=termID(1); abslmi=abs(lmi);
if lmi>0, str='lhs of '; else str='rhs of '; end
row=abs(termID(2)); col=abs(termID(3)); var=termID(4);
if row==0, col=0; var=0; end


if ~row & nargin > 2,
  error('There should be no B matrix for outer factors');
elseif ~var & nargin > 2,
  error('There should be no B matrix for constant terms');
end


% localize the specified LMI in GLZ_LMIS
% (col of GLZ_LMIS corresp. to the label "abs(lmi)"
lmirk=[];
if ~isempty(GLZ_LMIS), lmirk=find(GLZ_LMIS(1:nlmi,1)==abslmi); end
if isempty(lmirk),
   lmirk=nlmi+1; blckdims=0; outsize=0; insize=0; begt=0;
else
   outsize=GLZ_LMIS(lmirk,2); insize=GLZ_LMIS(lmirk,3);
   blckdims=GLZ_LMIS(lmirk,7:6+GLZ_LMIS(lmirk,6));
   begt=GLZ_LMIS(lmirk,4);
end
if ~begt, begt=nterm+1; end   % beginning of related terms in GLZ_LMIT


% localize the specified matrix var in GLZ_LMIV
% (varrk = col of GLZ_LMIV corresp. to the label "var")
if var,
  varrk=find(GLZ_LMIV(1,1:nvar)==abs(var));
  if row>0 & isempty(varrk),
     error('The specified matrix variable is undefined');
  end
end


% misc
if var~=0,
   vartype=GLZ_LMIV(2,varrk);
   if var<0 & (vartype==1 | vartype==31), var=-var; end
end

if row==0 | var~=0,
   if isempty(A), A=1; end,         if isempty(B), B=1; end
elseif isempty(A),
   error(sprintf('LMI #%d: empty constant term not permitted',abslmi));
end

if col>row, 	% need to reflect the request wrt the diagonal
   olrow=row; row=col; col=olrow;
   if var==0,           % cte term
      A=A';
   else                 % var. term
      AA=A';  A=B'; B=AA;             % reflected term will be B' Xk' A'
      if var<=0,
        var=-var;
      elseif (vartype~=1 & vartype~=31),  % non symmetric variable
        var=-var;
      end
   end
elseif col==row & var<0,
   AA=A';  A=B'; B=AA; var=-var; % for terms AXB+B'X'A', always store AXB
end



%%%%%%%%%%%  HANDLE OUTER FACTORS FIRST %%%%%%%%%%%%%%%


if row==0,			  % A -> outer factor

   [rA,cA]=size(A);    mpl=rA*cA;    scalarA=(mpl==1);

   if nterm>0 & lmirk <= nlmi,
     % extract the terms related to this LMI from GLZ_LMIT
     rgt=GLZ_LMIS(lmirk,4):GLZ_LMIS(lmirk,5);
     if ~isempty(rgt), lmit=GLZ_LMIT(1:2,rgt); else lmit=[0;0]; end
     if ~isempty(find(lmit(1,:)==lmi & ~lmit(2,:))),
       error(sprintf(...
         [ str 'LMI #%d: outer factor already defined'],abslmi));
     end
   end

   if mpl>1,   % full o.f.
     if insize<=0, insize=rA; end
     % outsize<0 -> scalar of previously met
     if outsize<0, outsize=insize; elseif ~outsize, outsize=cA; end
   elseif insize<=0 & outsize>0,
     insize=outsize;
   elseif outsize<=0 & insize>0,
     outsize=insize;
   elseif outsize<=0 & insize<=0,
     insize=-1; outsize=-1;
   end

%   if outsize==0,
%     insize=rA; outsize=cA;
%   elseif outsize==1 & insize==1,
%      insize=rA; outsize=rA;
%   end

   if (~scalarA & (rA~=insize | cA~=outsize)) | ...
                                      (scalarA & insize~=outsize),
       error(sprintf(...
         'LMI #%d: the outer factors have incompatible dimensions',abslmi));
   end

   % update GLZ_LMIS
   nterm=nterm+1; laux=length(blckdims); lnew=2+mpl;
   lmistore([abslmi outsize insize begt nterm laux blckdims],1,lmirk);
   GLZ_HEAD(1)=max(lmirk,nlmi);

   % update GLZ_LMIT
   lmistore([lmi;row;0;0;ldt;lnew],2,nterm);
   GLZ_HEAD(3)=nterm;

   % update GLZ_DATA
   lmistore([rA;cA;ma2ve(A,2)],3,ldt);
   GLZ_HEAD(7)=ldt+lnew;

   return

elseif max(max(abs(A)))==0 | max(max(abs(B)))==0, return, end



%%%%%%%%%%%%   HANDLE OTHER TYPES OF TERMS  %%%%%%%%%%%%%%%%%%%



% update block dimensions (GLZ_LMIS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[rA,cA]=size(A);    mpl=rA*cA;    scalarA=(mpl==1);
[rB,cB]=size(B);    mpr=rB*cB;    scalarB=(mpr==1);

laux=max(row,col);
if laux > length(blckdims), blckdims(1,laux)=0; end


% get term dimensions

if var==0,
   rT=rA; cT=cA;
else
   vadims=GLZ_LMIV(5:6,varrk);
   if var>0, rX=vadims(1);  cX=vadims(2);
   else      rX=vadims(2);  cX=vadims(1); end
   scalarX=all(vadims==[1;1]);

   if scalarA | scalarX,
      rAX=max(rA,rX);  cAX=max(cA,cX);
   elseif cA==rX,
      rAX=rA; cAX=cX;
   else
      error(sprintf(...
      [str 'LMI #%d, block (%d,%d): incompatible dimensions in A*X*B'],...
      abslmi,row,col));
   end

   if scalarB | (rAX==1 & cAX==1),
      rT=max(rAX,rB);  cT=max(cAX,cB);
   elseif cAX==rB,
      rT=rAX; cT=cB;
   else
      error(sprintf(...
      [str 'LMI #%d, block (%d,%d): incompatible dimensions in A*X*B'],...
      abslmi,row,col));
   end
end


% update blckdims

if (rT==1 & cT==1),     % scalar term added

  rb=blckdims(row);   cb=blckdims(col);
  if (rb==0 & cb==0),
    aux=min(blckdims)-1; blckdims(row)=aux; blckdims(col)=aux;
  elseif rb==0,
    blckdims(row)=cb;
  elseif cb==0,
    blckdims(col)=rb;
  elseif cb<0,
    ind=find(blckdims==cb); blckdims(ind)=rb*ones(1,length(ind));
  elseif rb<0,
    ind=find(blckdims==rb); blckdims(ind)=cb*ones(1,length(ind));
  elseif rb~=cb,
    error(sprintf([str 'LMI #%d, block (%d,%d): ' ...
      'scalar term incompatible with block dimensions'],abslmi,row,col));
  end

elseif row==col,

  if rT~=cT,
    error(sprintf([str 'LMI #%d, block (%d,%d): ' ...
          'terms in diagonal blocks must be square'],abslmi,row,col));
  end

  rb=blckdims(row);
  if rb<0,
    ind=find(blckdims==rb); blckdims(ind)=rT*ones(1,length(ind));
  elseif rb==0,
    blckdims(row)=rT;
  elseif rb~=rT,
    error(sprintf([str ...
    'LMI #%d, block (%d,%d): term dimensions incompatible with other \n' ...
    '                            terms in row #%d or column #%d'],...
    abslmi,row,col,row,col));
  end

else

  rb=blckdims(row);

  if rb<0,
    ind=find(blckdims==rb); blckdims(ind)=rT*ones(1,length(ind));
  elseif rb==0,
    blckdims(row)=rT;
  elseif rb~=rT,
    error(sprintf([str ...
    'LMI #%d, block (%d,%d): term dimensions incompatible with \n' ...
    '                            other terms in same row'],...
       abslmi,row,col));
  end

  cb=blckdims(col);

  if cb<0,
    ind=find(blckdims==cb); blckdims(ind)=cT*ones(1,length(ind));
  elseif cb==0,
    blckdims(col)=cT;
  elseif cb~=cT,
    error(sprintf([str ...
    'LMI #%d, block (%d,%d): term dimensions incompatible with \n' ...
    '                            other terms in same column'],...
       abslmi,row,col));
  end

end



%  store term description
%%%%%%%%%%%%%%%%%%%%%%%%%



if var==0,			% A -> constant coefficient

   % check symmetry in diagonal blocks
   if row==col,
     if max(max(abs(A'-A))) > 1.0e-8*max(max(abs(A))),
        error(sprintf(['LMI #%d, block (%d,%d): constant terms in ' ...
                  'diagonal blocks must be symmetric'],abslmi,row,row));
     else
        A=(A+A')/2;
     end
   end

   % search for other constant terms in the same block
   jct=[];
   if nterm>0 & lmirk<=nlmi,
      % extract the terms related to this LMI from GLZ_LMIT
      rgt=GLZ_LMIS(lmirk,4):GLZ_LMIS(lmirk,5);
      if ~isempty(rgt),
        lmit=GLZ_LMIT(1:4,rgt);
        jct=rgt(find(lmit(1,:)==lmi & lmit(2,:)==row &...
	           lmit(3,:)==col & ~lmit(4,:)));
      end
   end

   if ~isempty(jct),  % update already existing constant term
      resetct(lmirk,[],jct,A); return
   end

   newlt=[lmi;row;col;0;ldt;2+mpl];
   newdata=[rA;cA;ma2ve(A,2)];


else            % var. term:  A -> left coeff, B -> right coeff

   bool=0;

   % handle diagonal terms (symmetry check)

   if row==col,                                    % DIAG. BLOCK
      if vartype==1 | vartype==31 | scalarX,        % SYM. VAR.
        if scalarX,                 % scalar variable
           bool=isymm(A*B);
        else
           rT=max(rT,blckdims(row));
           if scalarA, AA=A*eye(rT); else AA=A; end
           if scalarB, BB=B*eye(rT); else BB=B; end
           bool=isslfcjg(AA,BB');
        end

        if bool==1 & nargin==4,
           A=2*A;                    % AXB+B'XA' stored as  2 AXA'
        elseif bool==0 & nargin~=4,
           disp(sprintf('Warning in (%d,%d) block of LMI #%d:',...
                                                         row,row,abslmi));
           disp('     Non symmetric term AXB stored as (AXB+B''XA'')/2.');
           disp('     For safety, set FLAG=''s'' to specify AXB+B''XA'' in one shot');
           A=A/2;
        end

      elseif ~scalarX & nargin~=4,                 % NONSYM VAR.
           disp(sprintf('Warning in (%d,%d) block of LMI #%d:',...
                                                         row,row,abslmi));
           disp('     Non symmetric term AXB stored as (AXB+B''X''A'')/2.');
           disp('     For safety, set FLAG=''s'' to specify AXB+B''X''A'' in one shot');
        A=A/2;
      end
   end

   newlt=[lmi;row;col;var;ldt;5+mpl+mpr];
   newdata=[rA;cA;ma2ve(A,2);rB;cB;ma2ve(B,2);bool];

end



% update GLZ_LMIS
nterm=nterm+1; laux=length(blckdims);
lmistore([abslmi outsize insize begt nterm laux blckdims],1,lmirk);
GLZ_HEAD(1)=max(lmirk,nlmi);

% update GLZ_LMIT
lmistore(newlt,2,nterm);
GLZ_HEAD(3)=nterm;

% update GLZ_DATA
lmistore(newdata,3,ldt);
GLZ_HEAD(7)=ldt+length(newdata);


% Originator: P. Gahinet (last modified: March 1995)
