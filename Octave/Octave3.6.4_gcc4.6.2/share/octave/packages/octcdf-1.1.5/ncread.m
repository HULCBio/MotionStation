% x = ncread(filename,varname)
% x = ncread(filename,varname,start,count,stride)
% read the variable varname from file filename.
% The parameter start contains the starting indices, count
% is the number of elements and stride the increment between
% two successive elements (default 1).

function x = ncread(filename,varname,start,count,stride)

nc = netcdf(filename,'r');
nv = nc{varname};
sz = size(nv); sz = sz(end:-1:1);

% number of dimenions
%nd = length(sz);
nd = length(dim(nv));

if nargin == 2
  start = ones(1,nd);
  count = inf*ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end

% replace inf in count
i = count == inf;
count(i) = (sz(i)-start(i))./stride(i) + 1;

% end index

endi = start + (count-1).*stride;

% replace inf in count

%i = endi == inf;
%endi(i) = sz(i);


% load data

% subsref structure
subsr.type = '()';
subsr.subs = cell(1,nd);
for i=1:nd
  subsr.subs{nd-i+1} = start(i):stride(i):endi(i);
end
%start,endi

x = subsref(nv,subsr);

% apply attributes

factor = nv.scale_factor(:);
offset = nv.add_offset(:);
fv = nv.FillValue_;

if ~isempty(fv)
  x(x == fv) = NaN;
else
  fv = nv.missing_value;
  
  if ~isempty(fv)
    x(x == fv) = NaN;
  end  
end

if ~isempty(factor)
  x = x * factor;
end

if ~isempty(offset)
  x = x + offset;
end

x = permute(x,[ndims(x):-1:1]);
x = reshape(x,count);
close(nc)


%% Copyright (C) 2012 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.
