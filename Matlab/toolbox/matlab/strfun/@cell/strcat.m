function t = strcat(varargin)
%STRCAT String horizontal concatenation.
%   T = STRCAT(S1,S2,...), when any of the inputs is a cell array of 
%   strings, returns a cell array of strings formed by concatenating
%   corresponding elements of S1,S2, etc.  The inputs must all have
%   the same size (or any can be a scalar). 

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/03/08 02:02:14 $

if nargin<1, error('Not enough input arguments.'); end

% Make sure everything is a cell array
maxsiz = [1 1];
emptyIdx = [];
for i=1:nargin,
  if (isempty(varargin{i}))
    emptyIdx(i) = i;
  end
  if ischar(varargin{i}),
    varargin{i} = cellstr(varargin{i});
  end
  siz{i} = size(varargin{i});
  if prod(siz{i})>prod(maxsiz),
     maxsiz = siz{i};
  end
  tf(i) = iscell(varargin{i});
end

if ~isempty(emptyIdx)
   emptyIdx = find(emptyIdx);
   varargin(emptyIdx) = [];
   tf(emptyIdx) = [];
   siz(emptyIdx) = [];
end

if ~all(tf), error('Inputs must be cell arrays or strings.'); end

% Scalar expansion
for i=1:length(varargin),
  if prod(siz{i})==1, 
    varargin{i} = varargin{i}(ones(maxsiz));
    siz{i} = size(varargin{i});
  end
end

if ((numel(siz) > 1) & ~isequal(siz{:})), 
  error('All the inputs must be the same size or scalars.');
end

s = cell([length(varargin) maxsiz]);
for i=1:length(varargin),
  s(i,:) = varargin{i}(:);
end

t = cell(maxsiz);
for i=1:prod(maxsiz),
  t{i} = [s{:,i}];
end
