function [x,val,csnrm,it,npcg,exitflag,LAMBDA,msg]=sqpbox(c,H,l,u,xstart,typx,verb,...
   pcmtx,pcflags,mtxmpy,tolx,tolfun,pcgtol,itb,showstat,computeLambda,kmax,varargin)
%SQPBOX Minimize box-constrained quadratic fcn
%
%   [x,val,csnrm,it,npcg,exitflag]=sqpbox(c,H,l,u,xstart,typx,verb,...
%                   pcmtx,pcflags,mtxmpy,tol,itb,showstat)
%
%   Locate a (local) soln
%   to the box-constrained QP:
%
%        min { q(x) = .5x'Hx + c'x :  l <= x <= u}. 
%
%   where H is sparse symmetric, c is a col vector,
%   l,u are vectors of lower and upper bounds respectively.
% Driver function is SQPMIN

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.4 $  $Date: 2004/03/18 17:59:54 $

%   INITIALIZATIONS
if nargin <= 1
   error('optim:sqpbox:NotEnoughInputs','sqpbox requires at least 2 arguments.')
end
n = length(c); 
it = 0; 
cvec = c; 
nbnds = 1;
header = sprintf(['\n                                Norm of      First-order \n',...
      ' Iteration        f(x)          step          optimality   CG-iterations']);
formatstr = ' %5.0f      %13.6g  %13.6g   %12.3g     %7.0f';

if n == 0
   error('optim:sqpbox:InvalidN','n must be positive.')
end
if nargin <= 2
   l = -inf*ones(n,1);
end
if nargin <= 3, 
   u = inf*ones(n,1); 
end
if isempty(l),
   l = -inf*ones(n,1); 
end 
if isempty(u),
   u = inf*ones(n,1);
end
arg = (u >= 1e10); 
arg2 = (l <= -1e10);
u(arg) = inf;
l(arg2) = -inf;
if min(u-l) <= 0 
   error('optim:sqpbox:InconsistentBnds','Inconsistent bounds.')
end
lvec = l; uvec = u; 
if nargin <= 4, 
   xstart = startx(u,l);
end
if min(min(u-xstart),min(xstart-l)) < 0, 
   xstart = startx(u,l);
end
if nargin <=5, 
   typx = ones(n,1);
end
if isempty(typx), 
   typx = ones(n,1);
end
if nargin <=6, 
   verb = 0; 
end
if isempty(verb), 
   verb = 0; 
end
if nargin <= 7, 
   pcmtx = @hprecon; 
end
if isempty(pcmtx), 
   pcmtx = @hprecon;
end
if nargin <= 8, 
   pcflags = [0;0]; 
end
if isempty(pcflags), 
   pcflags = [0;0]; 
end
if nargin <= 9 | isempty(mtxmpy), 
   mtxmpy = @hmult;
end
if nargin <= 10, 
   tolx = 100*eps; 
end
if nargin <= 11
   tolfun = 100*eps;
end
if isempty(tolx), 
   tolx = (10^2)*eps; 
end
if isempty(tolfun)
   tolfun = 100*eps;
end
if nargin <=12, 
   itb = 200; 
end
if isempty(itb), 
   itb = 200 ; 
end  
if nargin <=13, 
   showstat = 0; 
end
if isempty(showstat), 
   showstat = 0 ; 
end

pcgit = 0;
tolx2 = sqrt(tolx); 
tolfun2 = sqrt(tolfun);
vpcg(1,1) = 0; 
vpos(1,1) = 1;
[xstart,l,u,ds,DS,c] = shiftsc(xstart,l,u,typx,'sqpbox',mtxmpy,cvec,H,varargin{:});
dellow = 1.; 
delup = 10^3; 
npcg = 0; 
digits = inf; 
done = false;
v = zeros(n,1);
dv = ones(n,1);
del = 10*eps;
posdef = 1;
x = xstart; 
y = x;
sigma = ones(n,1);
g = zeros(n,1);
oval = inf; 
prev_diff = 0;
[val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:}); 
[v,dv] = definev(g,x,l,u); 
csnrm = norm(v.*g,inf); 
if csnrm == 0
   % If initial point is a 1st order point then randomly perturb the
   % initial point a little while keeping it feasible and reinitialize.
   dir = zeros(n,1);
   pos = u-x > x-l;
   neg = u-x <= x-l;
   dir(pos) = 1; dir(neg) = -1;
   randstate = rand('state'); 
   x = x + dir.*rand(n,1).*max(u-x,x-l).*1e-1;
   rand('state',randstate);
   y = x;
   [val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:});
end

if ((u == inf*ones(n,1)) & (l == -inf*ones(n,1))) 
   nbnds = 0; 
end
if showstat > 1, 
   figtr = display1('init',itb,tolfun,showstat,nbnds,x,g,l,u); 
end
%
%   MAIN LOOP: GENERATE FEAS. SEQ.  x(it) S.T. q(x(it)) IS DECREASING.
while ~done
   it = it + 1;
   vval(it,1) = val;
   %
   %     terminate?
   figtr = findobj('type','figure','Name','Progress Information') ;
   if ~isempty(figtr)
      lsotframe = findobj(figtr,'type','uicontrol',...
         'Userdata','LSOT frame') ;
      if get(lsotframe,'Value'), 
         exitflag = -1; % New exiting condition  
      end ;
   end ;
   %
   %     Update and display
   [v,dv] = definev(g,x,l,u); 
   csnrm = norm(v.*g,inf); 
   vcsnrm(it,1) = csnrm;
   r = abs(min(u-x,x-l));
   degen = min(r + abs(g));
   vdeg(it,1) = min(degen,1);
   if ((u == inf*ones(n,1)) & (l == -inf*ones(n,1))) 
      degen = -1; 
   end
   bndfeas = min(min(x-l,u-x));
   if showstat > 1
      display1('progress',it,csnrm,val,pcgit,npcg,degen,...
         bndfeas,showstat,nbnds,x,g,l,u,figtr);
   end
   %
   %     TEST FOR CONVERGENCE
   diff = abs(oval-val); 
   vdiff(it,1) = diff/(1+abs(oval));
   if it > 1, 
      digits = (prev_diff)/max(diff,eps); 
   end
   prev_diff = diff; 
   oval = val; 
   if diff < tolfun*(1+abs(oval)),
      exitflag = 3; done = true;
      msg = sprintf(['Optimization terminated: relative function value changing by\n' ...
                     ' less than OPTIONS.TolFun.']);
      if verb > 0
         disp(msg)
      end      
   elseif ((diff < tolfun2*(1+abs(oval))) & (digits < 3.5)) & posdef, 
      exitflag = 3; done = true;
      msg = sprintf(['Optimization terminated: relative function value changing by less\n' ... 
                     ' than sqrt(OPTIONS.TolFun), no negative curvature detected in current\n' ...
                     ' trust region model and the rate of progress (change in f(x)) is slow.']);
      if verb > 0
         disp(msg)
      end
   elseif ((csnrm < tolfun) & posdef & it > 1), 
      exitflag = 1; done = true;
      msg = sprintf(['Optimization terminated: no negative curvature detected in current\n' ...
                     ' trust region model and first order optimality measure < OPTIONS.TolFun.']);
      if verb > 0
         disp(msg)
      end
   end
   %
   if ~done 
      %       DETERMINE THE SEARCH DIRECTION
      dd = abs(v); 
      D = sparse(1:n,1:n,full(sqrt(dd).*sigma));
      grad = D*g; 
      normg = norm(grad);

      delta = max(dellow,norm(v)); 
      delta = min(delta,delup); 
      vdelta(it,1) = delta;

      [s,posdef,pcgit] = drqpbox(D,DS,grad,delta,g,dv,mtxmpy,...
         pcmtx,pcflags,pcgtol,H,0,kmax,varargin{:});

      npcg = npcg + pcgit; 
      vpos(it+1,1) = posdef; 
      vpcg(it+1,1) = pcgit;
      %
      %       DO A REFLECTIVE (BISECTION) LINE SEARCH. UPDATE x,y,sigma.
      strg= s'*(sigma.*g); 
      ox = x; 
      osig = sigma; 
      ostrg = strg;
      if strg >= 0,
         exitflag = -2; done = true;
         msg = sprintf(['Optimization terminated: loss of feasibility with respect to the\n' ...
                        ' constraints detected.']);
         if verb > 0
            disp(msg);
         end
      else
         [x,sigma,alpha] = biqpbox(s,c,ostrg,ox,y,osig,l,u,oval,posdef,...
            normg,DS,mtxmpy,H,0,varargin{:});
         if alpha == 0, 
            exitflag = -4; done = true;
            msg = sprintf(['Optimization terminated: current direction not descent direction;\n' ...
                           ' the problem may be ill-conditioned.']);
            if verb > 0
               disp(msg)
            end
            
         end
         y = y + alpha*s; 
         %
         %          PERTURB x AND y ?
         [pert,x,y] = perturb(x,l,u,del,y,sigma);
         %
         %          EVALUATE NEW FUNCTION VALUE, GRADIENT. 
         [val,g] = fquad(x,c,H,'sqpbox',mtxmpy,DS,varargin{:}); 
      end
      if it >= itb, 
         exitflag = 0; done = true;
         msg = sprintf('Maximum number of iterations exceeded; increase options.MaxIter');
         if verb > 0
            disp(msg)
         end              
      end
   end
end
%
%   RESCALE, UNSHIFT, AND EXIT.
x = unshsca(x,lvec,uvec,DS);
% unscaled so leave out DS
[val,g] = fquad(x,cvec,H,'sqpbox',mtxmpy,[],varargin{:}); 
if showstat > 1,
   display1('final',figtr);
end
if showstat>0, 
   xplot(it,vval,vcsnrm,vpos,vdeg,vpcg); 
end

if computeLambda
 LAMBDA.lower = zeros(length(lvec),1);
 LAMBDA.upper = zeros(length(uvec),1);
 active_tol = sqrt(eps);
 argl = logical(abs(x-lvec) < active_tol);
 argu = logical(abs(x-uvec) < active_tol);

 g = full(g);
 LAMBDA.lower(argl) = abs(g(argl));
 LAMBDA.upper(argu) = -abs(g(argu));
else
  LAMBDA=[];
end
