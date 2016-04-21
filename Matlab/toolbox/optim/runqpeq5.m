function [fval, exitflag, output, x] = runqpeq5
% RUNQPEQ5 demonstrates 'HessMult' option for QUADPROG with equalities.
% 
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:54 $

load qpeq5 % Get xstart, Aeq, Beq, f, xstart, A, B
mtxmpy = @qpeq5mult; % function handle to subfunction qpeq5mult

% Choose the HessMult option
% Override the TolPCG option
options = optimset('HessMult',mtxmpy,'display','iter','TolPcg',0.01); 

% Pass B to qpeq5mult via the H argument. Also, B will be used in
% computing a preconditioner for PCG.
% A is passed as additional arguments after 'options'
n = length(f);
[x, fval, exitflag, output] = quadprog(B,f,[],[],Aeq,beq,[],[],xstart,options,A);

%----------------------------------------------------------------------------
function W = qpeq5mult(B,Y,A);
% QPEQ5MULT Structured multiply
%
%   W = qpeq5mult(B,Y,A);
%
%   Compute W = (B + A)*Y where 
%
%   INPUT:
%       Y - vector (or matrix) to be multiplied by B+A.
%       A - square matrix (7 by 7).
%       B - square matrix (7 by 7)
%
%   OUTPUT:
%       W - The product (B + A)*Y.
%

  W = B*Y + A*Y;
