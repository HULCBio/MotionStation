function [def, printerNames] = findprinters( varargin )
%FINDPRINTERS Return names of output devices listed in configuration file.
%   Searches standard unix places for files in the following order:
%       1)/$HOME/printers.conf file.
%       2)/etc/printers.conf file.
%       3)/etc/printcap file.
%   Reads only the devices listed in the first file it comes across.
%   Finds only the first name for each device; if one device is listed
%   with the first name of lp, he second name is read and that device 
%   is returned as the default printer.
%   Default printer will be reset to that of the environment variable
%   LPDEST or PRINTER if either exists.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2002/10/24 02:14:40 $

fid = -1;
printerNames = {};
numPrinters = 0;
lpDevice  = '';
theEntry = '';
tabchar = sprintf('\t');
spcchar = sprintf(' ');

% are we running MAC OS X
if strncmp(computer, 'MA', 2)
    [ printerNames, defaultIndex ] = getmacprinters;
    if ~isempty(printerNames) && defaultIndex > 0
        def = printerNames{defaultIndex};
    else
        def = '';
    end
    return;
end

%Check environment for default printer
def = LocalDefaultPrinter;
if ~isempty( def )
    printerNames{1}= def;
    numPrinters = numPrinters +1;
end

%1) check $home/printers.conf
home = getenv('HOME');
if ~isempty( home )
    fname = fullfile( home, 'printers.conf' );
    fid = fopen( fname, 'r' );
end

if fid == -1
    %2) check /etc/printers.conf
    fname = '/etc/printers.conf';
    fid = fopen( fname, 'r' );
end

if fid == -1
    %2) check /etc/printcap
    fname = '/etc/printcap';
    fid = fopen( fname, 'r' );
end

if fid ~= -1
    while 1
        str = fgetl(fid);
        if ~isstr(str), break, end

        % Ignore comments, leading whitespace, and blank lines
        if ~isempty(str) & (str(1) == '#'), continue, end
        while ~isempty(str) & ((str(1) == tabchar) | (str(1) == spcchar))
            str = str(2:end);
        end
        if isempty(str), continue, end

        theEntry = [ theEntry str ];
        if theEntry(end) == '\'
            % Remove continuation character and keep reading..
            theEntry(end) = [];
        else
            % Now we have a complete printcap entry
	    sep = sort([findstr(theEntry,'|') findstr(theEntry,':')]);
	    % check for unknown formats
	    if isempty(sep)
	      theEntry = '';
	      continue;
	    end
            numPrinters = numPrinters+1;
            name = theEntry(1:sep(1)-1);
            % First name of 'lp' signals the default printer
            % Get next name and save it as default and add it to list.
            if strcmp(name,'lp')
                if length(sep) > 1
                    name = theEntry(sep(1)+1 : sep(2)-1);
                end
                lpDevice = name;
            end
            printerNames{numPrinters} = name;
            theEntry = '';
        end 
    end
	
    %All done with the file
    fclose(fid);
end


%If no env variable, use the one called 'lp' in printer description file, or just first entry.
if isempty( def )
	if ~isempty( lpDevice  )
        def = lpDevice;
	elseif numPrinters > 0
        def = printerNames{1};
    end
end


function def = LocalDefaultPrinter
%Look for a default printer in the environement. LP and LPR use different precedence.
def = '';
if isunix
	cmd = printopt;
    %Is there a printer being specified in the command?
    Loc=[];
    if findstr(cmd,'lpr')
        Loc=findstr('-P',cmd);
    elseif findstr(cmd,'lp')
        Loc=findstr('-d',cmd);
    end
    if ~isempty( Loc )
        Loc = Loc+2; %get past -d/-P
        nameLength = findstr(' ',cmd(Loc:end) );
        if isempty( nameLength )
            nameLength = (length(cmd) - Loc) +1;
        else
            nameLength = nameLength(1) -1;
        end
        def = cmd(Loc:(Loc+nameLength-1));
    end
    
    if isempty( def )
        %Next step is to check for environment variables
		p = getenv('PRINTER');
		l = getenv('LPDEST');
        %If one, or both, doesn't exist, use the one that does or empty string.
        if isempty(p) | isempty(l)
            if isempty(p)
                def = l;
            else
        		def = p;
            end
        else
            %They both exist, check what command is being used
            if findstr(cmd,'lpr')
				def = p;
            elseif findstr(cmd,'lp')
				def = l;
            else 
                def = p; %VMS?
            end
        end
    end
else %PC
    def = system_dependent('getdefaultprinter');
end
