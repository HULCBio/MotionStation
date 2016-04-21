function [X,FVAL,EXITFLAG,OUTPUT] = pfminlcon(FUN,initialX,Aineq,Bineq,Aeq,Beq,LB,UB,options)
%PFMINLCON Finds a linearly constrained minimum of a function.
%   PFMINLCON solves problems of the form:
%           min F(X)    subject to:      A*x <= b
%            X                          Aeq*x = beq
%                                      LB <= X <= UB 
%          
%   X = PFMINLCON(FUN,X0) starts at X0 and finds a local minimum X to the
%   function FUN. FUN accepts input X and returns a scalar function value 
%   F evaluated at X. X0 may be a scalar or vector.
%
%   X = PFMINLCON(FUN,X0,A,b) starts at X0 and finds a local minimum X to the
%   function FUN, subject to  A*x <= b. If A is a matrix of size M X N then M is the 
%   number of linear inequality constraints and N is the number of variables. b should a 
%   column vector of length M.
%
%   X = PFMINLCON(FUN,X0,A,b,Aeq,beq) starts at X0 and finds a local minimum X to the
%   function FUN, subject to  A*x <= b and  Aeq*x = beq. If Aeq is a matrix of size M X N 
%   then M is the number of linear equality constraints and N is the number of variables. 
%   beq should a column vector of length M. If there are no inequality constraints, pass 
%   empty matrices for A and b.
%
%   X = PFMINLCON(FUN,X0,A,b,Aeq,beq,LB,UB) starts at X0 and finds a local minimum X to the
%   function FUN, subject to  A*x <= b, Aeq*x = beq and LB <= X <= UB.If LB (or UB) is empty 
%   (or not provided) it is automatically expanded to -Inf (or Inf). If there are no inequality 
%   and/or eqality constraints, pass empty matrices for A, b, Aeq and beq.
%
%   X = PFMINLCON(FUN,X0,A,b,Aeq,beq,LB,UB,options) minimizes with the default optimization 
%   parameters replaced by values in the structure OPTIONS. OPTIONS can be created 
%   with the PSOPTIMSET function.
%
%   [X,FVAL] = PFMINLCON(FUN,X0,...) returns the value of the objective function FUN 
%   at the solution X.
%
%   [X,FVAL,EXITFLAG] = PFMINLCON(FUN,X0,...) returns a string EXITFLAG that 
%   describes the exit condition of PFMINLCON.  
%     If EXITFLAG is:
%        > 0 then PFMINLCON converged to a solution X.
%        = 0 then the algorithm reached the maximum number of iterations or maximum number of function evaluations.
%        < 0 then PFMINLCON did not converge to a solution.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = PFMINLCON(FUN,X0,...) returns a structure
%   OUTPUT with the following information:
%          function: <Objective function>
%       problemtype: <Type of problem> (Unconstrained, Bound constrained or linear constrained)
%        pollmethod: <Polling technique>
%      searchmethod: <Search technique> used, if any
%        iterations: <Total iterations>
%         funcCount: <Total function evaluations>
%          meshsize: <Mesh size at X>


%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.21.6.2 $  $Date: 2004/03/09 16:15:54 $

defaultopt = psoptimset;   

%If FUN is a cell array with additional arguments, handle them
if iscell(FUN)
    objFcnArg = FUN(2:end);
    FUN = FUN{1};
else
    objFcnArg = {};
    FUN = FUN;
end
 
% If just 'defaults' passed in, return the default options in X
if nargin == 1 && nargout <= 1 && isequal(FUN,'defaults')
    X = defaultopt;
    return
end
%Only function_handle or inlines are allowed
if isempty(FUN) ||  ~(isa(FUN,'inline') || isa(FUN,'function_handle'))
    error('gads:PFMINLCON:needHandleOrInline','Objective function must be a function handle.');
end

%At least 2 arguments are needed. 
if nargin <2
    error('gads:PFMINLCON:inputArg','PFMINLCON requires at least 2 input arguments.');
end
if nargin < 9,  options = [];
    if nargin < 8, UB = [];
        if nargin < 7, LB = [];
            if nargin <6, Beq = [];
                if nargin <5, Aeq = [];
                    if nargin < 4, Bineq = [];
                        if nargin <3, Aineq= [];
                        end, end, end, end, end, end, end

%Initialize output args
X = []; FVAL = []; EXITFLAG = []; OUTPUT = [];

if(~isempty(initialX))
    Iterate.x = initialX(:);
    X = initialX;
    numberOfVariables = length(Iterate.x);
    type ='linearconstraints';
else
    error('gads:PFMINLCON:initialPoint','You must provide an initial point.');
end
%Retrieve all the options
[verbosity,MeshExpansion,MeshContraction,Completesearch, MeshAccelerator,minMesh,MaxMeshSize, ...
        maxIter,maxFun, TolBind,TolFun, TolX, MeshSize, pollmethod, pollorder,Completepoll,outputTrue,OutputFcns, ...
        OutputFcnArgs, plotTrue,PlotFcns, PlotFcnArgs,PlotInterval,searchtype ,searchFcnArg,Cache,Vectorized,NotVectorizedPoll, ...
        NotVectorizedSearch,cachetol,cachelimit,scaleMesh,RotatePattern]  =  checkoptions(options,defaultopt,numberOfVariables);
%Bound correction
[LB,UB,msg,EXITFLAG] = checkbound(LB,UB,numberOfVariables,verbosity);
if EXITFLAG < 0
    FVAL     =    [];
    X(:)     =  Iterate.x;
    OUTPUT.message = msg;
    if verbosity > 0
        fprintf('%s\n',msg)
    end
    return
end
%Make A, L, U.
[Iterate,A,L,U,nineqcstr,neqcstr,ncstr,IndIneqcstr,IndEqcstr,msg,EXITFLAG] = ...
    aluform(Iterate.x,Aineq,Bineq,Aeq,Beq,LB,UB,numberOfVariables,type,verbosity);
if EXITFLAG < 0
    FVAL     =    [];
    X(:)     =  Iterate.x;
    OUTPUT.message = msg;
    if verbosity > 0
        fprintf('%s\n',msg)
    end
    return
end
%Get some initial values
[FUN,Iterate,Iter,FunEval,scale,Successdir,nextIterate,deltaF,deltaX,MeshCont,NewMeshSize, ...
        infMessage,how,stopOutput,stopPlot,run,OUTPUT,EXITFLAG,X,FVAL] = getinitial(FUN,X,Iterate,Vectorized, ...
    objFcnArg,type,neqcstr,MeshContraction,MeshSize,scaleMesh,numberOfVariables,LB,UB);
%Set up output function plot
if(outputTrue)
    optimvalues = struct('x',X,'iteration',Iter,'fval',Iterate.f,'meshsize',MeshSize, ...
        'funccount',FunEval,'method',how,'TolFun',deltaF,'TolX',deltaX);
    [stopOutput,options,optchanged] = psoutput(OutputFcns,OutputFcnArgs,optimvalues,options,'init');
end
%Set up plot functions
if(plotTrue)
    optimvalues = struct('x',X,'iteration',Iter,'fval',Iterate.f,'meshsize',MeshSize, ...
        'funccount',FunEval,'method',how,'TolFun',deltaF,'TolX',deltaX);
    stopPlot = psplot(PlotFcns,PlotFcnArgs,PlotInterval,optimvalues,'init');
end
%Print some more diagnostic information if verbosity > 2
if verbosity > 2
    psdiagnose(FUN,Iterate,X,type,nineqcstr,neqcstr,ncstr,options);
end
%Setup display header 
if  verbosity>1
    fprintf('\n\nIter     f-count        MeshSize      f(x)        Method\n');
end

while run
    %Check for convergence
    [X,EXITFLAG,FVAL,msg,run] = isconverged(stopOutput,stopPlot,verbosity,Iter,maxIter,FunEval,maxFun,MeshSize,minMesh, ...
        infMessage,nextIterate,how,deltaX,deltaF,TolFun,TolX,X,EXITFLAG,FVAL,run);
    if ~run
        continue;
    end
    %SEARCH.
    [successSearch,nextIterate,FunEval] = search(FUN,X,searchtype,Completesearch,Iterate, ...
        Successdir,pollorder,MeshSize,scale,TolBind,A,L,U,IndIneqcstr,IndEqcstr,Iter, ...
        FunEval,maxFun,type,NotVectorizedSearch,Cache,cachetol,cachelimit,searchFcnArg,objFcnArg{:});
    
    %POLL
    if ~successSearch  %Unsuccessful search
        [successPoll,nextIterate,FunEval,Successdir] = poll(FUN,X,pollmethod,Completepoll,pollorder ...
            ,Iterate,Successdir,MeshSize,scale,TolBind,A,L,U,IndIneqcstr,IndEqcstr,Iter, ...
            FunEval,maxFun,type,NotVectorizedPoll,Cache,cachetol,cachelimit,objFcnArg{:});
    else
        successPoll =0; %Reset this parameter because this is used in updating mesh
    end
    
    %Scale the variables in every iterations
    if strcmpi(scaleMesh,'on') && ~neqcstr
        scale = logscale(LB,UB,mean(Iterate.x,2));
    end
    
    if outputTrue
        %Update optimvalues if outputfcn is provided
        optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
        %Intermediate call to outputfcn 'iter' state
        [stopOutput,options,optchanged] = psoutput(OutputFcns, OutputFcnArgs,optimvalues,options,'iter');
        if optchanged
            [verbosity,MeshExpansion,MeshContraction,Completesearch, MeshAccelerator,minMesh,MaxMeshSize, ...
                    maxIter,maxFun, TolBind,TolFun, TolX, MeshSize, pollmethod, pollorder,Completepoll,outputTrue,OutputFcns, ...
                    OutputFcnArgs, plotTrue,PlotFcns, PlotFcnArgs,PlotInterval,searchtype ,searchFcnArg,Cache,Vectorized,NotVectorizedPoll, ...
                    NotVectorizedSearch,cachetol,cachelimit,scaleMesh,RotatePattern]  =  checkoptions(options,defaultopt,numberOfVariables);
        end
    end
    if(plotTrue)
        optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
        stopPlot = psplot(PlotFcns,PlotFcnArgs,PlotInterval,optimvalues,'iter');
    end
    %Update
    [NewMeshSize,MeshContraction,how,deltaX,deltaF,scale,Iterate,X,Iter,infMessage] = ...
        updateparam(successPoll,successSearch,MeshAccelerator,RotatePattern,MaxMeshSize,minMesh,MeshExpansion,MeshCont, ...
        MeshContraction,MeshSize,scale,nextIterate,Iterate,X,Iter,how,infMessage);
  
    %Update mesh size 
    MeshSize = NewMeshSize;
end % End of while

if(outputTrue)
    optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
    [stopOutput,options,optchanged] = psoutput(OutputFcns, OutputFcnArgs,optimvalues,options,'done');
end
if(plotTrue)
    optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
    stopPlot = psplot(PlotFcns,PlotFcnArgs,PlotInterval,optimvalues,'done');
end

OUTPUT = struct('function',FUN,'problemtype',type,'pollmethod',pollmethod,'searchmethod',searchtype, ...
    'iterations',Iter,'funccount',FunEval,'meshsize',MeshSize,'message',msg);
