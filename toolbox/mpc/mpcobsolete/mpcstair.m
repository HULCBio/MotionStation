function out=mpcstair(in,istime)

%MPCSTAIR Turns an array into a stair-step function for plotting.
%
%	out=mpcstair(in)
%
%Rows of "in" are assumed to contain the function at successive
%time points.
%
%If "istime" is supplied as non-zero, "in" is assumed to be a
%time vector.  The result is then a "stairstep" time vector
%that can be used when plotting a stairstep function.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin < 1
   error('Must supply at least one input argument')
elseif nargin > 2
   error('Too many input arguments')
end

[n,m]=size(in);

if nargin == 1
   ix=[reshape([1:n-1;1:n-1],2*(n-1),1);n];
elseif istime == 0
   ix=[reshape([1:n-1;1:n-1],2*(n-1),1);n];
else
   ix=[1;reshape([2:n;2:n],2*(n-1),1)];
end

out=in(ix,:);