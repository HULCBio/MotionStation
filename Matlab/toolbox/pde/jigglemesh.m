function p=jigglemesh(p,e,t,p1,v1,p2,v2)
%JIGGLEMESH Jiggle internal points of a triangular mesh.
%
%       P1=JIGGLEMESH(P,E,T) jiggles the triangular mesh by adjusting
%       the node point positions. The quality of the mesh normally
%       increases.
%
%       See PDETRIQ for more info on triangle quality.
%
%       The following Property/Value pairs are allowed:
%
%       Property    Value/{Default}           Description
%       ------------------------------------------------------------
%       Opt         {off}|mean|min            Optimization method
%       Iter        1 or 20 (see below)       Maximum number of iterations
%
%       Each mesh point that is not located on a mesh boundary is
%       moved toward the center of mass of the polygon formed by the
%       adjacent triangles. This process is repeated according to the
%       setting of the Opt and Iter variables:
%       - When Opt is set to off this process is repeated Iter times
%       (default: once).
%       - When Opt is set to mean the process is repeated until the
%       mean triangle quality does not significantly increase, or until
%       the bound Iter is reached (default: 20).
%       - When Opt is set to min the process is repeated until the
%       minimum triangle quality does not significantly increase, or until
%       the bound Iter is reached (default: 20).
%
%       See also INITMESH, PDETRIQ

%       L. Langemyr 12-29-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:27:57 $

% Analyze input arguments

% Error checks
nargs = nargin;
if rem(nargs+3,2)
   error('PDE:jigglemesh:NoParamPairs','Param value pairs expected.')
end

% Default values
Opt='off';
Iter=-1;

for i=4:2:nargs,
  Param = eval(['p' int2str((i-4)/2 +1)]);
  Value = eval(['v' int2str((i-4)/2 +1)]);
  if ~ischar(Param),
    error('PDE:jigglemesh:ParamNotString', 'Parameter must be a string.')
  elseif size(Param,1)~=1,
    error('PDE:jigglemesh:ParamEmptyOrNot1row', 'Parameter must be a non-empty single row string.')
  end
  Param = lower(Param);
  if strcmp(Param,'opt')
    Opt=lower(Value);
    if ~ischar(Opt)
      error('PDE:jigglemesh:OptNotString', 'Opt must be a string.')
    elseif ~strcmp(Opt,'off') && ~strcmp(Opt,'minimum') && ~strcmp(Opt,'mean')
      error('PDE:jigglemesh:OptInvalidString', 'Opt must be off | minimum | {mean}.')
    end
  elseif strcmp(Param,'iter')
    Iter=Value;
    if ischar(Iter)
      error('PDE:jigglemesh:IterString', 'Iter must not be a string.')
    elseif ~all(size(Iter)==[1 1])
      error('PDE:jigglemesh:IterNotScalar', 'Iter must be a scalar.')
    elseif imag(Iter)
      error('PDE:jigglemesh:IterComplex', 'Iter must not be complex.')
    elseif Iter<-1
      error('PDE:jigglemesh:IterNeg', 'Iter must be non negative.')
    end
  else
    error('PDE:jigglemesh:InvalidParam', ['Unknown parameter: ' Param])
  end
end

if Iter==-1 && strcmp(Opt,'off')
  Iter=1;
elseif Iter==-1
  Iter=20;
end

% Determine interior non boundary points
ep=sort([e(1,:) e(2,:)]);
i=ones(1,size(p,2));
j=ep(find([1 sign(diff(ep))]));
i(j)=zeros(size(j));
i=find(i);

np=size(p,2);
nt=size(t,2);

if ~strcmp(Opt,'off')
  q=pdetriq(p,t);
  if strcmp(Opt,'minimum')
    q=min(q);
  else
    q=mean(q);
  end
end

j=1;
while j<=Iter
  X=sparse(t([1 2 3],:),t([2 3 1],:),p(1,t(1:3,:)),np,np);
  Y=sparse(t([1 2 3],:),t([2 3 1],:),p(2,t(1:3,:)),np,np);
  N=sparse(t([1 2 3],:),t([2 3 1],:),1,np,np);
  m=sum(N);
  X=sum(X)./m;
  Y=sum(Y)./m;
  p1=p;
  p(1,i)=X(i);
  p(2,i)=Y(i);
  if ~strcmp(Opt,'off')
    q1=q;
    q=pdetriq(p,t);
    if strcmp(Opt,'minimum')
      q=min(q);
    elseif strcmp(Opt,'mean')
      q=mean(q);
    end
    if q<q1
      p=p1;
      break,
    elseif q1+1e-4>q
      break
    end
  end
  j=j+1;
end

