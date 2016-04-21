function make(file,verbose)
%MAKE Creates Mex files for MPC Toolbox
%
%   MAKE                builds all DLL's (MPCSFUN, QPSOLVER, MPCLOOP_ENGINE)
%   MAKE file           only build DLL 'file'
%   MAKE file verbose   also displays warning messages

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   Revision: 1.00 $  $Date: 2003/12/04 01:37:45 $   

if nargin<2,
    verbose='';
end
if nargin<1,
    makeall=1;
    file='';
else
    makeall=0;
end

verbose=strcmp(verbose,'verbose');
file=lower(file);

if makeall | strcmp(file,'mpc_sfun'),
    fprintf('Compiling MPC_SFUN ...');
    if verbose
        mex -v mpc_sfun.c dantzgmp_solver.c
    else
        mex mpc_sfun.c dantzgmp_solver.c
    end
    !move mpc_sfun.dll ..
    fprintf('Done!\n');
end

if makeall | strcmp(file,'mpcloop_engine'),
    fprintf('Compiling MPCLOOP_ENGINE ...');
    if verbose
        mex -v mpcloop_engine.c dantzgmp_solver.c
    else
        mex mpcloop_engine.c dantzgmp_solver.c
    end
    !move mpcloop_engine.dll ..
    fprintf('Done!\n');
end

if makeall | strcmp(file,'qpsolver'),
    fprintf('Compiling QPSOLVER ...');
    if verbose
        mex -v qpsolver.c dantzgmp_solver.c
    else
        mex qpsolver.c dantzgmp_solver.c
    end
    !move qpsolver.dll ..
    fprintf('Done!\n');
end

disp(' ')
disp('NOTE: To build RTW files, you must copy MPC_SFUN.C, MPC_SFUN.H, MPC_COMMON.C, MAT_MACROS.H, QPSOLVER.C, DANTZGMP.H')
disp('      to a visible directory. Examples: ''.'', ''$MatlabDirectory$\rtw\c\src''')