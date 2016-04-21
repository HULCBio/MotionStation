function varargout = makeshow(file,getcode)
%MAKESHOW  Make slideshow demo.
%   MAKESHOW DEMONAME converts the demo structure into cell script and opens it
%   in the Editor.
%
%   The structure-based slideshow format isn't supported any more.  Use the
%   Codepad menu in the editor to develop slideshows.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.32.4.1 $  $Date: 2003/04/24 21:26:00 $


if (nargin == 0)
    warning('MATLAB:makeshow:isObsolete','%s\n%s', ...
    'MAKESHOW is no longer supported.', ...
    'Use the Codepad menu in the Editor to create files for PLAYSHOW.');
    return
end

dom = slide2dom(file);
xsl = fullfile(matlabroot,'toolbox','matlab','codetools','private','mxdom2m.xsl');
code = xslt(dom,xsl,'-tostring');

if (nargin == 2)
    warning('MATLAB:makeshow:isObsolete','MAKESHOW is no longer supported.');
    varargout = {code};
else
    warning('MATLAB:makeshow:isObsolete','%s\n%s\n%s', ...
    'MAKESHOW is no longer supported.', ...
    'This demo was converted to cell script format and opened in the Editor.', ...
    'Use the Codepad menu to work with this format.');
    com.mathworks.mlservices.MLEditorServices.newDocument(code);
end

%==========================================================================
function dom = slide2dom(demoName)
% Convert a MATLAB style slideshow to an XML-based Document Object Model

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
