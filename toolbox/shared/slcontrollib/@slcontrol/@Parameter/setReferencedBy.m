function setReferencedBy(this, model, varargin)
% SETREFERENCEDBY Checks whether the parameter is referenced by the MODEL.
% Sets the ReferencedBy property to a cell array of names of all the
% referring blocks.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:56 $

if isempty(varargin)
   % Check whether the model is open.
   if isempty( find_system( 'SearchDepth', 0, 'Name', model ) )
      error( 'Unable to locate block diagram ''%s''.', model );
   end
   % Get the list of all referenced variables.
   try
      vars = get_param(model, 'ReferencedWSVars');
   catch
      error('\nUnable to get block information from model ''%s''.\n', model);
   end
   % No variables in the model.
   if isempty(vars)
      fprintf('There are no parameters in block diagram ''%s''.\n', model);
      return
   end
   this.ReferencedBy = LocalSetReferencedBlocks(this, vars, model);
else
   % Straight assignment
   this.ReferencedBy = varargin{1};
end

% ----------------------------------------------------------------------------- %
function ParRefs = LocalSetReferencedBlocks(this, bwParams, model)
% Handles to all blocks that refer to this parameter
bwNames = {bwParams.Name};

idx = find( strcmp(this.Name, bwNames) );
ParRefs = {};
  
% Chech whether the parameter is referenced in the model
if ~isempty(idx)
  % Referring blocks
  blks = handle( bwParams(idx).ReferencedBy );

  % Construct reference display
  nb = length(blks);
  refs = cell(nb,1);
  for ctb = 1:nb
    refs{ctb} = blks(ctb).getFullName;
  end
  ParRefs = regexprep(refs, '\n\r?', ' ');
else
  fprintf('The parameter ''%s'' is not used in block diagram ''%s''.\n', ...
          this.Name, model);
end
