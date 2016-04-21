function out = frmcelln(in,cols,flshrght)
%OUT = FRMCELLN( IN, COLS, FLSHRGHT )

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:55 $

  out = i_format_cell_array(in,cols,flshrght);

%
% frmcell.m function to fromat the cell array into a single string matrix
%

function formattedStringMat = i_format_cell_array(inputCellArray,colWidths,flushDirection)


% Remove carraige returns







% flushDirection=0 if the column should be truncated by removing starting chars

columnSeparator = ' ';
szeDisplay = size(inputCellArray);
numCols =  szeDisplay(2);

if(numCols~=length(colWidths) & numCols~=length(flushDirection) )
  error('Formatting does not match cell array')
end

% Remove carraige returns
%cr = regexp(inputCellArray{2},setstr(10));
%ind = find(cr);
%if ~isempty(ind)
%	keyboard
%	str = inputCellArray{2};
%	str(ind,cr(ind)) = '$';
%	str = stradd(str,' ...');
%	ind = vset([1:size(str,1)],'-',ind);
%	len = strlen(str);
%	str(ind,len(ind)-3) = 0;
%	inputCellArray{2} = str;
%end


formattedStringMat = char(zeros(szeDisplay(1),1));  % First column is junk, remove later

%
% Loop through each column
%

for k=1:numCols
  stringColumn=inputCellArray{k};
  dims = size(stringColumn);

  if(dims(2)>colWidths(k))
    if(flushDirection(k))
      outMat = stringColumn(:,1:colWidths(k));
	  zeroIndex = find(outMat == 0);
	  outMat(zeroIndex) = ' ';
	else
	  testString = stradd(stringColumn,setstr(10));  % Insert line feeds for place keeping
	  
	  % loop through rows
	  outMat = '';
	  for n=1:dims(1)
	    brk = find(testString(n,:) == 10); 
		if(brk>(colWidths(k)+1))
		  outMat = strrows(outMat,stringColumn(n,(brk-colWidths(k)):(brk-1)));
		else
		  outMat = strrows(outMat,stringColumn(n,:));
		end
	  end

	  outMat = outMat(2:end,:);
	  zeroIndex = find(outMat == 0);
	  outMat(zeroIndex) = ' ';
	end
	  
  else
    numSpacePadding = colWidths(k) - dims(2);
    if(numSpacePadding)
	  padding = char(32*ones(dims(1),numSpacePadding));
	  outMat = [stringColumn padding];
	else
	  outMat = stringColumn;
	end
	zeroIndex = find(outMat == 0);
	outMat(zeroIndex) = ' ';
  end
  
  formattedStringMat = stradd(formattedStringMat,outMat,columnSeparator);

end

formattedStringMat = formattedStringMat(:,1:(end-1));
