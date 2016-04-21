function I = tssorttime(time,varargin)
%TSSORTTIME Utility to sort time vector and detect duplicate records
%
%   Author(s): J. G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:34:14 $
%
% Sort time numeric or cell array datestr data, remove duplicate 
% samples with identical data. Time must be numeric. If a data vector is
% supplied this function will error out if duplicate time records exist
% with non duplicate data 

if nargin==2
    data = varargin{1};
    s = hdsGetSize(data);
    if s(1)~=length(time) && s(end)~=length(time)
        error('tssorttime:mismatch','Mismatching time and data matrices')
    end
end

% Convert datestr times to numeric vector
if iscell(time)
    time = datenum(time);
end

% Sort time
if ~issorted(time)
   [time I] = sort(time);
   if nargin==2
       % Slice data
       if s(1)==length(time)
           data = hdsGetSlice(data,[{I} repmat({':'}, [1 length(s)-1])]);
       else
           data = hdsGetSlice(data,[{I} repmat({':'}, [1 length(s)-1])]);
       end
       if isa(data,'timeddata.ArrayAdaptor')
           try
              data = double(data); % Apply @DoubleArrayAdaptor "double" cast
           catch
              error('Cannot compare overlapping records since ordinate objects cannot be cast as doubles')
           end
       end
   end
else 
   I = (1:length(time))';
end

% Collapse duplicate times
J = abs(time(2:end)-time(1:end-1))<eps;
if sum(J)>0
    if nargin==2 && max(norm(data(find(J)+1,:)-data(find(J),:)))>eps
        error('Duplicate times with non-duplicate data')
    else 
        I = [I(1); I(find(~J)+1)];
        warning('Duplicate records are detected and have been merged.')
    end
end

