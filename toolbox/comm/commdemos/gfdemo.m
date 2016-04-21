%% Galois Fields
% A Galois field is an algebraic field that has a finite number of members.
% This section describes how to work with fields that have 2^m members,
% where m is an integer between 1 and 16.  Such fields are denoted GF(2^m).
% Galois fields are used in error-control coding.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2.2.1 $ $Date: 2003/04/23 06:13:41 $


%% Creating Galois field arrays
% You create Galois field arrays using the GF function.  To create the
% element 3 in the Galois field 2^2, you can use the following command:

A = gf(3,2)


%% Using Galois field arrays
% You can now use A as if it were a built-in MATLAB data type.  For
% example, here is how you can add two elements in a Galois field together:

A = gf(3,2);
B = gf(1,2);
C = A+B


%% Arithmetic in Galois fields
% Note that 3 + 1 = 2 in this Galois field.  The rules for arithmetic
% operations are different for Galois field elements compared to integers.
% To see some of the differences between Galois field arithmetic and
% integer arithmetic, first look at an addition table for integers 0
% through 3:
%
%    +__0__1__2__3
%    0| 0  1  2  3 
%    1| 1  2  3  4
%    2| 2  3  4  5
%    3| 3  4  5  6
%
% You can define such a table in MATLAB with the following commands:

A = ones(4,1)*[0 1 2 3];
B = [0 1 2 3]'*ones(1,4);
Table = A+B

%%
% Similarly, create an addition table for the field GF(2^2) with the
% following commands:

A = gf(ones(4,1)*[0 1 2 3],2);
B = gf([0 1 2 3]'*ones(1,4),2);
A+B


%% Using MATLAB functions with Galois arrays
% Many other MATLAB functions will work with Galois arrays.  To see this,
% first create a couple of arrays.

A = gf([1 33],8);
B = gf([1 55],8);

%%  
% Now you can multiply two polynomials.

C = conv(A,B)

%%
% You can also find roots of a polynomial.  (Note that they match the
% original values in A and B.)

roots(C)


%% Hamming code example
% The most important application of Galois field theory is in error-control
% coding.  The rest of this demonstration uses a simple error-control
% code, a Hamming code.  An error-control code works by adding redundancy
% to information bits.  For example, a (7,4) Hamming code maps 4 bits of
% information to 7-bit codewords.  It does this by multiplying the 4-bit
% codeword by a 4 x 7 matrix.  You can obtain this matrix with the HAMMGEN
% function:

[H,G] = hammgen(3)

%%
% H is the parity-check matrix and G is the generator matrix. To encode the
% information bits [0 1 0 0], multiply the information bits [0 1 0 0] by
% the generator matrix G:

A = gf([0 1 0 0],1)
Code = A*G

%%
% Suppose somewhere along transmission, an error is introduced into this
% codeword.  (Note that a Hamming code can correct only 1 error.)

Code(1) = 1   % Place a 1 where there should be a 0.

%%
% You can use the parity-check matrix H to determine where the error
% occurred, by multiplying the codeword by H:

H*Code'

%%
% To find the error, look at the parity-check matrix H.  The column in H
% that matches [1 0 0 ]' is the location of the error.  Looking at H, you
% can see that the first column is [1 0 0]'.  This means that the first
% element of the vector Code contains the error.

H
