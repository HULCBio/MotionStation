function [varargout] = permute(varargin)
%PERMUTE Permute array dimensions.
%   B = PERMUTE(A,ORDER) rearranges the dimensions of A so that they
%   are in the order specified by the vector ORDER.  The array produced
%   has the same values of A but the order of the subscripts needed to 
%   access any particular element are rearranged as specified by ORDER.
%   The elements of ORDER must be a rearrangement of the numbers from
%   1 to N.
%
%   PERMUTE and IPERMUTE are a generalization of transpose (.') 
%   for N-D arrays.
%
%   Example
%      a = rand(1,2,3,4);
%      size(permute(a,[3 2 1 4])) % now it's 3-by-2-by-1-by-4.
%
%   See also IPERMUTE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.2 $  $Date: 2004/04/16 22:05:15 $
%   Built-in function.

if nargout == 0
  builtin('permute', varargin{:});
else
  [varargout{1:nargout}] = builtin('permute', varargin{:});
end
