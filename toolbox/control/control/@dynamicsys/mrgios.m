function [InputNames,OutputNames,EmptySys] = mrgios(varargin)
%MRGIOS  Compiles master I/O name list from I/Os of individual models.
%
%   [INPUTNAMES,OUTPUTNAMES] = MRGIOS(SYS1,SYS2,...) returns I/O names 
%   for the minimal axes grid containing all the systems SYS1, SYS2,...
%
%   LOW-LEVEL UTILITY.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:30 $
nsys = length(varargin);
if nsys==1
   % Single model
   sys = varargin{1};
   InputNames = sys.InputName;
   OutputNames = sys.OutputName;
   EmptySys = (isempty(InputNames) || isempty(OutputNames));
else
   % Merge name
   InputNameList = cell(1,nsys);
   OutputNameList = cell(1,nsys);
   for ct=1:nsys
      sys = varargin{ct};
      InputNameList{ct} = sys.InputName;
      OutputNameList{ct} = sys.OutputName;
   end
   % Detect empty systems
   Ninputs = cellfun('length',InputNameList);
   Noutputs = cellfun('length',OutputNameList);
   EmptySys = (Ninputs==0 | Noutputs==0);
   % Merge names
   InputNames = LocalGetNames(InputNameList,Ninputs);
   OutputNames = LocalGetNames(OutputNameList,Noutputs);
end

% Always make sure the I/O sizes are nonzero
if isempty(InputNames)
   InputNames = {''};
end
if isempty(OutputNames)
   OutputNames = {''};
end   

%--------------------- Local Functions ----------------------------

function names = LocalGetNames(namelist,nio)
% Compiles i/o names of individual models into master i/o name list NAMES.

% RE: The global names are picked as follows
%     1) Pick models with maximal input (resp., output) size
%     2) Among these, consider only models with all their i/o names defined
%        (model set M)
%     3) Clear all names if there are naming conflicts among models in M
% Note that 
%   * Rule 1) is needed to ensure that conflicting input names (e.g., du and dy)
%     don't result in 1x2 plot.
%   * Rule 3) is needed because there is no rigorous remapping algorithm for partial 
%     matches
%   * The resulting global I/O names should be either all defined or all empty, 
%     otherwise models in M may be mapped incorrectly (mapping algorithm ignores 
%     partial matches and mapped to upper left corner of axes grid)
%   * For this reason, name conflicts for models outside the M set are ignored 
%     and should not result in partial clearing of the global names.

% Pick models with maximal i/o size and fully specified i/o names
niomax = max(1,max(nio));  % watch for empty models
fsn = (nio == niomax);
for ct=find(fsn)
   fsn(ct) = all(cellfun('length',namelist{ct}));
end

% Aggregate names of sources with fully specified i/o names
idx = find(fsn);
if isempty(idx)
   names(1:niomax,1) = {''};
else
   names = namelist{idx(1)};
   for ct=idx(2:end)
      names(~ismember(names,namelist{ct}),:) = {''};
   end
end
