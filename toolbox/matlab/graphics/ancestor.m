function p = ancestor(p,type,varargin)
%ANCESTOR  Get object ancestor.
%    P = ANCESTOR(H,TYPE) returns the handle of the ancestor of h of one of
%    the types in TYPE, or empty if none exists. TYPE may be a single
%    string (single type) or cell array of strings (types). If H is
%    a vector of handles the P is a cell array of the same length
%    as H and P{n} is the ancestor of H(n).
%    P = ANCESTOR(H,TYPE,'TOPLEVEL') finds the highest level ancestor of
%    one of the types in TYPE
%
%    If H is not an Handle Graphics object, ANCESTOR returns empty.
%
%  Examples:
%    p = ancestor(gca,'figure');
%    p = ancestor(gco,{'hgtransform','hggroup','axes'},'toplevel');

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2004/04/10 23:28:35 $

nargchk(2,4,nargin);

if ~ishghandle(p)
    p = [];
    return;
end

if length(p) > 1
  n = length(p);
  pv = cell(n,1);
  for k=1:n
    pv{k} = ancestor(p(k),type,varargin{:});
  end
  p = pv;
  return;
end

if nargin==2 % ancestor(h,type)
    while ~isempty(p) && ~isatype(p,type)
        p = get(handle(p),'parent');
    end
elseif nargin==3 % ancestor(h,type,'toplevel')
    P=[];
    if isatype(p,type)
        P = p;
    end
    while ~isempty(p)
        p = get(handle(p),'parent');
        if isatype(p,type)
            P = p;
        end
    end
    p=P;
end

%-------------------------------------------------------------%
function istype=isatype(h,type)

istype = false;
if ischar(type) % ancestor(h,'type'..)
    if strcmpi(get(h,'type'),type) ||...
            isa(handle(h),type)
        istype=true;
    end
else % ancestor(h,{'type1','type2',..}...)
    % % make sure it's a cell array
    % type = cellstr(type);
    if any(strcmpi(get(h,'type'),type))
        istype = true;
    else
        % check each cell
        for k=1:length(type)
            if isa(handle(h),type{k})
                istype=true;
            end
        end
    end
end
