%% Matrix Manipulation
% This demo examines some basic matrix manipulations in MATLAB.
% 
% Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 5.16 $ $Date: 2002/04/15 03:35:51 $

%% 
% We start by creating a magic square and assigning it to the variable A.

A = magic(3)

%% 
% Here's how to add 2 to each element of A.
% 
% Note that MATLAB requires no special handling of  matrix math.

A+2

%% 
% The apostrophe symbol denotes the complex conjugate transpose of a matrix.
% 
% Here's how to take the transpose of A.

A'

%% 
% The symbol * denotes multiplication of matrices.
% 
% Let's create a new matrix B and multiply A by B.

B = 2*ones(3)
A*B

%% 
% We can also multiply each element of A with its  corresponding element of B by
% using the  .* operator. 

A.*B

%% 
% MATLAB has functions for nearly every type of common matrix calculation.  For
% example, we can find the eigenvalues of A using the "eig" command.

eig(A)

%%
% This concludes our brief tour of some MATLAB matrix handling capabilities.
