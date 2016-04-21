function [varargout] = conv2(varargin)
%CONV2 Two dimensional convolution.
%   C = CONV2(A, B) performs the 2-D convolution of matrices
%   A and B.   If [ma,na] = size(A) and [mb,nb] = size(B), then
%   size(C) = [ma+mb-1,na+nb-1].
%   C = CONV2(H1, H2, A) convolves A first with the vector H1 
%   along the rows and then with the vector H2 along the columns.
%
%   C = CONV2( ... ,'shape') returns a subsection of the 2-D
%   convolution with size specified by 'shape':
%     'full'  - (default) returns the full 2-D convolution,
%     'same'  - returns the central part of the convolution
%               that is the same size as A.
%     'valid' - returns only those parts of the convolution
%               that are computed without the zero-padded
%               edges. size(C) = [ma-mb+1,na-nb+1] when
%               all(size(A) >= size(B)), otherwise C is empty.
%
%   See also CONV, CONVN, FILTER2 and, in the Signal Processing
%   Toolbox, XCORR2.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.21.4.2 $  $Date: 2004/04/16 22:04:39 $
%   Built-in function.

if nargout == 0
  builtin('conv2', varargin{:});
else
  [varargout{1:nargout}] = builtin('conv2', varargin{:});
end
