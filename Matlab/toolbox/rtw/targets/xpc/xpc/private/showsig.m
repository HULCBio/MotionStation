function result = showsig(modelname, index)
% SHOWSIG xPCTarget private function

% Group:       Scope
%
% Syntax:      showsig('modelname')
%              showsig('modelname', index)
%              result = showsig('modelname')
%              result = showsig('modelname', index)
%
% showsig shows the index into the signal list of the xPC Target-application
% and the block path, in form of a table in the MATLAB-command window. This
% information is necessary i.e. to change the scope signal list with setsig,
% delsig or settrig.
%
% showsig('modelname') returns the whole table.
%
% showsig('modelname', index) only indicates the line, with the given text
% from the table.
%
% If showsig is given a variable, then either the signal names are returned as
% a cell array, or the signal name as a string.
%
% showsig can only be called, if the current path corresponds to the xPC
% Target-project directory, resp. if the file model.bio lies in the current
% directory.
%
% Example:      showsig('osc')
%
% See also:     setsig, delsig, settrig

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:04:39 $

%signals = getxpcbio(modelname);
signals = xpcgate('getbio',modelname);
[m, n]  = size(signals);

if (nargout == 0)
  fprintf(2, '\nNumber Signal\n\n');
  if (nargin == 1)
    for i = 1 : m
      fprintf(2, '% - 4d   % - 40s\n', i - 1, signals{i});
    end
  elseif (nargin == 2)
    fprintf(2, '% - 4d   % - 40s\n', index, signals{index + 1});
  end
  fprintf(2, '\n');
elseif (nargout == 1)
   if (nargin == 1)
     for i = 1 : m
       result{i, 1} = signals{i};
     end
   elseif (nargin == 2)
     result = signals{index + 1};
   end
end
