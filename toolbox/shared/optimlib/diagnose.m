function msg = diagnose(caller,OUTPUT,gradflag,hessflag,constflag,gradconstflag,line_search,...
    OPTIONS,defaultopt,XOUT,non_eq,...
    non_ineq,lin_eq,lin_ineq,LB,UB,funfcn,confcn,f,GRAD,HESS,c,ceq,cGRAD,ceqGRAD)
%DIAGNOSE prints diagnostic information about the function to be minimized
%    or solved.
%
% This is a helper function.

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $ $Date: 2004/03/26 13:27:15 $

msg = [];

pstr = sprintf('\n%s\n%s\n',...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
    '   Diagnostic Information ');
disp(pstr)

if ~isempty(funfcn{1})
    funformula =  getformula(funfcn{3});
    gradformula = getformula(funfcn{4});
    hessformula = getformula(funfcn{5});
else
    funformula =  '';
    gradformula = '';
    hessformula = '';
end

if ~isempty(confcn{1})
    conformula = getformula(confcn{3});
    gradcformula = getformula(confcn{4});
else
    conformula = '';
    gradcformula = '';
end    

disp(['Number of variables: ', int2str(length(XOUT)),sprintf('\n')])
if ~isempty(funfcn{1})
    disp('Functions ')
    switch funfcn{1}
    case 'fun'
        % display 
        disp([' Objective:                            ',funformula]);
        
    case 'fungrad'
        if gradflag
            disp([' Objective and gradient:               ',funformula]);
        else
            disp([' Objective:                            ',funformula]);
            disp( '   (set OPTIONS.GradObj=''on'' to use user provided gradient function)') 
        end
        
    case 'fungradhess'
        if gradflag && hessflag
            disp([' Objective, gradient and Hessian:      ',funformula]);
        elseif gradflag
            disp([' Objective and gradient:               ',funformula]);
            disp( '   (set OPTIONS.Hessian to ''on'' to use user provided Hessian function)') 
        else
            disp([' Objective:                            ',funformula]);
            disp( '   (set OPTIONS.GradObj=''on'' to use user provided gradient function)')
            disp( '   (set OPTIONS.Hessian to ''on'' to use user provided Hessian function)') 
        end
        
        
    case 'fun_then_grad'
        disp([' Objective:                            ',funformula]);
        if gradflag
            disp([' Gradient:                             ',gradformula]);
        end
        if hessflag
            disp('-->Ignoring OPTIONS.Hessian --no user Hessian function provided')
        end
        
    case 'fun_then_grad_then_hess'
        disp([' Objective:                            ',funformula]);
        if gradflag && hessflag
            disp([' Gradient:                             ',gradformula]);
            disp([' Hessian:                              ',hessformula]);
        elseif gradflag
            disp([' Gradient:                             ',gradformula]);
        end   
    otherwise
        
    end
    
    if ~gradflag
        disp(' Gradient:                             finite-differencing')
    end
    % shape of grad
    
    if ~hessflag && (isequal('fmincon',caller) || isequal('constrsh',caller) || isequal('fminunc',caller))
        disp(' Hessian:                              finite-differencing (or Quasi-Newton)')
    end
    % shape of hess
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(confcn{1})
    switch confcn{1}
        
    case 'fun'
        disp([' Nonlinear constraints:                ',conformula]);
    case 'fungrad'
        if gradconstflag
            disp([' Nonlinear constraints and gradient:   ',conformula]);
        else
            disp([' Nonlinear constraints:                ',conformula]);
            disp( '   (set OPTIONS.GradConstr to ''on'' to use user provided gradient of constraints function)') 
        end
        
    case 'fun_then_grad'
        disp([' Nonlinear constraints:                ',conformula]);
        if gradconstflag
            disp([' Nonlinear constraints gradient:       ',gradcformula]);
        end
        
    otherwise
        
    end
    
    if ~constflag
        disp(' Nonlinear constraints:                finite-differencing')
    end
    if ~gradconstflag
        
        disp(' Gradient of nonlinear constraints:    finite-differencing')
    end
    disp([sprintf('\n'),'Constraints'])  
    disp([' Number of nonlinear inequality constraints: ',int2str(non_ineq)])
    disp([' Number of nonlinear equality constraints:   ',int2str(non_eq)])
    
elseif isequal(caller,'fmincon') || isequal(caller,'constrsh') || isequal(caller,'fminimax') || ...
        isequal(caller,'fgoalattain') || isequal(caller,'fseminf')
    disp([sprintf('\n'),'Constraints'])
    disp(' Nonlinear constraints:             do not exist')
    
end

disp(' ')

switch caller
case {'fmincon','constrsh','linprog','quadprog','lsqlin','fminimax','fseminf','fgoalattain'}
    disp([' Number of linear inequality constraints:    ',int2str(lin_ineq)])
    disp([' Number of linear equality constraints:      ',int2str(lin_eq)])
    disp([' Number of lower bound constraints:          ',int2str(nnz(~isinf(LB)))])
    disp([' Number of upper bound constraints:          ',int2str(nnz(~isinf(UB)))])
case {'lsqcurvefit','lsqnonlin'}
    disp([' Number of lower bound constraints:          ',int2str(nnz(~isinf(LB)))])
    disp([' Number of upper bound constraints:          ',int2str(nnz(~isinf(UB)))])
case {'bintprog'}
    disp([' Number of 0-1 binary integer variables:     ',int2str(length(XOUT))])
    disp([' Number of linear inequality constraints:    ',int2str(lin_ineq)])
    disp([' Number of linear equality constraints:      ',int2str(lin_eq)])
case {'fsolve','fminunc','fsolves'}
otherwise
end

if ~isempty(OUTPUT)
    temp = sprintf('\n%s\n   %s\n','Algorithm selected',OUTPUT.algorithm);
    disp(temp)
end

pstr = sprintf('\n%s\n%s\n',...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
    ' End diagnostic information ');

disp(pstr)


%--------------------------------------------------------------------------------
function funformula = getformula(fun)
% GETFORMULA Convert FUN to a string.

if isempty(fun)
    funformula = '';
    return;
end

if ischar(fun) % already a string
    funformula = fun;
elseif isa(fun,'function_handle')  % function handle
    funformula = func2str(fun);
elseif isa(fun,'inline')   % inline object
    funformula = formula(fun);
else % something else with a char method
    try
        funformula = char(fun);
    catch
        funformula = '';
    end
end
