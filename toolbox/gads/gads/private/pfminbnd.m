function [X,FVAL,EXITFLAG,OUTPUT] = pfminbnd(FUN,initialX,LB,UB,options)
%PFMINBND Finds minimum of a function with bound constraints.
%   PFMINBND solves problems of the form:
%        min F(X)  subject to: LB <= X <= UB  (Bound constraints) 
%         X                  
%           
%   X = PFMINBND(FUN,X0,LB,UB) starts at X0 and finds a local minimum X to the
%   function FUN, subject to the bounds LB <= X <= UB. FUN accepts input X
%   and returns a scalar function value F evaluated at X. X0 may be a scalar,
%   or vector. If LB (or UB) is empty (or not provided) it is automatically 
%   expanded to -Inf (or Inf)
%
%   X = PFMINBND(FUN,X0,LB,UB,OPTIONS) minimizes with the default optimization 
%   parameters replaced by values in the structure OPTIONS. OPTIONS can be created 
%   with the PSOPTIMSET function.
%
%   [X,FVAL] = PFMINBND(FUN,X0,LB,UB,...) returns the value of the objective 
%   function FUN at the solution X.
%
%   [X,FVAL,EXITFLAG] = PFMINBND(FUN,X0,LB,UB,...) returns a string EXITFLAG that 
%   describes the exit condition of PFMINBND.  
%     If EXITFLAG is:
%        > 0 then PFMINBND converged to a solution X.
%        = 0 then the algorithm reached the maximum number of iterations or maximum number of function evaluations.
%        < 0 then PFMINBND did not converge to a solution.
%
%   [X,FVAL,EXITFLAG,OUTPUT] = PFMINBND(FUN,X0,...) returns a structure
%   OUTPUT with the following information:
%          function: <Objective function>
%       problemtype: <Type of problem> (Unconstrained, Bound constrained or linear constrained)
%        pollmethod: <Polling technique>
%      searchmethod: <Search technique> used, if any
%        iterations: <Total iterations>
%         funcCount: <Total function evaluations>
%          meshsize: <Mesh size at X>



%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.20.6.2 $  $Date: 2004/03/09 16:15:53 $


defaultopt = psoptimset;  

%If FUN is a cell array with additional arguments, handle them
if  iscell(FUN)
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
    error('gads:PFMINBND:needHandleOrInline','Objective function must be a function handle.');
end


%At least 2 arguments are needed. 
if nargin <2
    error('gads:PFMINBND:inputArg','PFMINBND requires at least 2 input arguments.');
end
if nargin < 5,options = [];
    if nargin < 4, UB = [];
        if nargin < 3, LB = [];
        end, end, end

%Initialize output args
X = []; FVAL = []; EXITFLAG = []; OUTPUT = []; 

if(~isempty(initialX))
    Iterate.x = initialX(:);
    X = initialX;
    numberOfVariables = length(Iterate.x);
    type = 'boundconstraints';
else
    error('gads:PFMINBND:initialPoint','You must provide an initial point.');
end
%Retrieve all the options
[verbosity,MeshExpansion,MeshContraction,Completesearch, MeshAccelerator,minMesh,MaxMeshSize, ...
        maxIter,maxFun, TolBind,TolFun, TolX, MeshSize, pollmethod, pollorder,Completepoll,outputTrue,OutputFcns, ...
        OutputFcnArgs,plotTrue,PlotFcns, PlotFcnArgs, PlotInterval,searchtype ,searchFcnArg,Cache,Vectorized,NotVectorizedPoll, ...
        NotVectorizedSearch,cachetol,cachelimit,scaleMesh,RotatePattern]  =  checkoptions(options,defaultopt,numberOfVariables);
%Bound correction
[LB,UB,msg,EXITFLAG] = checkbound(LB,UB,numberOfVariables,verbosity);
if EXITFLAG < 0
    FVAL = [];
    X(:) = Iterate.x;
    OUTPUT.message = msg;
    if verbosity > 0
         fprintf('%s\n',msg)
    end
    return
end
%Make Iterate feasible and form A.
[Iterate,A] =aluform(Iterate.x,[],[],[],[],LB,UB,numberOfVariables,type,verbosity);
%Get some initial values
[FUN,Iterate,Iter,FunEval,scale,Successdir,nextIterate,deltaF,deltaX,MeshCont,NewMeshSize, ...
        infMessage,how,stopOutput,stopPlot,run,OUTPUT,EXITFLAG,X,FVAL] = getinitial(FUN,X,Iterate,Vectorized, ...
    objFcnArg,type,0,MeshContraction,MeshSize,scaleMesh,numberOfVariables,LB,UB);

%Set up output function plot
if(outputTrue)
    optimvalues = struct('x',X,'iteration',Iter,'fval',Iterate.f,'meshsize',MeshSize, ...
        'funccount',FunEval,'method',how,'TolFun',deltaF,'TolX',deltaX);
    [stopOutput,options,optchanged] = psoutput(OutputFcns,OutputFcnArgs,optimvalues,options,'init');
end
if(plotTrue)
    optimvalues = struct('x',X,'iteration',Iter,'fval',Iterate.f,'meshsize',MeshSize, ...
        'funccount',FunEval,'method',how,'TolFun',deltaF,'TolX',deltaX);
    stopPlot = psplot(PlotFcns,PlotFcnArgs,PlotInterval,optimvalues,'init');
end
%Print some more diagnostic information if verbosity > 2
if verbosity > 2
    psdiagnose(FUN,Iterate,X,type,[],[],[],options);
end
%Setup display header 
if  verbosity > 1
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
        Successdir,pollorder,MeshSize,scale,TolBind,A,LB,UB,[],[],Iter,FunEval,maxFun,type,NotVectorizedSearch,Cache,cachetol,cachelimit,searchFcnArg,objFcnArg{:});
    %POLL
    if ~successSearch  %Unsuccessful search
        [successPoll,nextIterate,FunEval,Successdir] = poll(FUN,X,pollmethod,Completepoll,pollorder ...
            ,Iterate,Successdir,MeshSize,scale,TolBind,A,LB,UB,[],[],Iter,FunEval,maxFun,type,NotVectorizedPoll,Cache,cachetol,cachelimit,objFcnArg{:});
    else
        successPoll =0;
    end 
    
    %Scale the variables (if needed)
    if strcmpi(scaleMesh,'on') 
        meanX = mean([Iterate.x],2);
        scale = logscale(LB,UB,meanX);
    end
    
    %Update optimvalues if outputfcn is provided
    if outputTrue
        %Update optimvalues if outputfcn is provided
        optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
        %Intermediate call to outputfcn 'iter' state
        [stopOutput,options,optchanged] = psoutput(OutputFcns, OutputFcnArgs,optimvalues,options,'iter');
        if optchanged
            [verbosity,MeshExpansion,MeshContraction,Completesearch, MeshAccelerator,minMesh,MaxMeshSize, ...
                    maxIter,maxFun, TolBind,TolFun, TolX, MeshSize, pollmethod, pollorder,Completepoll,outputTrue,OutputFcns, ...
                    OutputFcnArgs,plotTrue,PlotFcns, PlotFcnArgs, PlotInterval,searchtype ,searchFcnArg,Cache,Vectorized,NotVectorizedPoll, ...
                    NotVectorizedSearch,cachetol,cachelimit,scaleMesh,RotatePattern]  =  checkoptions(options,defaultopt,numberOfVariables); 
        end
    end
    if(plotTrue)
        optimvalues.x = X; optimvalues.iteration = Iter; optimvalues.fval = Iterate.f; optimvalues.meshsize = MeshSize;
        optimvalues.funccount = FunEval; optimvalues.method = how; optimvalues.TolFun = deltaF; optimvalues.TolX = deltaX;
        stopPlot = psplot(PlotFcns,PlotFcnArgs,PlotInterval,optimvalues,'iter');
    end
    %UPDATE
    [NewMeshSize,MeshContraction,how,deltaX,deltaF,scale,Iterate,X,Iter,infMessage] = ...
        updateparam(successPoll,successSearch,MeshAccelerator,RotatePattern,MaxMeshSize,minMesh,MeshExpansion,MeshCont, ...
        MeshContraction,MeshSize,scale,nextIterate,Iterate,X,Iter,how,infMessage);
   
    %Update mesh size 
    MeshSize = NewMeshSize;
end

%Output Function 
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
