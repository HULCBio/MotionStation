function a=combine(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11)
%COMBINE Form matrix from individual vectors and matrices.
%   AOUT = COMBINE(A1,A2,A3,..) forms the matrix AOUT containing the
%   vectors A1,A2,A3,... as rows.  Automatically pads each string with
%   zeros in order to form a valid matrix.  Up to 11 vectors
%   can be used to form AOUT.  Each vector parameter, Ai, can itself be a 
%   matrix.  This allows the creation of arbitrarily large matrices.
%   Although the inputs A1,A2, ... can be strings, the output AOUT is
%   always cast as a string. This function is used to assemble fuzzy
%   inference system (FIS) matrices.
%
%   For example:
%
%           combine('hello',8,[110 101 100],'blue')

%   This function is based on the function STR2MAT.
%   Ned Gulley, 2-2-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/14 22:20:20 $

maxInputs = 11;
numInputs = nargin;

% Determine the largest string size.
numRows = zeros(1,maxInputs); 
numCols = zeros(1,maxInputs);

% Find out how big the inputs are
% Empty rows will be ignored
for count=1:numInputs,
    countStr=int2str(count);
    evalStr = ['size(a',countStr,')'];
    [m,n] = eval(evalStr);
    % If the input is a string, set it to ASCII numbers
    evalStr = ['if isstr(a',countStr,'), a',countStr,'=abs(a',countStr,'); end'];
    eval(evalStr);
    numRows(count) = m;
    numCols(count) = n;
end

% Create a buffer of zeros the right size
buffer=zeros(sum(numRows),max(numCols));

% Fill up the output matrix
currRow=1;
for count=1:numInputs,
    countStr=int2str(count);
    rowIndex=[currRow:(currRow+numRows(count)-1)];
    colIndex=[1:numCols(count)];
    evalStr = ['buffer(rowIndex,colIndex) = a',countStr,';'];
    eval(evalStr);
    currRow=currRow+numRows(count);
end

a=buffer;

