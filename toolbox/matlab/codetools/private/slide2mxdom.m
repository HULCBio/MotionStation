function dom = slide2mxdom(demoName)
% Convert a MATLAB style slideshow to an XML-based Document Object Model

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2003/04/24 21:25:47 $

% Ned Gulley, Feb 2001

d = feval(demoName);

% Create a new DOM
dom = com.mathworks.xml.XMLUtils.createDocument('mscript');
rootNode = dom.getDocumentElement;

for n = 1:length(d),
    textCellArray = d(n).text;
    textCellArrayNewline = cell(1,2*length(textCellArray));
    textCellArrayNewline(1:2:end) = textCellArray;
    textCellArrayNewline(2:2:end-2) = {sprintf('\n')};
    textChars = [textCellArrayNewline{:}];
    
    codeCellArray = d(n).code;
    codeCellArrayNewline = cell(1,2*length(codeCellArray));
    codeCellArrayNewline(1:2:end) = codeCellArray;
    codeCellArrayNewline(2:2:end-2) = {sprintf('\n')};
    codeChars = [codeCellArrayNewline{:}];
    
    cellNode = dom.createElement('cell');
    rootNode.appendChild(cellNode);

    % Add an text element to the cell
    textNode = dom.createElement('text');
    cellNode.appendChild(textNode);
    textTextNode = dom.createTextNode(textChars);
    textNode.appendChild(textTextNode);
    
    % Add an mcode element to the cell
    codeNode = dom.createElement('mcode');
    cellNode.appendChild(codeNode);
    codeTextNode = dom.createTextNode(codeChars);
    codeNode.appendChild(codeTextNode);
    
end
