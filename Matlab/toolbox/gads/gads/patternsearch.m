function [X,FVAL,EXITFLAG,OUTPUT] = patternsearch(FUN,initialX,Aineq,Bineq,Aeq,Beq,LB,UB,options) 
%PATTERNSEARCH Finds a linearly constrained minimum of a function. 
%   PATTERNSEARCH solves problems of the form: 
%           min F(X)    subject to:      A*X <= b 
%            X                          Aeq*X = beq 
%                                      LB <= X <= UB  
%           
%   X = PATTERNSEARCH(FUN,X0) starts at X0 and finds a local minimum X to
%   the function FUN. FUN accepts input X and returns a scalar function
%   value F evaluated at X. X0 may be a scalar or vector. 
% 
%   X = PATTERNSEARCH(FUN,X0,A,b) starts at X0 and finds a local minimum X
%   to the function FUN, subject to  A*X <= b. If A is a matrix of size
%   m-by-n then m is the number of linear inequality constraints and n is
%   the number of variables. The input b is a vector of length m. 
% 
%   X = PATTERNSEARCH(FUN,X0,A,b,Aeq,beq) starts at X0 and finds a local
%   minimum X to the  function FUN, subject to  A*X <= b and  Aeq*X = beq.
%   If Aeq is a matrix of size m-by-n then m is the number of linear
%   equality constraints and n is the number of variables. The input beq is a 
%   vector of length m. If there are no linear inequality constraints, 
%   pass empty matrices for A and b. 
% 
%   X = PATTERNSEARCH(FUN,X0,A,b,Aeq,beq,LB,UB) starts at X0 and finds a
%   local minimum X to the  function FUN, subject to  A*X <= b, Aeq*X = beq
%   and LB <= X <= UB. Use empty matrices for LB and UB if no bounds exist. 
%   Set LB(i) = -Inf if X(i) is unbounded below; set UB(i) = Inf if X(i) is 
%   unbounded above. If there are no linear constraints, pass empty matrices 
%   for A, b, Aeq and beq. 
% 
%   X = PATTERNSEARCH(FUN,X0,A,b,Aeq,beq,LB,UB,options) minimizes with the
%   default optimization parameters replaced by values in the structure
%   OPTIONS. OPTIONS can be created with the PSOPTIMSET function. See
%   PSOPTIMSET for details.
%
%   X = PATTERNSEARCH(PROBLEM) finds the minimum for PROBLEM. PROBLEM is a struct
% 	that has the following fields:
%      objective: <Objective function>
%             X0: <Starting point>
%          Aineq: <A matrix for inequality constraints>
%          Bineq: <B vector for inequality constraints>
%            Aeq: <A matrix for equality constraints>
%            Beq: <B vector for equality constraints>
%             LB: <Lower bound on X>
%             UB: <Upper bound on X>
%        options: <options structure created with PSOPTIMSET>
%      randstate: <Optional field to reset rand state>
%     randnstate: <Optional field to reset randn state>
%   This syntax is specially useful if you export a problem from
%   PSEARCHTOOL and use it from the command line to call PATTERNSEARCH.
%   NOTE: PROBLEM must have all the fields as specified above. 
%
%   [X,FVAL] = PATTERNSEARCH(FUN,X0,...) returns the value of the objective
%   function FUN at the solution X. 
% 
%   [X,FVAL,EXITFLAG] = PATTERNSEARCH(FUN,X0,...) returns a string EXITFLAG
%   that describes the exit condition of PATTERNSEARCH.   
%     If EXITFLAG is: 
%        > 0 then PATTERNSEARCH converged to a solution X. 
%        = 0 then the algorithm reached the maximum number of iterations 
%            or maximum number of function evaluations.  
%        < 0 then PATTERNSEARCH did not converge to a solution. 
% 
%   [X,FVAL,EXITFLAG,OUTPUT] = PATTERNSEARCH(FUN,X0,...) returns a
%   structure OUTPUT with the following information: 
%          function: <Objective function> 
%       problemtype: <Type of problem> (Unconstrained, Bound constrained or     
%                     linear constrained) 
%        pollmethod: <Polling technique> 
%      searchmethod: <Search technique> used, if any 
%        iterations: <Total iterations> 
%         funccount: <Total function evaluations> 
%          meshsize: <Mesh size at X>
%           message: <PATTERNSEARCH termination message>
% 
%   Examples: 
%    FUN can be a function handle (using @)
%      X = patternsearch(@lincontest6, ...)
%    In this case, F = lincontest6(X) returns the scalar function
%    value F of the  function  evaluated at X.
% 
%   An example with inequality constraints and lower bounds
%    A = [1 1; -1 2; 2 1];  b = [2; 2; 3];  lb = zeros(2,1); 
%    [X,FVAL,EXITFLAG] = patternsearch(@lincontest6,[0 0],A,b,[],[],lb);
% 
%   See also PSOPTIMSET, GA, PSOUTPUTFCNTEMPLATE, SEARCHFCNTEMPLATE, @, INLINE.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.2 $  $Date: 2004/04/04 03:24:33 $ 

defaultopt = struct('TolMesh', 1e-6, ...
                'TolX', 1e-6 , ...
                'TolFun',1e-6 , ...
                'TolBind',1e-3, ...
                'MaxIteration', '100*numberofvariables', ...
                'MaxFunEvals', '2000*numberofvariables', ...
                'MeshContraction', 0.5, ... 
                'MeshExpansion', 2.0, ...
                'MeshAccelerator','off', ...
                'MeshRotate','on', ...
                'InitialMeshSize', 1.0, ...
                'ScaleMesh', 'on', ...
                'MaxMeshSize', inf, ...
                'PollMethod', 'positivebasis2n', ...
                'CompletePoll','off', ...
                'PollingOrder', 'consecutive', ...
                'SearchMethod', [], ...
                'CompleteSearch','off', ...
                'Display', 'final', ...
                'OutputFcns', [], ...
                'PlotFcns', [], ...
                'PlotInterval', 1, ...
                'Cache','off', ... 
                'CacheSize',1e4, ... 
                'CacheTol',eps, ...
                'Vectorized','off' ...
               );     

% If just 'defaults' passed in, return the default options in X 
if  checkinputs && nargin == 1 && nargout <= 1 && isequal(FUN,'defaults') 
    X = defaultopt; 
    return 
end 

errmsg = nargchk(1,9,nargin); 
%At least 1 arguments are needed.  
if nargin <1 
    error('gads:PATTERNSEARCH:inputArg',[errmsg,' PATTERNSEARCH requires at least 1 input argument.']); 
elseif ~isempty(errmsg) 
    error('gads:PATTERNSEARCH:inputArg',[errmsg,' PATTERNSEARCH takes at most 9 input arguments.']); 
end 
errmsg = nargoutchk(0,4,nargin); 
if nargout > 4 && ~isempty(errmsg) 
    error('gads:PATTERNSEARCH:outputArg',[errmsg,' PATTERNSEARCH returns at most 4 output arguments.']); 
end 


if nargin < 9,  options = []; 
    if nargin < 8, UB = []; 
        if nargin < 7, LB = []; 
            if nargin <6, Beq = []; 
                if nargin <5, Aeq = []; 
                    if nargin < 4, Bineq = []; 
                        if nargin <3, Aineq= []; 
                        end, end, end, end, end, end, end 

%if one input is provided, it must be a struct
if nargin == 1
    if isa(FUN,'struct')
        try
            if isfield(FUN, 'randstate') && isfield(FUN, 'randnstate') && ...
                    isa(FUN.randstate, 'double') && isequal(size(FUN.randstate),[35, 1]) && ...
                    isa(FUN.randnstate, 'double') && isequal(size(FUN.randnstate),[2, 1])
                rand('state',FUN.randstate);
                randn('state',FUN.randnstate);
            end
            initialX = FUN.X0;
            Aineq    = FUN.Aineq;
            Bineq    = FUN.Bineq;
            Aeq      = FUN.Aeq;
            Beq      = FUN.Beq;
            LB       = FUN.LB;
            UB       = FUN.UB;
            options  = FUN.options;
            FUN      = FUN.objective;
        catch 
            msg = sprintf('%s%s\n%s', 'Trying to use a structure with invalid/missing fields: ', ...
                'See help for PATTERNSEARCH.', ...
                lasterr);
            
            error('gads:PATTERNSEARCH:invalidStructInput',msg);
        end
    else % Single input and non-structure.
        error('gads:PATTERNSEARCH:inputArg','The input should be a structure with valid fields or provide two arguments to patternsearch' );
    end
end
if ~isequal('double', superiorfloat(initialX,Aineq,Bineq,Aeq,Beq,LB,UB))
   error('gads:PATTERNSEARCH:dataType','PATTERNSEARCH only accepts inputs of data type double.');
end
%If Aeq or Aineq is NOT empty, then problem has linear constraints. 
%Call PFMINLCON 
if ~isempty(Aeq) || ~isempty(Aineq) 
    [X,FVAL,EXITFLAG,OUTPUT] = pfminlcon(FUN,initialX,Aineq,Bineq,Aeq,Beq,LB,UB,options); 
    %This condition satisfies bound constraints 
elseif (isempty(Aeq) && isempty(Aineq) && isempty(Bineq) && isempty(Beq)) && ( ~isempty(LB) || ~isempty(UB) ) 
    [X,FVAL,EXITFLAG,OUTPUT] = pfminbnd(FUN,initialX,LB,UB,options); 
elseif (isempty(Aeq) && isempty(Aineq) && isempty(Bineq) && isempty(Beq) && isempty(LB) && isempty(UB)) 
    [X,FVAL,EXITFLAG,OUTPUT] = pfminunc(FUN,initialX,options);   
    %Try with PFMINLCON 
else  
    try  
        [X,FVAL,EXITFLAG,OUTPUT] = pfminlcon(FUN,initialX,Aineq,Bineq,Aeq,Beq,LB,UB,options); 
    catch 
        error('gads:PATTERNSEARCH:entryPoint',lasterr); 
    end 
end 
 
