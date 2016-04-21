function opentoline(fileName, lineNumber)
%OPENTOLINE Open to specified line in function file in the editor.
%   OPENTOLINE(FILENAME, LINENUMBER)
%   Helper function to PROFVIEW.
%
%   See also PROFVIEW.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:24:17 $
%   Ned Gulley, Mar 2002

com.mathworks.mlservices.MLEditorServices.openDocumentToLine(fileName, lineNumber, 1, 1)
% The third and fourth arguments to openDocumentToLine bring the window to the front
% and highlight the selected line number.