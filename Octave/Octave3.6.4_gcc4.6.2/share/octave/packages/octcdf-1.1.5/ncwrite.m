% ncwrite(filename,varname,x)
% ncwrite(filename,varname,x,start,stride)
% write the variable varname to file filename.
% The parameter start contains the starting indices 
% and stride the increment between
% two successive elements (default 1).

function ncwrite(filename,varname,x,start,stride)

nc = netcdf(filename,'w');
nv = nc{varname};

% number of dimenions
nd = length(dim(nv));

% sz size (padded with ones)
sz = ones(1,nd);
tmp = size(x);
sz(1:length(tmp)) = tmp;

if nargin == 3
  start = ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end

% end index

endi = start + (sz-1).*stride;


% save data

% subsref structure
subsr.type = '()';
subsr.subs = cell(1,nd);
for i=1:nd
  subsr.subs{nd-i+1} = start(i):stride(i):endi(i);
end
%start,endi


% apply attributes

factor = nv.scale_factor(:);
offset = nv.add_offset(:);
fv = nv.FillValue_(:);

if ~isempty(offset)
  x = x - offset;
end

if ~isempty(factor)
  x = x / factor;
end

if ~isempty(fv)
  x(isnan(x)) = fv;
else
  fv = nv.missing_value;
  
  if ~isempty(fv)
    x(isnan(x)) = fv;
  end  
end

x = permute(x,[ndims(x):-1:1]);

nv = subsasgn(nv,subsr,x);
close(nc)

