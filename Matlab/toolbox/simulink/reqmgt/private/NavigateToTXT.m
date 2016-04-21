function NavigateToTXT(fileName, id)

% Copyright 2004 The MathWorks, Inc.

	% Assume no id
	lineNum = 0;

	% Find id
	if ~isempty(id)
		fid = fopen(fileName);
		i   = 1;
		while lineNum == 0
			lineStr = fgetl(fid);
			if ~isempty(strfind(lineStr, id))
				lineNum = i;
			end;
			if ~ischar(lineStr), break, end;
			i = i + 1;
		end;
		fclose(fid);
	end;

	% Open editor to that line
	openTextFileToLine(fileName, lineNum);


function openTextFileToLine(fileName, lineNum)

	if lineNum > 0
		err = javachk('mwt', 'The MATLAB Editor');
		if isempty(err)
			editor = com.mathworks.mlservices.MLEditorServices;
			editor.openDocumentToLine(fileName, lineNum);
		end;
	else
		edit(fileName);
	end;
