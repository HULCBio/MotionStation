function D = slice(this,idx,vars)
%SLICE  Extracts portion of a spreadsheet.
%
%   S2 = SLICE(S,IDX) extracts all rows with indices IDX.
%   
%   S2 = SLICE(S,IDX,VARS) extracts the rows with indices IDX
%   and the columns associated with the variables VARS.
%   VARS can be specified as a vector of indices, a cell array
%   of strings, or a vector of @variable objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:37 $

% Parse variable input
Variables = getvars(this);
if nargin==2
   vars = Variables;
   idxv = 1:length(Variables);
elseif isnumeric(vars)
   if islogical(vars)
      idxv = find(vars);
   else
      idxv = vars;
   end
   try
      vars = vars(idxv);
   catch
      rethrow(lasterror)
   end
else
   idxv = locate(Variables,vars);
   vars = Variables(idxv);
end
% Variables should be unique
if length(unique(idxv))<length(idxv)
   error('Variables cannot be repeated.')
end

% Process row index
if islogical(idx)
   idx = find(idx);
elseif ischar(idx)
   idx = 1:this.Grid_.Length;
end
   
% Create new spreadsheet
D = hds.spreadsheet;
for ct=1:length(vars)
   D.addvar(vars(ct));
end

% Copy grid info
D.Grid_ = this.Grid_;
D.Grid_.Length = length(idx);

% Copy data for selected rows/columns
Data = D.Data_;
for ctv=1:length(idxv)
   ct = idxv(ctv);
   Data(ctv).GridFirst = this.Data_(ct).GridFirst;
   Data(ctv).SampleSize = this.Data_(ct).SampleSize;
   Data(ctv).Data = getSlice(this.Data_(ct),{idx});
end