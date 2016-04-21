%
% LMI-Lab Commands:
%
% Specification of LMIs.
%    lmiedit   - GUI-based specification of LMIs.
%    setlmis   - Initialize the LMI description.
%    lmivar    - Specify a new matrix variable.
%    lmiterm   - Add a term to the list of LMI terms.
%    newlmi    - Attach a name or tag to new LMIs.
%    getlmis   - Get the internal description of the LMI system.
%
% Information retrieval.
%    lmiinfo   - Inquire about an existing system of LMIs.
%    lminbr    - Get the number of LMIs in a problem.
%    matnbr    - Get the number of matrix variables in a problem.
%    decnbr    - Get the number of decision variables.
%    dec2mat   - Matrix variable values given the decision variables.
%    mat2dec   - Decision variable values given the matrix variables.
%    decinfo   - Decision variable distribution in matrix variables.
%
% LMI solvers.
%    feasp     - Compute a solution to a given LMI system.
%    mincx     - Linear objective minimization under LMI constraints.
%    gevp      - Generalized eigenvalue minimization.
%    dec2mat   - Convert solver output to matrix variable values.
%    defcx     - Help specify c'x objectives for MINCX.
%
% Validation of results.
%    evallmi   - Evaluate LMIs for given values of the variables.
%    showlmi   - Return the lhs and rhs of evaluated LMIs.
%
% Modification of a system of LMIs.
%    dellmi    - Delete an LMI from a system.
%    delmvar   - Remove a matrix variable from a problem.
%    setmvar   - Set a matrix variable to some value.
%
% Special problems
%    basiclmi  - Solution of M+P'*X*Q+Q'*X'*P < 0.
%
% Demonstration
%    lmidem    - Demo of the LMI Lab environment.
%

% Copyright 1995-2004 The MathWorks, Inc. 
