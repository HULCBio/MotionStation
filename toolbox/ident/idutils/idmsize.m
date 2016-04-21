function maxdef = idmsize(N,d)
%IDMSIZE   Sets default value for the variable maxsize 
%   See IDPROPS ALGORITHM.
%
%   maxdef = idmsize(N,d)
%
%   N : Number of data points to be processed
%   d : Number of parameters to be estimated
%   maxdef : Default value of maxsize
%
%   USERS WHO WORK WITH VERY LARGE DATA RECORDS AND LARGE MODELS SHOULD
%   TRIM THIS ALGORITHM TO HIS OR HER COMPUTER

%   L. Ljung 10-1-89
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:56 $

if nargin<2,
	d=6;
end
if nargin<1,
	N=1000;
end
[cmp,mem] = computer;
if mem<8192, 
	maxdef = 4096;
 else
	 maxdef = 250000;
 end
% The value of maxdef that gives the most efficient computing time
% in the parameter estimation algorithms depends on the memory available
% in the computer.
% The algorithms will work with matrices that are N by d, provided the
% number of elements is less than maxsize. Note that the number d is
% not provided by all of teh estimation algorithms.
