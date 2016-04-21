function [varargout] = colon(varargin)
%:  Colon.
%   J:K  is the same as [J, J+1, ..., K].
%   J:K  is empty if J > K.
%   J:D:K  is the same as [J, J+D, ..., J+m*D] where m = fix((K-J)/D).
%   J:D:K  is empty if D > 0 and J > K or if D < 0 and J < K.
%
%   COLON(J,K) is the same as J:K and COLON(J,D,K) is the same as J:D:K.
%
%   The colon notation can be used to pick out selected rows, columns
%   and elements of vectors, matrices, and arrays.  A(:) is all the
%   elements of A, regarded as a single column. On the left side of an
%   assignment statement, A(:) fills A, preserving its shape from before.
%   A(:,J) is the J-th column of A.  A(J:K) is [A(J),A(J+1),...,A(K)].
%   A(:,J:K) is [A(:,J),A(:,J+1),...,A(:,K)] and so on.
%
%   The colon notation can be used with a cell array to produce a comma-
%   separated list.  C{:} is the same as C{1},C{2},...,C{end}.  The comma
%   separated list syntax is valid inside () for function calls, [] for
%   concatenation and function return arguments, and inside {} to produce
%   a cell array.  Expressions such as S(:).name produce the comma separated
%   list S(1).name,S(2).name,...,S(end).name for the structure S.
%
%   For the use of the colon in the FOR statement, See FOR.
%   For the use of the colon in a comma separated list, See VARARGIN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:07:42 $

if nargout == 0
  builtin('colon', varargin{:});
else
  [varargout{1:nargout}] = builtin('colon', varargin{:});
end
