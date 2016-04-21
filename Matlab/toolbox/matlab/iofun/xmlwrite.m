function varargout=xmlwrite(varargin)
%XMLWRITE  Serialize an XML Document Object Model node.
%   XMLWRITE(FILENAME,DOMNODE) serializes the DOMNODE to file FILENAME.
%
%   S = XMLWRITE(DOMNODE) returns the node tree as a string.
%
%   Example:
%   % Create a sample XML document.
%   docNode = com.mathworks.xml.XMLUtils.createDocument('root_element')
%   docRootNode = docNode.getDocumentElement;
%   for i=1:20
%      thisElement = docNode.createElement('child_node');
%      thisElement.appendChild(docNode.createTextNode(sprintf('%i',i)));
%      docRootNode.appendChild(thisElement);
%   end
%   docNode.appendChild(docNode.createComment('this is a comment'));
%
%   % Save the sample XML document.
%   xmlFileName = [tempname,'.xml'];
%   xmlwrite(xmlFileName,docNode);
%   edit(xmlFileName);
%
%   See also XMLREAD, XSLT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:27:42 $

%    Advanced use:
%       FILENAME can also be a URN, java.io.OutputStream or
%                java.io.Writer object
%       SOURCE can also be a SAX InputSource, JAXP Source,
%              InputStream, or Reader object

% This is the XML that the help example creates:
% <?xml version="1.0" encoding="UTF-8"?>
% <root_element>
%     <child_node>1</child_node>
%     <child_node>2</child_node>
%     <child_node>3</child_node>
%     <child_node>4</child_node>
%     ...
%     <child_node>18</child_node>
%     <child_node>19</child_node>
%     <child_node>20</child_node>
% </root_element>
% <!--this is a comment-->

returnString = logical(0);
if length(varargin)==1
    returnString = logical(1);
    result = java.io.StringWriter;
    source = varargin{1};
else
    result = varargin{1};
    if ischar(result)
        result = xmlstringinput(result,logical(0));
    end
    
    source = varargin{2};
    if ischar(source)
        source = xmlstringinput(source,logical(1));
    end
end

% The JAXP-approved way to serialize a 
% document is to run a null transform.
% This is a JAXP-compliant static convenience method
% which does exactly that.
javaMethod('serializeXML',...
    'com.mathworks.xml.XMLUtils',...
    source,result);

if returnString
    varargout{1}=char(result.toString);
end