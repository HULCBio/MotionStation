function result = showpar(modelname, index)
% SHOWPAR xPCTarget private function

% Group:       Parameter
%
% Syntax:      showpar('modelname')
%              showpar('modelname', index)
%
% showpar gives the index into the parameter list in the MATLAB command
% window, the block path and the parameter name in form of a table. This
% information is needed i.e. to change parameters with setpar.
%
% showpar('modelname') writes the information for all the existent parameters
% into the table and displays it.
%
% showpar('modelname', index) writes the information for the parameter, with
% the given index, into the table and displays it.
%
% If showpar is given a result argument, then either the parameter names or
% the parameter name as a cell array (dimension getnpar*2 resp. 1*2) are
% returned.
%
% showpar can only be called, if the current path corresponds to the xPC
% Target-project directory, resp. if the file modelpar.m lies in the current
% directory.
%
% Example:      showpar('osc')
%
% See also:     getparindex, setpar, getpar

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/03/25 04:21:46 $

eval(['pt = ', modelname, 'pt;'], 'error(''Model does not exist'')');
npar = length(pt);

if (nargin == 1)
  fprintf(2, '\n% - 7s% - 12s% - 8s% - 30s% - 30s\n\n', ...
          'Index', 'Type', 'Size', 'Parameter Name', 'Block Name');
  index = 0;
  for i = 1 : npar
    par = pt(i);
    if ((par.nrows == 1) & (par.ncols == 1))
      fprintf(2, '% - 7d% - 12s% - 8s% - 30s% - 30s\n', ...
              index, par.subsource, 'Scalar', par.paramname, par.blockname);
      index = index + 1;
    else
      fprintf(2, '% - 7d% - 12s% - 8s% - 30s% - 30s\n', ...
              index, par.subsource, [num2str(par.nrows), '*', ...
                    num2str(par.ncols)], par.paramname, par.blockname);
      index = index + 1;
    end
  end
  fprintf(2, '\n');
else
  result = [pt(index + 1).blockname, ':', pt(index + 1).paramname];
end
