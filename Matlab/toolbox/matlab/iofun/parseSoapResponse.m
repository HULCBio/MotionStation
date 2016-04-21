function result = parseSoapResponse(response)
%PARSESOAPRESPONSE Convert the response from a SOAP server into MATLAB types.
%   parseSoapResponse(RESPONSE) converts RESPONSE, a string returned by a SOAP
%   server, into a cell array of approprate MATLAB datatypes.
%    
%   Example:
%
%   m = createSoapMessage( ...
%       'urn:xmethodsBabelFish', ...
%       'BabelFish', ...
%       {'en_it','Matthew thinks you''re nice.'}, ...
%       {'translationmode','sourcedata'}, ...
%       repmat({'{http://www.w3.org/2001/XMLSchema}string'},1,2));
%   
%   response = callSoapService( ...
%       'http://services.xmethods.net:80/perl/soaplite.cgi', ...
%       'urn:xmethodsBabelFish#BabelFish', ...
%        m);
%
%   results = parseSoapResponse(response)
%
%   See also createClassFromWsdl, callSoapService, createSoapMessage.


% Matthew J. Simoneau, June 2003
% $Revision: 1.1.6.3 $  $Date: 2004/03/26 13:26:32 $
% Copyright 1984-2004 The MathWorks, Inc.

% Extract the meat from the SOAP message.
d = org.apache.xerces.parsers.DOMParser;
d.parse(org.xml.sax.InputSource(java.io.StringReader(response)));
response = d.getDocument;

% Assume the body is the last child of the response we receive.
envelope = response.getFirstChild;
soapBody = envelope.getFirstChild;
while ~isempty(soapBody.getNextSibling)
    soapBody = soapBody.getNextSibling;
end

% Pull the result node out of the SOAP Body.
resultNode = soapBody.getFirstChild;

% Convert XML to a cell array of appropriate MATLAB values.
resultChild = resultNode.getFirstChild;
result = {};
while ~isempty(resultChild)
    result{end+1} = convert(resultChild);
    resultChild = resultChild.getNextSibling;
end

%===============================================================================
function s = convert(d)

nextChild = d.getFirstChild;
if isempty(d.getFirstChild)
    s = convertType(...
        '', ...
        char(d.getAttribute('xsi:type')));
elseif nextChild.getNodeType == 3
    s = convertType(...
        char(nextChild.getNodeValue), ...
        char(d.getAttribute('xsi:type')));
else
    s = [];
    while ~isempty(nextChild)
        name = char(nextChild.getAttribute('name'));
        if isempty(name)
            name = char(nextChild.getNodeName);
        end
        % TODO: Handle namespaces properly.
        name = name(max([find(name == ':') 0])+1:end);

        value = convert(nextChild);
        if isfield(s,name)
            if isstruct(value)
                s.(name)(end+1,1) = value;
            elseif ischar(value)
                if ischar(s.(name))
                    s.(name) = {s.(name);value};
                else
                    s.(name){end+1,1} = value;
                end
            else
                % TODO: Other types.
            end
        else
            s.(name) = value;
        end
        nextChild = nextChild.getNextSibling;
    end
    % The CHAR below is to handle the empty case.
    if ~isempty(regexp(char(d.getAttribute('xsi:type')),':Array$'))
        if length(fieldnames(s)) == 1
            s = s.(name);
        else
            error('Non-unique elements.')
        end
    end
end

%===============================================================================
function value = convertType(value,type)
% Convert each primitive type to a MATLAB-friendly type.

% TODO: Handle namespaces properly.
type = type(max([find(type == ':') 0])+1:end);

% If "type" is empty, make sure it is a CHAR.
type = char(type);
switch type
    case 'string'
        % Leave it alone.
    case 'boolean'
        switch value
            case 'false'
                value = false;
            case 'true'
                value = true;
            otherwise
                error('not true or false');
        end
    case {'int','integer','decimal','double'}
        value = str2double(value);
    case {'float'}
        value = single(str2double(value));
    otherwise
        %disp(sprintf('Unknown type: "%s".',type))
end
