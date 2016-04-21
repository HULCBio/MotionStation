function [GS,GSeq,GGS,GGSeq] = goalcon(V,neqgoal,funfcn,confcn,WEIGHT,GOAL,x,varargin)
%GOALCON Utility function to translate gradient in goal-attainment problem.
%   Intermediate function used to translate goal attainment
%   problem into constrained optimization problem.
%   Used by FGOALATTAIN, FMINIMAX and FMINCON (via private/NLCONST). 
%
%   See also GOALFUN.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/01/24 09:22:37 $


nx=length(V)-1;
x(:)=V(1:nx);
lambda=V(nx+1);

% Compute the constraints
f=[]; gf=[];  % Tell parser that f and g are variables.
switch funfcn{1} % evaluate function gradients
case 'fun'
   f = feval(funfcn{3},x,varargin{:});  
case 'fungrad'
   [f,gf] = feval(funfcn{3},x,varargin{:});
   
 
case 'fun_then_grad'
   f = feval(funfcn{3},x,varargin{:});  
   gf = feval(funfcn{4},x,varargin{:});

   
otherwise
   error('optim:goalcon:UndefinedCalltypeFgoalattain','Undefined calltype in FGOALATTAIN.');
end

gc = []; gceq=[]; c=[]; ceq=[];
% Evaluate constraints
switch confcn{1}
case 'fun'
   [ctmp,ceqtmp] = feval(confcn{3},x,varargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   gc = [];
   gceq = [];
case 'fungrad'
   [ctmp,ceqtmp,gc,gceq] = feval(confcn{3},x,varargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   
case 'fun_then_grad'
   [ctmp,ceqtmp] = feval(confcn{3},x,varargin{:});
   c = ctmp(:); ceq = ceqtmp(:);
   [gc,gceq] = feval(confcn{4},x,varargin{:});
  
case ''
   c=[]; ceq =[];
   gc = [];
   gceq = [];
otherwise
   error('optim:goalcon:UndefinedCalltypeFgoalattain','Undefined calltype in FGOALATTAIN.');
end



ncstr=length(WEIGHT);

% neqgoal comes from options.GoalsExactAchieve
GS = zeros(ncstr+neqgoal,1);
for i=1:ncstr
     if WEIGHT(i)~=0
       diff=f(i)-GOAL(i);
       GS(i)=sign(real(diff))*norm(diff)/WEIGHT(i)-lambda;
       if i<=neqgoal, 
          GS(i+ncstr)=-GS(i)-2*lambda; 
       end
      else
       GS(i)=f(i)-GOAL(i);
       if i<=neqgoal, 
          GS(i+ncstr)=-GS(i)-1e-10; 
       end
     end
end

GS=[c(:);GS];  % inequalities

% Equalities and gradient of equalities
GSeq = ceq(:);
GGSeq = gceq;

if isempty(gf) && isempty(gc)
   GGS=[]; GGSeq = [];
elseif (isempty(gf) && ~isempty(gc)) 
   error('optim:goalcon:GradFunRequiredForGradCon','Must provide gradient of function if gradient of constraints to be used.');
else % gf not empty, gc empty or not
   
   % Gradient of the constraints
   GL = -ones(1,ncstr+neqgoal);
   for i=1:ncstr
      if WEIGHT(i)~=0
         gf(:,i)=gf(:,i)/WEIGHT(i);
         if i<=neqgoal,
            gf(:,i+ncstr)=-gf(:,i);
         end 
      else
         GL(1,i)=0;
      end
   end
   
   GGS=[gf;GL];
   
   sizegc=size(gc);
   % Put gc first
   if sizegc(1)>0, 
      GGS=[[gc;zeros(1,sizegc(2))],GGS]; 
   end
end
