function [varargout] = balance(varargin)
%BALANCE Diagonal scaling to improve eigenvalue accuracy.
%   [T,B] = BALANCE(A) finds a similarity transformation T such
%   that B = T\A*T has, as nearly as possible, approximately equal
%   row and column norms.  T is a permutation of a diagonal matrix
%   whose elements are integer powers of two so that the balancing
%   doesn't introduce any round-off error.
%
%   B = BALANCE(A) returns the balanced matrix B.
%
%   [S,P,B] = BALANCE(A) returns the scaling vector S and the
%   permutation vector P separately.  The transformation T and 
%   balanced matrix B are obtained from A,S,P by 
%      T(:,P) = diag(S),    B(P,P) = diag(1./S)*A*diag(S).
%   
%   To scale A without permuting its rows and columns, use
%   the syntax BALANCE(A,'noperm').
%
%   See also EIG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.3 $  $Date: 2004/04/16 22:07:16 $
%   Built-in function.

if nargout == 0
  builtin('balance', varargin{:});
else
  [varargout{1:nargout}] = builtin('balance', varargin{:});
end
