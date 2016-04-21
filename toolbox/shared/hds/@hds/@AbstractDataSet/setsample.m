function setsample(this,GridSection,s)
%SETSAMPLE  Modifies data points in data set.
%
%   SETSAMPLE(D,I,S) modifies the I-th data point in the data set.
%
%   SETSAMPLE(D,{I1,..,IN},S) modifies the data associated with the
%   portion of the grid defined by the vectors of indices I1,...,IN
%   relative to each grid dimension.
%
%   In both cases, S is a structure array whose fields are named after
%   the variables to be modified.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:19 $

% Error checking
GridSize = getGridSize(this);
ngdim = length(GridSize);
if any(GridSize==0)
   error('Not available until grid is fully specified.')
end
   
% Build list of variables to be included
% REVISIT: follows links one level down
[VarPool,ContainerPool,LinkIndex] = utGetVisibleVars(this);

% Locate modified variables
Vars = fieldnames(s);
try
   idx = locate(VarPool,Vars);
catch
   rethrow(lasterror)
end
Vars = VarPool(idx);
Containers = ContainerPool(idx);
LinkIndex = LinkIndex(idx);

% Process requested grid section
% Result is a cell array of integer-valued index vectors of length 1
% (absolute index) or with as many entries as grid dimensions
if ~isa(GridSection,'cell')
   GridSection = {GridSection};
end
if length(GridSection)==1
   % Absolute index
   gsize = prod(GridSize);
   ngdim = 1;
elseif length(GridSection)~=ngdim
   error('Number of index vectors does not match number of grid dimensions.')
else
   gsize = GridSize;
end
for ct=1:ngdim
   if strcmp(GridSection{ct},':')
      GridSection{ct} = 1:gsize(ct);
   elseif isa(GridSection{ct},'logical')
      GridSection{ct} = find(GridSection(ct));
   end
   idx = GridSection{ct};
   if ~isnumeric(idx) || ~isequal(round(idx),idx) || any(idx<0) || any(idx>gsize(ct))
      error('Invalid vector of indices.')
   end
end

% Consistency check  
SectionSize = cellfun('length',GridSection);
if prod(size(s))~=prod(SectionSize)
   error('Size mismatch between sample array and specified portion of the grid.')
end

% Update data
c = struct2cell(s(:));
GridVarMap = utGridVarMap(this,Vars);
idxV = find(LinkIndex==0);
idxL = unique(LinkIndex(LinkIndex>0));

% Process root-level variables and links
idx = cell(1,ndims(s));
for ctx=1:length(idxV)
   ct = idxV(ctx);
   gdim = GridVarMap(ct);
   try
      if gdim==0
         % Regular variable
         Containers(ct).setSlice(GridSection,reshape(c(ct,:),size(s)),GridSize);
      elseif length(GridSection)==1
         % Absolute indexing for grid variable
         pIdx = this.utGridProject(GridSection{1},GridSize,gdim);
         Containers(ct).setSlice({pIdx},c(ct,:),[GridSize(gdim) 1])
      else
         % Multi-indexing for grid variable
         idx(:) = {1};
         idx{gdim} = ':';
         gc = struct2cell(squeeze(s(idx{:})));
         Containers(ct).setSlice(GridSection(gdim),gc(ct,:),[GridSize(gdim) 1]);
      end
   catch
      error(sprintf('Data for variable %s is of the wrong type or size.',Vars(ct).Name))
   end
end

% Process depth-one variables for transparent links
for ct=1:length(idxL)
   % Gather values for all variables immediately reachable through link
   idx = find(LinkIndex==idxL(ct));
   Container = Containers(idx(1));
   try
      Container.setSlice(GridSection,s,GridSize,Vars(idx));
   catch
      error(sprintf('Invalid data for dependent data sets with alias %s',Container.Alias))
   end
end
