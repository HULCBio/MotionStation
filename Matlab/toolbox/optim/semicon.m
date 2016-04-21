function [c_all,ceq,NPOINT,NEWLAMBDA,OLDLAMBDA,LOLD,s] = semicon(x,LAMBDA,NEWLAMBDA,OLDLAMBDA,POINT,flag,s,ntheta,confcn,varargin)
%SEMICON Translation routine for semi-infinite optimization.
%       Function used by FSEMINF to make semi-infinite problems
%       look like regular constrained optimization problems.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/01/24 09:23:08 $

T = cell(1,ntheta);
switch confcn{1}
case 'fun'
    [ctmp,ceqtmp,T{:},s] = feval(confcn{3},x,s,varargin{:});
    c = ctmp(:); ceq = ceqtmp(:);
otherwise
    error('optim:semicon:UndefinedCalltypeFseminf','Undefined calltype in FSEMINF.');
end

LOLD = [];
ccnt = length(c)+1; 
cncnt = ccnt; 
NPOINT = POINT; 
if isempty(POINT)
    POINT = zeros(ntheta, 1);
    LAMBDA = zeros(ccnt-1, 1);
    NEWLAMBDA = zeros(ccnt-1, 1);
end
    
delta = []; 
if isempty(c) 
    c_all=[]; 
else 
    c_all=c(:); 
end

chg = false; 
if flag  > 0
    NEWLAMBDA = LAMBDA;
end

for i= 1:ntheta
      %  [gt,d]=eval(['findmax(t',int2str(i),',flag<0)']);
        [gt,d]=feval(@findmax, T{i}, flag<0);
% Find all the maximum points of the data
        nmax=length(gt);
% If the number of maxima is different from last time then change
% LAMBDA and OLDLAMBDA.
% Since the number of maxima is changing then we must try to
% allocate elements of LAMBDA to each of the main peaks.
        nl=POINT(i);
% If the number of maxima is different during  a gradient calculation
% then assign first 'nl' gradients to gt
    if flag > 0
        NPOINT(i,1) = nmax; 
    end
    if flag < 0
        if ~isnan(s) , s(i,:) = s(i,:).*d;    end
    end
        if nmax~=nl && flag > 0
        chg = true; 
                [dum,ind]=sort(-gt);
                indl=find(LAMBDA(ccnt:ccnt+nl-1)>0);
                if length(indl)>nmax, indl=indl(1:nmax); end
                sortl=zeros(nmax,1);
                sortl(sort(ind( (1:length(indl))' )))=LAMBDA(ccnt-1+indl);
                NEWLAMBDA=[NEWLAMBDA( (1:cncnt-1)' ); ...
                  sortl; LAMBDA( (ccnt+nl:length(LAMBDA))' )]; 
        LOLD=NEWLAMBDA;
        end
        cncnt=min(length(NEWLAMBDA)+1, cncnt+nmax);
        ccnt=ccnt+nl;
        delta=[delta;d];
        c_all=[c_all;gt];
end
if  chg || (flag > 0 && length(OLDLAMBDA) ~= length(c_all))
        %% V5 update:
        if ~isempty(OLDLAMBDA)
          OLDLAMBDA = NEWLAMBDA + max(OLDLAMBDA);
        end
end
