function [f,status] = urlwrite(urlChar,location,method,params);
%URLWRITE Save the contents of a URL to a file.
%   URLWRITE(URL,FILENAME) saves the contents of a URL to a file.  FILENAME
%   can specify the complete path to a file.  If it is just the name, it will
%   be created in the current directory.
%
%   F = URLWRITE(...) returns the path to the file.
%
%   F = URLWRITE(...,METHOD,PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a
%   cell array of param/value pairs.
%
%   [F,STATUS] = URLWRITE(...) catches any errors and returns the error code. 
%
%   Examples:
%   urlwrite('http://www.mathworks.com/',[tempname '.html'])
%   urlwrite('ftp://ftp.mathworks.com/pub/pentium/Moler_1.txt','cleve.txt')
%   urlwrite('file:///C:\winnt\matlab.ini',fullfile(pwd,'my.ini'))
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD.

%   Matthew J. Simoneau, 13-Nov-2001
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $ $Date: 2004/04/10 23:29:46 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:urlwrite:NoJvm','URLWRITE requires Java.');
end

import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

% Be sure the proxy settings are set.
com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings

% Check number of inputs and outputs.
error(nargchk(2,4,nargin))
error(nargoutchk(0,2,nargout))
if (nargin > 2) && ~strcmpi(method,'get') && ~strcmpi(method,'post')
    error('Second argument must be either "get" or "post".');
end

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

% Set default outputs.
f = '';
status = 0;

% GET method.  Tack param/value to end of URL.
if (nargin > 2) && strcmpi(method,'get')
    if mod(length(params),2) == 1
        error('Invalid parameter/value pair arguments.');
    end
    for i=1:2:length(params)
        if (i == 1), separator = '?'; else, separator = '&'; end
        param = char(java.net.URLEncoder.encode(params{i}));
        value = char(java.net.URLEncoder.encode(params{i+1}));
        urlChar = [urlChar separator param '=' value];
    end
end

% Create the URL object.
try
    url = java.net.URL(urlChar);
catch
    if catchErrors, return
    else error('Either this URL could not be parsed or the protocol is not supported.',catchErrors);
    end
end

% Open a connection to the URL.
urlConnection = url.openConnection;

% POST method.  Write param/values to server.
if (nargin > 2) && strcmpi(method,'post')
    try
        urlConnection.setDoOutput(true);
        urlConnection.setRequestProperty( ...
            'Content-Type','application/x-www-form-urlencoded');
        printStream = java.io.PrintStream(urlConnection.getOutputStream);
        for i=1:2:length(params)
            if (i > 1), printStream.print('&'); end
            param = char(java.net.URLEncoder.encode(params{i}));
            value = char(java.net.URLEncoder.encode(params{i+1}));
            printStream.print([param '=' value]);
        end
        printStream.close;
    catch
        if catchErrors, return
        else error('Could not POST to URL.');
        end
    end
end

% Specify the full path to the file so that getAbsolutePath will work when the
% current directory is not the startup directory and urlwrite is given a
% relative path.
file = java.io.File(location);
if ~file.isAbsolute
   location = fullfile(pwd,location);
   file = java.io.File(location);
end

% Make sure the path isn't nonsense.
try
   file = file.getCanonicalFile;
catch
   error('Could not resolve file "%s".',char(file.getAbsolutePath));
end

% Open the output file.
try
    fileOutputStream = java.io.FileOutputStream(file);
catch
    error('Could not open output file "%s".',char(file.getAbsolutePath));
end

% Read the data from the connection.
try
    inputStream = urlConnection.getInputStream;
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    isc.copyStream(inputStream,fileOutputStream);
    inputStream.close;
    fileOutputStream.close;
    f = char(file.getAbsolutePath);
    status = 1;
catch
    if catchErrors, return
    else error('Error downloading URL.');
    end
end
