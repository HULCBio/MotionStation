function dom = createSoapMessage(tns,methodname,values,names,types)
%CREATESOAPMESSAGE Creates the SOAP message, ready to send to the server.
%   CREATESOAPMESSAGE(NAMESPACE,METHOD,VALUES,NAMES,TYPES) creates a SOAP
%   message.  VALUES, PARAMETERS, and TYPES are cell arrays.  PARAMETERS will
%   default to dummy names and TYPES will default to unspecified.
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
%   See also createClassFromWsdl, callSoapService.

% Matthew J. Simoneau, June 2003
% $Revision: 1.1.6.3 $  $Date: 2004/03/26 13:26:20 $
% Copyright 1984-2004 The MathWorks, Inc.

% Default to made-up names.
if (nargin < 4)
    names = cell(length(values));
    for i = 1:length(values)
        names{i} = sprintf('param%.0f',i);
    end
end
% Default to empty types.
if (nargin < 5)
    types = cell(length(values));
    types(:) = {''};
end

%   Form the envelope
dom = com.mathworks.xml.XMLUtils.createDocument('soap-env:Envelope');
rootNode = dom.getDocumentElement;
rootNode.setAttribute('xmlns:soap-env','http://schemas.xmlsoap.org/soap/envelope/');
%env = addAttribute(env,'xmlns:xsi','http://www.w3.org/1999/XMLSchema-instance');  % not sure I need
rootNode.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');  % not sure I need
%env = addAttribute(env,'xmlns:xsd','http://www.w3.org/1999/XMLSchema');
rootNode.setAttribute('xmlns:xsd','http://www.w3.org/2001/XMLSchema');

%   Form the header
%header = xdoc('soap-env:Header');
%   Add the header to the envelops
%env = addChild(env,header);

%   Form the body
soapBody = dom.createElement('soap-env:Body');

%soapMessage = xdoc(methodname);
soapMessage = dom.createElement(['ns1:' methodname]);
%soapMessage = addAttribute(soapMessage,'xmlns',tns);
soapMessage.setAttribute('xmlns:ns1',tns);
soapMessage.setAttribute('soap-env:encodingStyle','http://schemas.xmlsoap.org/soap/encoding/');

for i = 1:length(names)
    input = dom.createElement(names{i});
    %c = class(values{i}); if ischar(values{i}); c = 'string';end
    if ~isempty(types{i})
        if ~isempty(strmatch('{http://www.w3.org/2001/XMLSchema}',types{i}))
            input.setAttribute('xsi:type',['xsd:' types{i}(35:end)]);
        else
            % TODO: Better type handling.
            %disp(sprintf('Could do better with "%s" in "%s".',types{i},names{i}))
        end
    end
    textToSend = convertToText(values{i});
    input.appendChild(dom.createTextNode(textToSend));
    soapMessage.appendChild(input);
end
soapBody.appendChild(soapMessage);

%   Add the body
rootNode.appendChild(soapBody);

%===============================================================================
function s = convertToText(x)
switch class(x)
    case 'char'
        s = x;
    otherwise
        s = mat2str(x);
end