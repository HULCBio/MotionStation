function out = grepfields(filename,searchstring,casesensitivity, ...
                          startcol,field,machineformat,nheadbytes) 
%GREPFIELDS Identify matching records in fixed record length files.
% 
%   GREPFIELDS(FILENAME,SEARCHSTRING) displays lines in the file that 
%   begin with the search string.  The file must have fixed length records 
%   with line endings.
% 
%   GREPFIELDS(FILENAME,SEARCHSTRING,CASESENS), with  CASESENS
%   'matchcase' specifies a case-sensitive search.  If  omitted or 'none',
%   the search string will match regardless of the case.
% 
%   GREPFIELDS(FILENAME,SEARCHSTRING,CASESENS,STARTCOL) searches 
%   starting with the specified column.  STARTCOL is an integer between 1
%   and  the bytes per record in the file.  In this calling form, the file
%   is  regarded as a text file with line endings.
%   
%   GREPFIELDS(FILENAME,SEARCHSTRING,CASESENS,STARTFIELD,FIELDS) 
%   searches within the specified field.  STARTFIELD is an integer between
%   1  and the number of fields per record.  The format of file is
%   described by  the FIELDS structure.  See READFIELDS for recognized
%   FIELDS structure  entries.  In this calling form, the file can be
%   binary and lack line  endings.  The search is within STARTFIELD, which
%   must be a character  field.
% 
%   GREPFIELDS(FILENAME,SEARCHSTRING,CASESENS,STARTFIELD,FIELDS,MACHINE
%   FORMAT)  opens the file with the specified machine format.
%   MACHINEFORMAT must be  recognized by FOPEN.
% 
%   GREPFIELDS(FILENAME,SEARCHSTRING,CASESENS,STARTFIELD,FIELDS,MACHINE
%   FORMAT, NHeadBytes) skips a file header before beginning the search.
%   The size of the  header is specified in bytes.
% 
%   INDEX = GREPFIELDS(...) returns the record numbers of matched records 
%   instead of displaying them on-screen.
%   
%   See also READFIELDS, READMTX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  W. Stumpf

if nargin < 2; error('Incorrect number of arguments'); end

if nargin < 7; nheadbytes = 0; end

if nargin < 3; casesensitivity = 'none';end
if nargin < 4; startcol = 1;end
if nargin >= 5 % file structure specified
    
	[ncols,field] = recordlength(field);
	if length(searchstring) > field(startcol).bytes*field(startcol).length; return; end
	if ~field(startcol).ischar;
		error('Searched field should contain character data')
    end
	if startcol ~= 1
		startcol = 1+sum([field(1:startcol-1).length] .* [field(1:startcol-1).bytes]);
    end
else % treat as text file

	fid = fopen(filename,'r');
    status = fseek(fid,nheadbytes,'bof');
    if status == -1; error(ferror(fid)); end
	ncols = length(fgets(fid));
	fclose(fid);
end
if nargin < 6; machineformat = 'native'; end


% enforce searchstring type character

if ~ischar(searchstring)
	error('Search string must be a character')
end

% check for recognized strings
switch lower(casesensitivity)
case {'none','matchcase'}
otherwise
	error('Case sensitivity must be ''none'' or ''matchcase''')
end

% determine number of rows

f = dir(filename);
nrows = (f.bytes-nheadbytes)/ncols;

% If the file does not match inputs try to be as informative as possible.
% Try to detect text files that actually do have fixed record lengths, and 
% state the actual and expected record lengths.

if rem(nrows,1) ~= 0;
	
	% Open file
	if isempty(filename)
		[filename,filepath] = uigetfile('*','Select the file');
		filename = [filepath,filename];
    end

	fid = fopen(filename,'rb', machineformat);
	
	if fid == -1
		[filename,filepath] = uigetfile(filename,['Where is ',filename,'?']);
		if filename == 0 ; data = []; return; end
		fid = fopen([filepath,filename],'rb', machineformat);
    end

	strng = fread(fid,10000,'char');
	
	CRindx = find(strng==13);
	if ~isempty(CRindx) & all( diff(diff(CRindx))==0 ) &  nargin <= 5 % file structure specified
		fseek(fid,0,-1);
		actualrecordlen = length(fgets(fid));
		fclose(fid);
        warning(sprintf([ ...
        'File size of ' num2str(f.bytes) ' bytes is not evenly \n' ...
        'divisible into records.\n' ...					
        ]))
		error(sprintf(['File size does not match inputs. \n' ...
        'Expected record length was ' num2str(ncols) ' bytes.\n' ...
        'Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
        ]))
    end

	linefeedindx = find(strng==10);
	if ~isempty(linefeedindx) & all( diff(diff(linefeedindx))==0 ) &  nargin <= 5 % file structure specified
		fseek(fid,0,-1);
		actualrecordlen = length(fgets(fid));
		fclose(fid);
        warning(sprintf([ ...
        'File size of ' num2str(f.bytes) ' bytes is not evenly \n' ...
        'divisible into records.\n' ...					
        ]))
		error(sprintf(['File size does not match inputs. \n' ...
        ' Expected record length was ' num2str(ncols) ' bytes.\n' ...
        ' Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
        ]))
    end

	fclose(fid);
	error(sprintf([ ...
    'File size of ' num2str(f.bytes) ' bytes is not evenly \n' ...
    'divisible into records.\n' ...					
    ]))
end


% read a column at a time, each time only reading rows that have matched so far

readrows = 1:nrows;
for i=1:length(searchstring)
	
	column = readmtx(filename,nrows,ncols,'uint8',readrows',(i+startcol-1)*[1 1],machineformat,nheadbytes);
    
	switch lower(casesensitivity)
	case 'matchcase'
		readrows = readrows( find( double(searchstring(i)) == column )   );
    otherwise
		readrows = readrows( find( ...
        double(lower(searchstring(i))) == column | ...
        double(upper(searchstring(i))) == column   ...
        ) );
    end

	if isempty(readrows); break; end
	if length(readrows) == 1; readrows = [readrows readrows]; end	
end

if nargout == 0
	if ~isempty(readrows)
		s = readmtx(filename,nrows,ncols,'uint8',readrows(:),1:ncols,machineformat,nheadbytes);
		disp(char(s))
    end
else
	out = unique(readrows);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [recordlen,field] = recordlength(field)

%RECORDLENGTH computes the length of a record by summing lengths of fields

% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads. Can't simply read a record
% with FGETL and measure the length, because this may result in read the 
% whole file. Bad idea if files are very large.

recordlen = 0;

for i=1:length(field)
    
	field(i).ischar = 0; % keep track of whether a field contains character data, to enforce consistent types in matching
	
	switch field(i).type
    
    % Platform indpendent precision strings
    
case {	'char'   , 'char*1',...         	% character,  8 bits, 1 byte
    'uchar'  , 'unsigned char',...  	% unsigned character,  8 bits, 1 byte
    'schar'  , 'signed char'}		   	% signed character,  8 bits, 1 byte
    
    recordlen = recordlen + 1*field(i).length;
    field(i).bytes = 1;
    field(i).ischar = 1;
    
case {	'int8'   , 'integer*1',...   		% integer, 8 bits, 1 byte
    'uint8'  }		    				% unsigned integer, 8 bits, 1 byte
    
    recordlen = recordlen + 1*field(i).length;
    field(i).bytes = 1;
    
case {	'int16'  , 'integer*2',...      	% integer, 16 bits, 2 bytes
    'uint16' }      					% unsigned integer, 16 bits, 2 bytes
    
    recordlen = recordlen + 2*field(i).length;
    field(i).bytes = 2;
    
case {	'int32'  , 'integer*4',...      	% integer, 32 bits, 4 bytes
    'uint32' ,... 	      				% unsigned integer, 32 bits, 4 bytes
    'float32', 'real*4'}         		% floating point, 32 bits, 4 bytes
    
    recordlen = recordlen + 4*field(i).length;
    field(i).bytes = 4;
    
case{	'int64'  , 'integer*8',...      	% integer, 64 bits, 8 bytes
    'uint64' ,...       				% unsigned integer, 64 bits, 8 bytes
    'float64', 'real*8'}         		% floating point, 64 bits, 8 bytes
    
    recordlen = recordlen + 8*field(i).length;
    field(i).bytes = 8;
    
    % The following platform dependent formats are also supported but
    % they are not guaranteed to be the same size on all platforms.
    % Assume a size, and notify user.
    
case {	'short',...                     	% integer,  16 bits, 2 bytes
    'ushort' , 'unsigned short'} 		% unsigned integer,  16 bits, 2 bytes
    
    warning( ['Assuming machine dependent ' field(i).type ' is 16 bits, 2 bytes long'])
    recordlen = recordlen + 2*field(i).length;
    field(i).bytes = 2;
    
case {	'int',...            				% integer,  32 bits, 4 bytes
    'long',...           				% integer,  32 or 64 bits, 4 or 8 bytes
    'uint'   , 'unsigned int',...   	% unsigned integer,  32 bits, 4 bytes
    'ulong'  , 'unsigned long',...  	% unsigned integer,  32 bits or 64 bits, 4 or 8 bytes
    'float'}          					% floating point, 32 bits, 4 bytes
    
    warning( ['Assuming machine dependent ' field(i).type ' is 32 bits, 4 bytes long'])
    recordlen = recordlen + 4*field(i).length;
    field(i).bytes = 4;
    
case 'double'        						% floating point, 64 bits, 8 bytes

    warning( ['Assuming machine dependent ' field(i).type ' is 64 bits, 8 bytes long'])
    recordlen = recordlen + 8*field(i).length;
    field(i).bytes = 8;
    
otherwise
    if ~isempty(findstr('%',field(i).type)) % SCANF-style formatted data
        precision = field(i).type;
        numericCharindx = find(double(precision) >= 48 & double(precision) <= 57); % numeric character ascii codes
        if isempty(numericCharindx);
            error(['Element ' num2str(i) ' type field needs a field width for formatted input. Example: ''%8g'' '])
        end
        onefieldlen = str2num(precision(numericCharindx));
        recordlen = recordlen + 1*onefieldlen*field(i).length;
        field(i).bytes = 1*onefieldlen;
        if strcmp(field(i).type(end),'c') | strcmp(field(i).type(end),'s')
            field(i).ischar = 1; % field contains character data
        end
    else
        error(['Field type ' field(i).type ' not recognized'])
    end
end

end % for i



