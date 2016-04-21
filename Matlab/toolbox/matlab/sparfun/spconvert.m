function S = spconvert(D)
%SPCONVERT Import from sparse matrix external format.
%   SPCONVERT is used to create sparse matrices from a simple sparse
%   format easily produced by non-MATLAB sparse programs.  SPCONVERT
%   is the second step in the process:
%     1) LOAD an ASCII data file containing [i,j,v] or [i,j,re,im]
%        as rows into a MATLAB variable.
%     2) Convert that variable into a MATLAB sparse matrix.
%
%   S = SPCONVERT(D) converts the matrix D containing row-column-value
%   triples [i,j,v] as rows into a sparse matrix S such that
%      for k=1:size(D,1),
%         S(D(k,1),D(k,2)) = D(k,3).
%      end
%
%   If D is M-by-4 then the third and fourth columns are treated as
%   the real and imaginary parts of the complex values, so that
%      for k=1:size(D,1),
%         S(D(k,1),D(k,2)) = D(k,3) + i*D(k,4).
%      end
%
%   D can contain rows of the form [m n 0] or [m n 0 0] to specify
%   size(S) is m-by-n. If D is already sparse no conversion is done, so
%   SPCONVERT can be used after D is loaded from either a MAT or an
%   ASCII file.
%
%   Example: Suppose mydata.dat contains the rows
%           8  1  6.00
%           3  5  7.00
%           4  9  2.00
%           9  9  0
%
%   then the commands
%
%       load mydata.dat
%       A = spconvert(mydata);
%
%   produces the 9-by-9 sparse matrix
%
%       A = 
%          (8,1)        6
%          (3,5)        7
%          (4,9)        2
%
%   See also SPARSE, FULL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/16 22:08:31 $

if ~issparse(D)
    [nnz,na] = size(D);
    if na == 3
       S = sparse(D(:,1),D(:,2),D(:,3));
    elseif na == 4
       S = sparse(D(:,1),D(:,2),D(:,3)+i*D(:,4));
    else
       error('MATLAB:spconvert:WrongArraySize',...
             'Array D must have 3 or 4 columns.')
    end
else
    S = D;
end
