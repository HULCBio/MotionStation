function sendmail(to, subject, message, attachments)
%SENDMAIL Send e-mail.
%   SENDMAIL(TO,SUBJECT,MESSAGE,ATTACHMENTS) sends an e-mail.  TO is either a
%   string specifying a single address, or a cell array of addresses.  SUBJECT
%   is a string.  MESSAGE is either a string or a cell array.  If it is a
%   string, the text will automatically wrap at 75 characters.  If it is a cell
%   array, it won't wrap, but each cell starts a new line.  In either case, use
%   char(10) to explicitly specify a new line.  ATTACHMENTS is a string or a
%   cell array of strings listing files to send along with the message.  Only TO
%   and SUBJECT are required.
%
%   SENDMAIL relies on two preferences, "Internet:SMTP_Server", your mail
%   server, and "Internet:E_mail", your e-mail address.  Use SETPREF to set
%   these before using SENDMAIL.  The easiest ways to identify your outgoing
%   mail server is to look at the preferences of another e-mail application or
%   consult your administrator.  If you cannot find out your server's name,
%   setting it to just 'mail' might work.  If you do not set these preferences
%   SENDMAIL will try to determine them automatically by reading environment 
%   variables and the Windows registry.
%
%   Example:
%     setpref('Internet','SMTP_Server','mail.example.com');
%     setpref('Internet','E_mail','matt@example.com');
%     sendmail('user@example.com','Calculation complete.')
%     sendmail({'matt@example.com','peter@example.com'},'You''re cool!', ...
%       'See the attached files for more info.',{'attach1.m','d:\attach2.doc'});
%     sendmail('user@example.com','Adding additional breaks',['one' 10 'two']);
%     sendmail('user@example.com','Specifying exact lines',{'one','two'});
%
%   See also WEB, FTP.

% Use the SMTP protocol directly. Connect to the SMTP port on the given
% mail server, and chat away. Use MIME encoding to ship a multipart/mixed
% message.
%
% RFC 821 lists the SMTP status codes. Multiple copies of that document
% exist on the Internet. See http://www.landfield.com/rfcs/rfc821.html
% for one example.

% Peter Webb, Aug. 2000
% Matthew J. Simoneau, Nov. 2001, Aug 2003
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.4.4.6 $  $Date: 2004/03/26 13:26:33 $

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:sendmail:NoJvm','SENDMAIL requires Java.');
end

global base64Map

% Argument parsing.
error(nargchk(2,4,nargin));
if (nargin < 3)
    message = '';, 
end
if (nargin < 4) 
    attachments = [];
elseif ischar(attachments)
    attachments = {attachments};
end

% Determine SERVER
server=getpref('Internet','SMTP_Server','');
if isempty(server) & ispc
    try
        defaultMailAccount=winqueryreg('HKEY_CURRENT_USER', ...
            'Software\Microsoft\Internet Account Manager', ...
            'Default Mail Account');
        defaultMailAccountRegistry = ...
            ['Software\Microsoft\Internet Account Manager\Accounts\' ...
                defaultMailAccount];
        server=winqueryreg('HKEY_CURRENT_USER', defaultMailAccountRegistry, ...
            'SMTP Server');
    catch
    end
end
if isempty(server)
    server = getenv('mailhost');
end
if isempty(server)
    error(sprintf('%s\n%s', ...
        'Could not determine SMTP server.  You can set one like this: ', ...
        'setpref(''Internet'',''SMTP_Server'',''myserver.myhost.com'');'))
end

% Determine FROM
from=getpref('Internet','E_mail','');
if isempty(from) & ispc
    try
        from=winqueryreg('HKEY_CURRENT_USER', defaultMailAccountRegistry, ...
            'SMTP Email Address');
    catch
    end
end
if isempty(from)
    from = getenv('LOGNAME');
end
if isempty(from)
    error(sprintf('%s\n%s', ...
        'Could not determine FROM address.  You can set one like this: ', ...
        'setpref(''Internet'',''E_mail'',''username'');'))
end

% Everyone uses this port, right?
port = 25;

% Set up the base 64 conversion map 
% A:Z a:z 0:9 + /
base64Map = char([65:90 97:122 48:57 '+' '/' '=']);

% Connect to given SMTP server
try
    mail = java.net.Socket(server, port);
catch
    error(sprintf('Could not establish connection with %s on port %i.', ...
        server,port));
end

% Get the output and input streams from the socket connection
out = java.io.DataOutputStream(getOutputStream(mail));
in = java.io.DataInputStream(getInputStream(mail));

% Message acknowledging the SMTP server is alive
[status, code] = okSMTP(readmsg(in));
if status == 0, error('No answer from SMTP server.'), end

% The boundary to be used between the parts of the message
boundary = '----=_X_X_sendmail.m_X_X_';

% Regular SMTP protocol. These lines must be sent in this order.
% Start a session
sendSMTP(out, in, 'HELO mailman', 1);

% Set sender
sendSMTP(out, in, ['MAIL FROM: ' from], 1);

% Set recipients
if iscell(to)
    for i=1:length(to)'
        sendSMTP(out, in, ['RCPT TO: ' to{i}], 1);
    end
else
    sendSMTP(out, in, ['RCPT TO: ' to], 1);
end

% Send the body of the message
sendSMTP(out, in, 'DATA', 1);

% Determine "To:".
toField = to;
if iscell(toField)
    % Join cells into one string separated by ", ".
    toField = toField(:)';
    ds = cell(size(toField));
    ds(:) = {', '};
    toField = [toField;ds];
    toField = toField(1:end-1);
    toField = [toField{:}];
end

sendSMTP(out, in, ['X-Mailer: MATLAB ' version], 0);
sendSMTP(out, in, ['From: ' from], 0);
sendSMTP(out, in, ['To: ' toField], 0);
sendSMTP(out, in, ['Subject: ' subject], 0);

% Here, it gets interesting. Send the Mime-Version header because we're
% using MIME encoding
sendSMTP(out, in, 'Mime-Version: 1.0', 0);

% If there are attachments, this is a multipart message
if length(attachments) > 0
    sendSMTP(out, in, ...
        ['Content-Type: multipart/mixed; boundary="' boundary '"'], 0);
    sendSMTP(out, in, [13 10 '--' boundary], 0);
end

% Start boundary for the first (text) section
sendSMTP(out, in, ['Content-Type: text/plain; charset=us-ascii' 13 10], 0);

if ~isempty(message) 
    sendText(message, in, out);
end

% Loop over the attachments, sending each in its own section	
if length(attachments) > 0
    for i=1:length(attachments)
        % Start boundary for the next attachment
        sendSMTP(out, in, [13 10 '--' boundary], 0);
        % It's very important that there be a blank line between these Content-*
        % statements and the start of the attachment data
        sendSMTP(out, in, ['Content-Type: application/octet-stream'], 0);
        sendSMTP(out, in, 'Content-transfer-encoding: base64', 0);
        % Remove the directory, if any, from the attachement name.
        [fileDir,fileName,fileExt]=fileparts(attachments{i});
        sendSMTP(out, in, ['Content-Disposition: attachment; filename=' fileName fileExt 13 10], 0);
        % Send the attachment data
        sendBinaryFile(attachments{i}, in, out);
    end
    % End boundary for the message
    sendSMTP(out, in, [13 10 '--' boundary '--'], 0);
end

% Indicate we're done with the data section of the message
sendSMTP(out, in, '.', 1);

% Terminate the SMTP session
sendSMTP(out, in, 'QUIT', 1);

% Close the mail socket
close(mail);

% Clean up the global variable
clear global base64Map

%===============================================================================
function sendSMTP(out, in, msg, rflag)
% Send a text along an SMTP connection

% Send the text
msg = java.lang.String([msg 13 10]);
writeBytes(out, msg);

% Read and check the response, if the rflag is non-zero
if rflag
    inmsg = readmsg(in);
	[smtpStatus, smtpCode] = okSMTP(inmsg);                                   
	if smtpStatus == 0
        error(['SMTP error: ' inmsg]);
    end                  
else
	status = 1;
	code = 0;
end

%===============================================================================
function sendText(msgText, in, out)
% Send a block of text (break into 75 character lines) along the SMTP 
% connection

% For a cell array, send each cell as one line.
if iscell(msgText)
    for i = 1:length(msgText)
        sendSMTP(out, in, msgText{i}, 0);
    end
    return
end

% For a char array, break each line at a char(10) or try to wrap to 75 
% characters.
maxLineLength = 75;
cr = char(10);
msgText = [cr msgText cr];
crList = find(msgText == cr);

for i = 1:length(crList)-1
    nextLine = msgText(crList(i)+1 : crList(i+1)-1);
    lineLength = length(nextLine);

    nextStart = 1;
    moreOnLine = true;
    while moreOnLine
        start = nextStart;
        if (lineLength-start+1 <= maxLineLength)
            % The rest fits on one line.
            stop = lineLength;
            moreOnLine = false;
        else
            % Whole line doesn't fit.  Needs to be broken up.
            spaces = find(nextLine == ' ');
            spaces = spaces(spaces >= start);
            nonSpaces = find(nextLine ~= ' ');
            nonSpaces = nonSpaces(nonSpaces >= start);            
            if isempty(spaces)
%                 % No spaces anywhere.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            elseif isempty(nonSpaces)
                % Nothing but spaces.  Send an empty line.
                stop = start-1;
            elseif (min(spaces) > (start+maxLineLength))
%                 % The first space doesn't show up soon enough to help.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            elseif isempty(spaces( ...
                    spaces > min(nonSpaces) & spaces < start+maxLineLength ...
                    ))
%                 % There are only leading spaces, which we respect.  Chop!
%                 stop = start+maxLineLength-1;
                % No spaces anywhere.  Preserve.
                stop = lineLength;
            else
                % Break on the last space that will make the line fit.
                stop = max(spaces(spaces <= (start+maxLineLength)))-1;
            end
            % After a break, start the next line on the next non-space.
            nonSpaces = find(nextLine ~= ' ');
            nextStart = min(nonSpaces(nonSpaces > stop));
            if isempty(nextStart)
                moreOnLine = false;
            end
        end
        sendSMTP(out,in,nextLine(start:stop),0);
    end
end

%===============================================================================
function b64 = base64(data)
% Convert 24 bits of base 256 data into 32 bits of base 64 data
global base64Map
sixbits = 63;
one = 18;
two = 12;
three = 6;
four = 0;

% Break the data into four 6-bit letters
b64(1) = bitshift(bitand(data, bitshift(sixbits, one)), -one);
b64(2) = bitshift(bitand(data, bitshift(sixbits, two)), -two);
b64(3) = bitshift(bitand(data, bitshift(sixbits, three)), -three);
b64(4) = bitshift(bitand(data, bitshift(sixbits, four)), -four);

b64 = base64Map(b64+1);

%===============================================================================
function encoded = encode64(data)
% Encode a string of bytes into base64, as defined by RFC 2045
count = 1;
left = mod(length(data),3);
len = length(data)-left;
for i=1:3:len
	group = bitshift(data(i),16) + bitshift(data(i+1),8) + data(i+2);
	encoded(count:count+3) = base64(group);
	count = count+4;
end
if left ~= 0
	group = bitshift(data(len+1),16);
	padstr = '==';
	if left == 2
		group = group + bitshift(data(len+2),8);
		padstr = '=';
	end
	b64 = base64(group);
	encoded(count:count+left) = b64(1:left+1);
	count=count+left+1;
	encoded(count:count+length(padstr)-1) = padstr;
end

%===============================================================================
function sendBinaryFile(name, in, out)
% Send a binary file. Encode into base64. Send no more than 76 characters
% at a time. 
maxc = 57;
fid = fopen(name, 'r');
if (fid == -1)
    error('MATLAB:sendmail:CannotOpenFile','Cannot open file "%s".',name);
end
while 1
	[line, count] = fread(fid, maxc, 'uchar');
	if count == 0, break, end
	sendSMTP(out, in, encode64(line), 0);
end
fclose(fid);

%===============================================================================
function msg=readmsg(in)
msg=char(readLine(in));
% Read (using Java) a line of bytes from the SMTP connection. Block until
% we get something to read.


%===============================================================================
function [status, code] = okSMTP(message)
% Check the code returned by the SMTP server. The code is the first 3 
% characters of the response. The first digit of the command determines
% success or failure:
%
%   2 : Command succeeded
%   3 : Success (informational message)
%   4 : Transient error (try again)
%   5 : Permanent error (fix commands before trying again)

code = message(1:3);
switch code(1)
case '2'
	status = 1;
case '3'
	status = 1;
case '4'
	status = 0;
case '5'
	status = 0;
otherwise
	status = 0;
end
