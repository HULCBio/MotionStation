function send( pj )
%SEND Send output file to hardcopy device.
%   The output file is in the format specified by the device argument to 
%   the PRINT command. The command used to send the file to the output device 
%   is operating system specific. The command is stored in the PrintJob object.
%
%   Ex:
%      SEND( pj );
%
%   See also PRINT, PRINTOPT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/06/17 13:33:53 $

lprcmd = pj.PrintCmd;

% set up a filename for use
theFileName = pj.FileName;

if ~isempty(pj.GhostName)
    theFileName = pj.GhostName;
end

% Does something exist to send to the printer?
if ~exist( theFileName )
    error('No file to send to printer.')
end

if strcmp( computer, 'PCWIN' )

    % double the slashes, and insert file name
    cmd = sprintf(strrep(lprcmd,'\','\\'), theFileName);
    
    % insert a port name
    if ~isempty(findstr(cmd,'$portname$'))
        
        % find out which port it goes to
        portName = system_dependent('getspecifiedprinterport', pj.PrinterName);
        
        % check for empty (unknown) port or FILE: device, use default if
        % found
	if isempty(portName) 

	    % error, no default printer setup
	    if isempty(pj.PrinterName) 		
		error('No default printer configured.');
	    end
	    
            error(['Invalid printer ''' pj.PrinterName ''' specified.' ] );
        end
        
        if strcmp(portName,'FILE:')
	    error(['Unsupported port''' portName ''' to printer ''' pj.PrinterName ''', use a file instead.' ] );
        end
        
        % substitute $portname$ for a real port
        cmd = strrep(cmd,'$portname$','%s');
        % replace slashes by double slashes (sprintf converts then to
        % escapes)
        cmd = strrep(cmd,'\','\\');
        % subsistute portname into string, once only
        cmd = sprintf(cmd, portName);
    end

    % insert a file name
    if ~isempty(findstr(cmd,'$filename$'))
        
        % substitute $portname$ for a real port
        cmd = strrep(cmd,'$filename$','%s');
        % replace slashes by double slashes (sprintf converts then to
        % escapes)
        cmd = strrep(cmd,'\','\\');
        % subsistute portname into string, once only
        cmd = sprintf(cmd, theFileName);
    end

    if pj.DebugMode
        disp( ['PRINT debugging: print command = ''' cmd '''.'] )
    end
    
    
    [s, r] = privdos(pj,cmd);

    if ~pj.DebugMode
        delete(theFileName);
    end
    
else
    if strncmp( lprcmd, 'lp ', min(length(lprcmd),3) ) 
        notBSD = 1;
    else
        notBSD = 0;
    end
    if ~isempty( pj.PrinterName )
        %If user specified a printer, add it to the printing command
        if notBSD
          cmdOption = '-d';
        else
          cmdOption = '-P';
        end
        lprcmd = [ lprcmd ' "' cmdOption pj.PrinterName '"' ];
    end
    
    if pj.DebugMode
        disp( ['PRINT debugging: print command = ''' lprcmd ' "' theFileName '"''.'] )
    end
    dberror = disabledberror;
    try
      [s, r] = unix([lprcmd ' "' theFileName '"' ] );
    catch
      % Try unix with one argument if last call fails
      s = unix([lprcmd ' "' theFileName '"' ]);
      r = '';
    end
    enabledberror(dberror);
      
    if notBSD
        % SGI and SOL2 without Berkley printing extensions do not
        % have a 'delete when done' option, so used copy option and
        % now delete the temporary file we made.

        if ~pj.DebugMode
            delete(theFileName)
        end

    end
end

% general error code and output testing
if s & ~isempty(r)
    error( sprintf('Problem sending file to output device, system returned error :\n%s', r) )
end

% mac "Print" never has non-zero return code - check stdout
if strncmp(computer,'MA',2) & ~isempty(r) & strncmp(lprcmd,'Print',5) & ~isempty(strfind(r,'ERROR:'))
    error( sprintf('Problem sending file to output device, system returned error :\n%s', r) )
end
