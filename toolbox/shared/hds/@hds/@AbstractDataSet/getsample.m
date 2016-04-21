function s = getsample(this,GridSection,Vars)
%GETSAMPLE  Extract data points from a data set.
%
%   S = GETSAMPLE(D) serializes D into a structure array S with one 
%   field per variable.
%
%   S = GETSAMPLE(D,I) extracts the I-th data point in the data set.
%
%   S = GETSAMPLE(D,{I1,..,IN}) extracts all data associated with the 
%   portion of the grid defined by the vectors of indices I1,...,IN
%   relative to each grid dimension.
%
%   S = GETSAMPLE(D,...,VARS) includes only the variables VARS (cell
%   array of names or vector of @variable handles).

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:10 $
ni = nargin;

% Error checking
GridSize = getGridSize(this);
ndims = length(GridSize);
if any(GridSize==0)
   error('Not available until grid is fully specified.')
end
   
% Build list of variables to be included
% RE: Follows data links one level down
[VarPool,ContainerPool,LinkIndex] = utGetVisibleVars(this);

% Process inputs
if ni==2 && (isa(GridSection,'hds.variable') || iscellstr(GridSection))
   Vars = GridSection;
   GridSection = repmat({':'},[1 ndims]);
else
   if ni<2
      GridSection = repmat({':'},[1 ndims]);
   end
   if ni<3,
      Vars = VarPool;
   end
end

% Validate specified variable
if ~isequal(Vars,VarPool)
   try
      idx = locate(VarPool,Vars);
   catch
      rethrow(lasterror)
   end
   Vars = VarPool(idx);
   Containers = ContainerPool(idx);
   LinkIndex = LinkIndex(idx);
else
   Containers = ContainerPool;
end

% Process requested grid section
% Result is a cell array of integer-valued index vectors of length 1
% (absolute index) or with as many entries as grid dimensions
if ~isa(GridSection,'cell')
   GridSection = {GridSection};
end
if length(GridSection)==1
   % Absolute index
   gsize = prod(GridSize);
   ndims = 1;
elseif length(GridSection)~=ndims
   error('Number of index vectors does not match number of grid dimensions.')
else
   gsize = GridSize;
end
for ct=1:ndims
   if strcmp(GridSection{ct},':')
      GridSection{ct} = 1:gsize(ct);
   elseif isa(GridSection{ct},'logical')
      GridSection{ct} = find(GridSection{ct});
   end
   idx = GridSection{ct};
   if ~isnumeric(idx) || ~isequal(round(idx),idx) || any(idx<0) || any(idx>gsize(ct))
      error('Invalid vector of indices.')
   end
end

% Initialize output structure
fn = get(Vars,{'Name'});  % field names
fv = cell(size(fn));      % field values
idxV = find(LinkIndex==0);
idxL = unique(LinkIndex(LinkIndex>0));
GridVarMap = utGridVarMap(this,Vars);
SectionSize = cellfun('length',GridSection);

% Process root-level variables and links
for ctx=1:length(idxV)
   ct = idxV(ctx);
   gdim = GridVarMap(ct);
   if gdim==0
      % Regular variable or data link
      Slice = Containers(ct).getSlice(GridSection,'cell');
   elseif length(GridSection)==1
      % Absolute indexing for grid variable
      pIdx = this.utGridProject(GridSection{1},GridSize,gdim);
      Slice = Containers(ct).getSlice({pIdx},'cell');
   else
      % Multi-indexing for grid variable
      gSlice = Containers(ct).getSlice(GridSection(gdim),'cell');
      Slice = this.utGridFill(gSlice,SectionSize,gdim);
   end
   if isempty(Slice)
      fv{ct} = [];
   else
      fv{ct} = Slice;
   end
end

% Construct structure array
c = [fn' ; fv'];
s = struct(c{:});

% Add depth-one variables for transparent links
for ct=1:length(idxL)
   % Gather values for all variables immediately reachable through link
   idx = find(LinkIndex==idxL(ct));
   Container = Containers(idx(1));
   v = Vars(idx);
   Slice = Container.getSlice(GridSection,v); % struct array
   if ~isempty(Slice)
      for ctv=1:length(v)
         vn = v(ctv).Name;
         % REVISIT  {s.(vn)} = {Slice.(vn)}
         for ct=1:numel(Slice)
            s(ct).(vn) = Slice(ct).(vn);
         end
      end
   end
end

