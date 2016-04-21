function B = uintlut(varargin)
%UINTLUT computes new values of A based on lookup table LUT.
%   UINTLUT(A,LUT) creates an array containing new values of A based on the
%   lookup table, LUT.  For example, if A is a vector whose kth element is equal
%   to alpha, then B(k) is equal to the LUT value corresponding to alpha, i.e.,
%   LUT(alpha+1).
%
%   Class Support
%   -------------
%   A must be uint8 or uint16. If A is uint8, then LUT must be a uint8 vector
%   with 256 elements.  If A is uint16, then LUT must be a uint16 vector with
%   65536 elements. B has the same size and class as A.
%
%
%   Example
%   -------
%        A = uint8([1 2 3 4; 5 6 7 8;9 10 11 12]);
%        LUT = repmat(uint8([0 150 200 255]),1,64);
%        B = uintlut(A,LUT);
%        imview(A),imview(B);

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/05/03 17:52:43 $

B = uintlutc(varargin{:});
