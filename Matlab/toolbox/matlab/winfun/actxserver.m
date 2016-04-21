function h = actxserver(varargin)
%ACTXSERVER Create ActiveX automation server.
%  H = ACTXSERVER(PROGID) will create a local or remote ActiveX
%  automation server where PROGID is the program ID of the ActiveX object and 
%  H is the handle of the control's default interface. 
%
%  H = ACTXSERVER(PROGID,'MACHINE') specifies the name of a remote machine 
%  on which to launch the server.
% 
%  See also: ACTXCONTROL

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.8.6.4 $ $Date: 2004/04/15 00:06:49 $

switch length(varargin)
case 1
    progID = varargin{1};
    machinename = '';
case 2
    progID = varargin{1};
    machinename = varargin{2};
otherwise
    error('Incorrect number of input parameters');
end

% workaround for bug parsing control name which ends with dot + integer
convertedProgID = newprogid(progID);

if (~isempty(machinename))
    try
        h=feval(['COM.' convertedProgID], 'server', machinename);
    catch
        lastid = lasterror; lastid = lastid.identifier;
        if (strcmpi(lastid, 'MATLAB:Undefinedfunction'))
            disp = sprintf('Server creation failed. Invalid ProgID ''%s''', progID);
            error('MATLAB:COM:InvalidProgid',disp);
        else    
            rethrow(lasterror);
        end    
    end    
else
    try
        h=feval(['COM.' convertedProgID], 'server');
    catch
        lastid = lasterror; lastid = lastid.identifier;
        if (strcmpi(lastid, 'MATLAB:Undefinedfunction'))
            disp = sprintf('Server creation failed. Invalid ProgID ''%s''', progID);
            error('MATLAB:COM:InvalidProgid',disp);
        else    
            rethrow(lasterror);
        end    
    end        
end


