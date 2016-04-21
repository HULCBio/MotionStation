function resp = callSoapService(endpoint,soapAction,message)
%CALLSOAPSERVICE Send a SOAP message off to an endpoint.
%   callSoapService(ENDPOINT,SOAPACTION,MESSAGE) sends the MESSAGE, a Java DOM,
%   to the SOAPACTION service at the ENDPOINT.
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
%   See also createClassFromWsdl, parseSoapResponse.

% Matthew J. Simoneau, June 2003
% $Revision: 1.1.6.3 $  $Date: 2004/03/26 13:26:19 $
% Copyright 1984-2004 The MathWorks, Inc.

% Implementation #1: Build up the whole message and use C MEX-files to send.

% %   Separate the host from the rest of the URL
% http_ss = 'http://';
% if all(endpoint(1:length(http_ss))==http_ss)
%     endpoint((1:length(http_ss))) = [];
% end
% fs = find(endpoint=='/');
% if ~isempty(fs)
%     host = endpoint(1:(fs(1)-1));
%     postTarget = endpoint(fs(1):end);
% else
%     host = endpoint;
%     postTarget = '/';
% end
%
%
% %   Construct the HTTP header information
% C = {};
% C{end+1} = ['POST ' postTarget ' HTTP/1.1'];
% C{end+1} = ['Host: ' host];
% C{end+1} = 'Content-Type: text/xml; charset=utf-8';
% C{end+1} = ['Content-Length: ' num2str(length(message(:)))];  
% C{end+1} = ['SOAPAction: "' soapAction '"'];
% C{end+1} = ['User-Agent: MATLAB ' version];
% C{end+1} = 'Accept: text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2';
% C{end+1} = 'Connection: Keep-Alive';
% 
% %   Add newlines
% LF = char(13);
% CR = char(10);
% for i = 1:length(C); C{i} = [C{i} LF CR]; end
% 
% %   Add the message, separated by a blank line
% charsForSOAPRequest = [C{:}, LF, CR, message];
% 
% %   Call the mex file to send and receive the response
% IPstr = resolve(host);
% resp = mexcallsoapservice(IPstr,charsForSOAPRequest);
% %resp = xdoc(resp);


% Implementation #2: Use Java class to send the message.

% resp = char(javaMethod('main','SendSoap',endpoint,soapAction,message));


% Implementation #3: Use inline Java to send the message.
import java.io.*;
import java.net.*;

toSend = serializeDOM(message);
% TODO: Why does this attribute missing?  Use strrep to put it back.
toSend = strrep(toSend, ...
    'xmlns:soap-env=""', ...
    'xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"');
toSend = java.lang.String(toSend);
b = toSend.getBytes('UTF8');

% Create the connection where we're going to send the file.
url = URL(endpoint);
httpConn = url.openConnection;

% Set the appropriate HTTP parameters.
httpConn.setRequestProperty('Content-Length', javaMethod('valueOf','java.lang.String',length(b)));
httpConn.setRequestProperty('Content-Type','text/xml; charset=utf-8');
httpConn.setRequestProperty('SOAPAction',soapAction);
httpConn.setRequestMethod('POST');
httpConn.setDoOutput(true);
httpConn.setDoInput(true);

% Everything's set up; send the XML that was read in to b.
outputStream = httpConn.getOutputStream;
outputStream.write(b);
outputStream.close;

% Read the response and write it to standard out.
try
    isr = InputStreamReader(httpConn.getInputStream);
catch
    % Try to chop off the Java stack trace.
    message = lasterr;
    [null,null,t] = regexp(message,'java.io.IOException: (.*)\n');
    if isempty(t)
        error(message)
    else
        error(message(t{1}(1):t{1}(2)))
    end
end
in = BufferedReader(isr);

stringBuffer = java.lang.StringBuffer;

while true
    inputLine = in.readLine;
    if isempty(inputLine)
        break;
    end
    stringBuffer.append(inputLine);
end
in.close;
% Leave the response as a java.lang.String so we don't squash Unicode.
resp = stringBuffer.toString;

%===============================================================================
function s = serializeDOM(x)
% Serialization through tranform.
domSource = javax.xml.transform.dom.DOMSource(x);
tf = javax.xml.transform.TransformerFactory.newInstance;
serializer = tf.newTransformer;
serializer.setOutputProperty(javax.xml.transform.OutputKeys.ENCODING,'utf-8');
serializer.setOutputProperty(javax.xml.transform.OutputKeys.INDENT,'yes');

stringWriter = java.io.StringWriter;
streamResult = javax.xml.transform.stream.StreamResult(stringWriter);

serializer.transform(domSource, streamResult);
s = char(stringWriter.toString);
