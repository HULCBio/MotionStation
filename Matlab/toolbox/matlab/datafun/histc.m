%HISTC Histogram count.
%   N = HISTC(X,EDGES), for vector X, counts the number of values in X
%   that fall between the elements in the EDGES vector (which must contain
%   monotonically non-decreasing values).  N is a LENGTH(EDGES) vector
%   containing these counts.  
%
%   N(k) will count the value X(i) if EDGES(k) <= X(i) < EDGES(k+1).  The
%   last bin will count any values of X that match EDGES(end).  Values
%   outside the values in EDGES are not counted.  Use -inf and inf in
%   EDGES to include all non-NaN values.
%
%   For matrices, HISTC(X,EDGES) is a matrix of column histogram counts.
%   For N-D arrays, HISTC(X,EDGES) operates along the first non-singleton
%   dimension.
%
%   HISTC(X,EDGES,DIM) operates along the dimension DIM. 
%
%   [N,BIN] = HISTC(X,EDGES,...) also returns an index matrix BIN.  If X is a
%   vector, N(K) = SUM(BIN==K). BIN is zero for out of range values. If X
%   is an m-by-n matrix, then,
%     for j=1:n, N(K,j) = SUM(BIN(:,j)==K); end
%
%   Use BAR(EDGES,N,'histc') to plot the histogram.
%
%   Example:
%      histc(pascal(3),1:6) produces the array [3 1 1;
%                                               0 1 0;
%                                               0 1 1;
%                                               0 0 0;
%                                               0 0 0;
%                                               0 0 1]
%
%   Class support for inputs X,EDGES:
%      float: double, single
%
%   See also HIST.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $
%   Implemented in a MATLAB mex file.
%#mex
