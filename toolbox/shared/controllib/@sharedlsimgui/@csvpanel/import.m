function import(h,inputtable,varargin)
%IMPORT Imports data from csvpanel to inputtable
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:31 $

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

sheetObj = h.csvsheet;
selectedCols = double(sheetObj.STable.getSelectedColumns);
    
if ~isempty(selectedCols)
    rawdata = csvread(sheetObj.filename);
    rawdata = rawdata(:,selectedCols);
   
    % empty rawdata means the import failed. 
    if isempty(rawdata)
        return
    end    
    copyStruc = struct('data',rawdata,'source','csv','length',size(rawdata,1),'subsource',...
        '','construction',sheetObj.filename,'columns',selectedCols,'transposed',false);   
else
    return
end

% Copy to clipboard or intert into table
if nargin==3 && strcmp(varargin{1},'copy')
    inputtable.copieddatabuffer = copyStruc;
    inputtable.STable.getModel.setMenuStatus([1 1 1 1 1]);
else    
	numpastedrows = inputtable.pasteData(copyStruc);
	% if >= 1 rows were sucessfuly imported then bring the lsim gui into focus
	if numpastedrows > 0
		inputtable.setFocus
	end
end