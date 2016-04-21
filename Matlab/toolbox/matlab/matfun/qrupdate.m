function [varargout] = qrupdate(varargin)
%QRUPDATE Rank 1 update to QR factorization.
%   If [Q,R] = QR(A) is the original QR factorization of A, then
%   [Q1,R1] = QRUPDATE(Q,R,U,V) returns the QR factorization of A + U*V',
%   where U and V are column vectors of appropriate lengths.
%
%   QRUPDATE works only for full matrices.
%
%   See also QR, QRINSERT, QRDELETE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/16 22:07:30 $
%   Built-in function.

if nargout == 0
  builtin('qrupdate', varargin{:});
else
  [varargout{1:nargout}] = builtin('qrupdate', varargin{:});
end
