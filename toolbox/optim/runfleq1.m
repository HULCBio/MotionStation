function [fval, exitflag, output, x] = runfleq1
% RUNFLEQ1 demonstrates 'HessMult' option for FMINCON with linear
% equalities.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.3 $  $Date: 2004/04/01 16:13:03 $

problem = load('fleq1');   % Get V, Aeq, beq
V = problem.V; Aeq = problem.Aeq; beq = problem.beq;
n = 1000;             % problem dimension
xstart = -ones(n,1); xstart(2:2:n,1) = ones(length(2:2:n),1); % starting point
options = optimset('GradObj','on','Hessian','on','HessMult',@(Hinfo,Y)hmfleq1(Hinfo,Y,V) ,...
    'Display','iter','TolFun',1e-9); 
[x,fval,exitflag,output] = fmincon(@(x)brownvv(x,V),xstart,[],[],Aeq,beq,[],[], ...
                                    [],options);
