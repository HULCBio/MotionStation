function [x,OPTIONS,lambda,HESS]=nlconst(FUNfcn,x,OPTIONS,VLB,VUB,GRADfcn,...
                                         varargin)
%NLCONST Helper function for SIMCNSTR.
%   NLCONST is a helper function for SIMCNSTR to find the constrained minimum 
%   of a function of several variables.
%
%   [X,OPTIONS,LAMBDA,HESS]=NLCONST('FUN',X0,OPTIONS,VLB,VUB,'GRADFUN',...
%   varargin{:}) starts at X0 and finds a constrained minimum to the function 
%   which is described in FUN. FUN is a four element cell array set up by 
%   PREFCNCHK.  It contains the call to the objective/constraint function, the 
%   gradients of the objective/constraint functions, the calling type (used by 
%   OPTEVAL), and the calling function name. 

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $
%   Andy Grace 7-9-90, Mary Ann Branch 9-30-96.

%   Calls OPTEVAL.


% Expectations: GRADfcn must be [] if it does not exist.
global OPT_STOP OPT_STEP;
OPT_STEP = 1; 
OPT_STOP = 0; 
% Initialize so if OPT_STOP these have values
lambda = []; HESS = [];

% Set up parameters.
XOUT=x(:);

VLB=VLB(:); lenvlb=length(VLB);
VUB=VUB(:); lenvub=length(VUB);
bestf = Inf; 

nvars = length(XOUT);

OPTIONS(10)=1;
OPTIONS(11)=1;
CHG = 1e-7*abs(XOUT)+1e-7*ones(nvars,1);

if lenvlb*lenvlb>0
      if any(VLB( (1:lenvub)' ) > VUB), error('Bounds Infeasible'), end
end
for i=1:lenvlb
       if lenvlb>0,if XOUT(i)<VLB(i),XOUT(i)=VLB(i)+1e-4; end,end
end
for i=1:lenvub
       if lenvub>0,if XOUT(i)>VUB(i),XOUT(i)=VUB(i);CHG(i)=-CHG(i);end,end
end

% Used for semi-infinite optimization:
s = nan; POINT =[]; NEWLAMBDA =[]; LAMBDA = []; NPOINT =[]; FLAG = 2;
OLDLAMBDA = [];

sizep = length(OPTIONS);
OPTIONS = foptions(OPTIONS);
if lenvlb*lenvlb>0
      if any(VLB((1:lenvub)') > VUB), error('Bounds Infeasible'), end
end
for i=1:lenvlb
       if lenvlb>0,if XOUT(i)<VLB(i),XOUT(i)=VLB(i)+eps; end,end
end
OPTIONS(18)=1;
if OPTIONS(1)>0
   if OPTIONS(7)==1
        disp('')
        disp('f-COUNT     MAX{g}         STEP  Procedures');
   else
    disp('')
        disp('f-COUNT   FUNCTION       MAX{g}         STEP  Procedures');
   end
end
HESS=eye(nvars,nvars);
if sizep<1 |OPTIONS(14)==0, OPTIONS(14)=nvars*100;end

x(:) = XOUT;  % Set x to have user expected size
% Compute the objective function and constraints
if strcmp(FUNfcn{4},'ncdtoolbox')
  [f,g] = feval(FUNfcn{1},x,varargin{:});
else
  [f,g,msg] = opteval(x,FUNfcn,varargin{:});
  error(msg);
  g = g(:);
end
if isempty(f)
  error('FUN must return a non-empty objective function.')
end
ncstr = length(g);

GNEW=1e8*CHG;
% Evaluate gradients and check size
if isempty(GRADfcn)  
  analytic_gradient = 0;
else
  analytic_gradient = 1;
  if strcmp(FUNfcn{4},'ncdtoolbox')
     [gf_user,gg_user,OPTIONS] = feval(GRADfcn{1},x,GNEW,OPTIONS,varargin{:});
     gf_user = gf_user(:);
  else
     [gf_user,gg_user,msg] = opteval(x,GRADfcn,varargin{:});
     error(msg);            
     gf_user = gf_user(:);
  end
  % Both might evaluate to empty when expression syntax is used
  if isempty(gf_user) & isempty(gg_user) 
    analytic_gradient = 0;
  else  % Either gf or gg is defined
     if length(gf_user) ~= nvars
       error('The objective gradient is the wrong size.')
     end
     if isempty(gg_user) & isempty(g)
       % Make gg compatible
       gg = g';
     else % Check size of gg
       [ggrow, ggcol] = size(gg_user);
       if ggrow ~= nvars 
          error('The constraint gradient has the wrong number of rows.')
       end
       if ggcol ~= ncstr
          error('The constraint gradient has the wrong number of columns.')
       end
     end % isempty(gg_user)
  end % isempty(gf_user) & isempty(gg_user)
end % isempty(GRADfcn) 
 
OLDX=XOUT;
OLDG=g;
OLDgf=zeros(nvars,1);
gf=zeros(nvars,1);
OLDAN=zeros(ncstr,nvars);
LAMBDA=zeros(ncstr,1);


%---------------------------------Main Loop-----------------------------
status = 0;
first_iter=1;
while status ~= 1

%----------------GRADIENTS----------------

    if ~analytic_gradient | OPTIONS(9)
% Finite Difference gradients (even if just checking analytical)
        POINT = NPOINT; 
        oldf = f;
        oldg = g;
        ncstr = length(g);
        FLAG = 0; % For semi-infinite
        gg = zeros(nvars, ncstr);  % For semi-infinite
% Try to make the finite differences equal to 1e-8.
        CHG = -1e-8./(GNEW+eps);
        CHG = sign(CHG+eps).*min(max(abs(CHG),OPTIONS(16)),OPTIONS(17));
        OPT_STEP = 1;
        for gcnt=1:nvars
            if gcnt == nvars, 
              FLAG = -1; 
            end
            temp = XOUT(gcnt);
            XOUT(gcnt)= temp + CHG(gcnt);
            x(:) =XOUT; 
            
            if strcmp(FUNfcn{4},'ncdtoolbox')
              [f,g] = feval(FUNfcn{1},x,varargin{:});
            else
              [f,g,msg] = opteval(x,FUNfcn,varargin{:});
              error(msg);
              g = g(:);
            end
            OPT_STEP = 0;
            if OPT_STOP
               break;
            end
            % Next line used for problems with varying number of constraints
            if ncstr~=length(g), 
               diff=length(g); 
               g=v2sort(oldg,g); 
            end

            gf(gcnt,1) = (f-oldf)/CHG(gcnt);
            if ~isempty(g)
              gg(gcnt,:) = (g - oldg)'/CHG(gcnt); 
            end
            XOUT(gcnt) = temp;
            if OPT_STOP
                break;
            end
        end % for 
        if OPT_STOP
            break;
        end
          
% Gradient check
        if OPTIONS(9) == 1 & analytic_gradient
            gfFD = gf;
            ggFD = gg; 
            gg = gg_user;
            gf = gf_user;

            disp('Function derivative')
            if isa(GRADfcn{1},'inline')
              graderr(gfFD, gf, formula(GRADfcn{1}));
            else
              graderr(gfFD, gf, GRADfcn{1});
            end
            if ~isempty(gg)
              disp('Constraint derivative')
              if isa(GRADfcn{3},'inline')
                graderr(ggFD, gg, formula(GRADfcn{3}));
              else
                graderr(ggFD, gg, GRADfcn{3});
              end
            end
            OPTIONS(9) = 0;
        end % OPTIONS(9) == 1 & analytic_gradient
        FLAG = 1; % For semi-infinite
        OPTIONS(10) = OPTIONS(10) + nvars;
        f=oldf;
        g=oldg;
    else % analytic_gradient & options(9)=0
    % User-supplied gradients
        % gf and gg already computed first time through loop
        if ~first_iter
          gg = zeros(nvars, ncstr);
          if strcmp(FUNfcn{4},'ncdtoolbox')
             [gf,gg,OPTIONS] = feval(GRADfcn{1},x,GNEW,OPTIONS,varargin{:});
          else
             [gf,gg,msg] = opteval(x,GRADfcn,varargin{:});
             error(msg);
          end
          gf = gf(:);
          if isempty(gg) & isempty(g)
            gg = g';
          end
        else
          % First time through loop
          gg = gg_user;
          gf = gf_user;
          first_iter=0;
        end

        if OPT_STOP
           break;
         end
       
    end  % if ~analytic_gradient | OPTIONS(9)
    AN=gg';
    how='';
    OPT_STEP = 2;

%-------------SEARCH DIRECTION---------------

    for i=1:OPTIONS(13) 
        schg=AN(i,:)*gf;
        if schg>0
            AN(i,:)=-AN(i,:);
            g(i)=-g(i);
        end
    end

    if OPTIONS(11)>1  % Check for first call    
% For equality constraints make gradient face in 
% opposite direction to function gradient.
        if OPTIONS(7)~=5,   
            NEWLAMBDA=LAMBDA; 
        end
        [ma,na] = size(AN);
        GNEW=gf+AN'*NEWLAMBDA;
        GOLD=OLDgf+OLDAN'*LAMBDA;
        YL=GNEW-GOLD;
        sdiff=XOUT-OLDX;
% Make sure Hessian is positive definite in update.
        if YL'*sdiff<OPTIONS(18)^2*1e-3
            while YL'*sdiff<-1e-5
                [YMAX,YIND]=min(YL.*sdiff);
                YL(YIND)=YL(YIND)/2;
            end
            if YL'*sdiff < (eps*norm(HESS,'fro'));
                how=' Hessian modified twice';
                FACTOR=AN'*g - OLDAN'*OLDG;
                FACTOR=FACTOR.*(sdiff.*FACTOR>0).*(YL.*sdiff<=eps);
                WT=1e-2;
                if max(abs(FACTOR))==0; FACTOR=1e-5*sign(sdiff); end
                while YL'*sdiff < (eps*norm(HESS,'fro')) & WT < 1/eps
                    YL=YL+WT*FACTOR;
                    WT=WT*2;
                end
             else
                    how=' Hessian modified';
            end
        end

%----------Perform BFGS Update If YL'S Is Positive---------
        if YL'*sdiff>eps
            HESS=HESS+(YL*YL')/(YL'*sdiff)-(HESS*sdiff*sdiff'*HESS')/(sdiff'*HESS*sdiff);
% BFGS Update using Cholesky factorization  of Gill, Murray and Wright.
% In practice this was less robust than above method and slower.
%   R=chol(HESS); 
%   s2=R*S; y=R'\YL; 
%   W=eye(nvars,nvars)-(s2'*s2)\(s2*s2') + (y'*s2)\(y*y');
%   HESS=R'*W*R;
        else
            how=' Hessian not updated';
        end

    else % First call
          OLDLAMBDA=(eps+gf'*gf)*ones(ncstr,1)./(sum(AN'.*AN')'+eps) ;
    end % if OPTIONS(11)>1
    OPTIONS(11)=OPTIONS(11)+1;

    LOLD=LAMBDA;
    OLDAN=AN;
    OLDgf=gf;
    OLDG=g;
    OLDF=f;
    OLDX=XOUT;
    XN=zeros(nvars,1);
    if (OPTIONS(7)>0&OPTIONS(7)<5)
    % Minimax and attgoal problems have special Hessian:
        HESS(nvars,1:nvars)=zeros(1,nvars);
        HESS(1:nvars,nvars)=zeros(nvars,1);
        HESS(nvars,nvars)=1e-8*norm(HESS,'inf');
        XN(nvars)=max(g); % Make a feasible solution for qp
    end
    if lenvlb>0,
       AN=[AN;-eye(lenvlb,nvars)];
       GT=[g;-XOUT((1:lenvlb)')+VLB];
    else
       GT=g;
    end
    if lenvub>0
       AN=[AN;eye(lenvub,nvars)];
       GT=[GT;XOUT((1:lenvub)')-VUB];
    end
    [SD,lambda,howqp] = qpsub(HESS,gf,AN,-GT,[],[],XN,OPTIONS(13),-1, ...
                        'nlconst',size(AN,1),nvars,0,1);
    lambda((1:OPTIONS(13))') = abs(lambda( (1:OPTIONS(13))' ));
    ga=[abs(g( (1:OPTIONS(13))' )) ; g( (OPTIONS(13)+1:ncstr)' ) ];
    if ~isempty(g)
      mg=max(ga);
    else
      mg = 0;
    end
    
    if OPTIONS(1)>0
           if strncmp(howqp,'ok',2); howqp =''; end
           if ~isempty(how) & ~isempty(howqp) 
             how = [how,'; '];
           end
           if OPTIONS(7)==1,
              gamma = mg+f;
              disp([sprintf('%5.0f %12.6g ',OPTIONS(10),gamma), sprintf('%12.3g  ',OPTIONS(18)),how, ' ',howqp]);
           else
        disp([sprintf('%5.0f %12.6g %12.6g ',OPTIONS(10),f,mg), sprintf('%12.3g  ',OPTIONS(18)),how, ' ',howqp]);
           end
    end
    LAMBDA=lambda((1:ncstr)');
    OLDLAMBDA=max([LAMBDA';0.5*(LAMBDA+OLDLAMBDA)'])' ;

%---------------LINESEARCH--------------------
    MATX=XOUT;
    MATL = f+sum(OLDLAMBDA.*(ga>0).*ga) + 1e-30;
    infeas = strncmp(howqp,'i',1);
    if OPTIONS(7)==0 | OPTIONS(7) == 5
% This merit function looks for improvement in either the constraint
% or the objective function unless the sub-problem is infeasible in which
% case only a reduction in the maximum constraint is tolerated.
% This less "stringent" merit function has produced faster convergence in
% a large number of problems.
        if mg > 0
            MATL2 = mg;
        elseif f >=0 
            MATL2 = -1/(f+1);
        else 
            MATL2 = 0;
        end
        if ~infeas & f < 0
            MATL2 = MATL2 + f - 1;
        end
    else
% Merit function used for MINIMAX or ATTGOAL problems.
        MATL2=mg+f;
    end
    if mg < eps & f < bestf
        bestf = f;
        bestx = XOUT;
    end
    MERIT = MATL + 1;
    MERIT2 = MATL2 + 1; 
    OPTIONS(18)=2;
    while (MERIT2 > MATL2) & (MERIT > MATL) & OPTIONS(10) < OPTIONS(14) & ~OPT_STOP
        OPTIONS(18)=OPTIONS(18)/2;
        if OPTIONS(18) < 1e-4,  
            OPTIONS(18) = -OPTIONS(18); 

        % Semi-infinite may have changing sampling interval
        % so avoid too stringent check for improvement
            if OPTIONS(7) == 5, 
                OPTIONS(18) = -OPTIONS(18); 
                MATL2 = MATL2 + 10; 
            end
        end
        XOUT = MATX + OPTIONS(18)*SD;
        x(:)=XOUT; 
        if strcmp(FUNfcn{4},'ncdtoolbox')
           [f,g] = feval(FUNfcn{1},x,varargin{:});
        else
          [f,g,msg] = opteval(x,FUNfcn,varargin{:});
          error(msg);
        end
        g = g(:);
        if OPT_STOP
           break;
        end
        
        OPTIONS(10) = OPTIONS(10) + 1;
        ga=[abs(g( (1:OPTIONS(13))' )) ; g( (OPTIONS(13)+1:length(g))' )];
        if ~isempty(g)
           mg=max(ga);
        else
           mg = 0;
        end

        MERIT = f+sum(OLDLAMBDA.*(ga>0).*ga);
        if OPTIONS(7)==0 | OPTIONS(7) == 5
            if mg > 0
                MERIT2 = mg;
            elseif f >=0 
                MERIT2 = -1/(f+1);
            else 
                MERIT2 = 0;
            end
            if ~infeas & f < 0
                MERIT2 = MERIT2 + f - 1;
            end
        else
            MERIT2=mg+f;
        end
    end
%------------Finished Line Search-------------

    if OPTIONS(7)~=5
        mf=abs(OPTIONS(18));
        LAMBDA=mf*LAMBDA+(1-mf)*LOLD;
    end
    if max(abs(SD))<2*OPTIONS(2) & abs(gf'*SD)<2*OPTIONS(3) & ...
          (mg<OPTIONS(4) | (strncmp(howqp,'i',1) & mg > 0 ) )
        if OPTIONS(1)>0
                   if OPTIONS(7)==1,
                      gamma = mg+f;
                      disp([sprintf('%5.0f %12.6g ',OPTIONS(10),gamma),sprintf('%12.3g  ',OPTIONS(18)),how, ' ',howqp]);
                   else
            disp([sprintf('%5.0f %12.6g %12.6g ',OPTIONS(10),f,mg),sprintf('%12.3g  ',OPTIONS(18)),how, ' ',howqp]);
                   end
            if ~strncmp(howqp, 'i', 1) 
                disp('Optimization Converged Successfully')
                active_const = find(LAMBDA>0);
                    if active_const 
                      disp('Active Constraints:'), 
                      disp(active_const) 
                    else % active_const == 0
                      disp(' No Active Constraints');
                    end 
            end
        end
        if (strncmp(howqp, 'i',1) & mg > 0)
            disp('Warning: No feasible solution found.')
        end
        status=1;

    else
    %   NEED=[LAMBDA>0]|G>0
        if OPTIONS(10) >= OPTIONS(14) | OPT_STOP
            XOUT = MATX;
            f = OLDF;
            if ~OPT_STOP
                disp('Maximum number of function evaluations exceeded;')
                disp('increase OPTIONS(14)')
            end
            status=1;
        end
    end  
end

% If a better unconstrained solution was found earlier, use it:
if f > bestf 
    XOUT = bestx;
    f = bestf;
end
OPTIONS(8)=f;
x(:) = XOUT;
if (OPT_STOP)
    disp('Optimization terminated prematurely by user')
end


