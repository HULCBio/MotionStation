function ndx = sub2ind(siz,varargin)
%SUB2IND Linear index from multiple subscripts.
%   SUB2IND is used to determine the equivalent single index
%   corresponding to a given set of subscript values.
%
%   IND = SUB2IND(SIZ,I,J) returns the linear index equivalent to the
%   row and column subscripts in the arrays I and J for an matrix of
%   size SIZ. If any of I or J is empty, and the other is empty or scalar,
%   SUB2IND returns an empty matrix.
%
%   IND = SUB2IND(SIZ,I1,I2,...,In) returns the linear index
%   equivalent to the N subscripts in the arrays I1,I2,...,In for an
%   array of size SIZ.
%
%
%   See also IND2SUB.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $  $Date: 2003/11/24 23:23:58 $
%==============================================================================

if length(siz)<2
        error('MATLAB:sub2ind:InvalidSize',...
            'Size vector must have at least 2 elements.');
end

%Adjust input
if length(siz)<=nargin-1
    %Adjust for trailing singleton dimensions
    siz = [siz ones(1,nargin-length(siz)-1)];
else
    %Adjust for linear indexing on last element
    siz = [siz(1:nargin-2) prod(siz(nargin-1:end))];
end

% if any subscript vectors are empty, the linear index is the appropriate
% sized empty double.
mt = cellfun('isempty',varargin);
if any(mt)
    if any(cellfun('length',{varargin{~mt}})>1)
        error('MATLAB:sub2ind:SubscriptNotScalar',...
            'All other indices must be scalar when one is empty.')
    end
    ndx = zeros(~mt);
    return;
end

%Compute linear indices
k = [1 cumprod(siz(1:end-1))];
ndx = 1;
s = size(varargin{1}); %For size comparison
for i = 1:length(siz),
    v = varargin{i};
    %%Input checking
    if ~isequal(s,size(v))
        %Verify sizes of subscripts
        error('MATLAB:sub2ind:SubscriptVectorSize',...
            'The subscripts vectors must all be of the same size.');
    end
    if (any(v(:) < 1)) || (any(v(:) > siz(i)))
        %Verify subscripts are within range
        error('MATLAB:sub2ind:IndexOutOfRange','Out of range subscript.');
    end
    ndx = ndx + (v-1)*k(i);
end
