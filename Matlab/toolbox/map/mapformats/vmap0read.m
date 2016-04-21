function [struc,field,varlen,description,narrativefile] = vmap0read( ...
                                  filepath,filename,recordIDs,field,varlen)
%VMAP0READ Read a Vector Map Level 0 file.
%
% VMAP0READ reads a VMAP0 file.  The user may select the file
% interactively.
%
% VMAP0READ(filepath,filename) reads the specified file.  The combination
% [filepath filename] must form a valid complete filename.
%
% VMAP0READ(filepath,filename,recordIDs) reads selected records or fields
% from the file.  If recordIDs is a scalar or a vector of integers, the
% function returns the selected records.  If recordIDs is a cellarray of
% integers, all records of the associated fields are returned.
%
% VMAP0READ(filepath,filename,recordIDs,field,varlen) uses previously read
% field and variable length record information to skip parsing the file
% header.
%
% struc = VMAP0READ...  returns the file contents in a structure.
%
% [struc,field] = VMAP0READ...  returns the contents and a structure
% describing the format of the file.
%
% [struc,field,varlen] = VMAP0READ ...  also returns a vector describing
% which fields have variable length records.
%
% [struc,field,varlen,description] = VMAP0READ ...  adds the string
% describing the contents of the file to the output arguments.
%
% [struc,field,varlen,description,narrativefile] = VMAP0READ ...  also
% returns the name of the narrative file for the current file.
%
% See also VMAP0DATA, VMAP0GAZ, VMAP0RHEAD

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%   $Revision: 1.1.6.2 $    $Date: 2003/12/13 02:57:06 $

if nargin >= 2

	if isempty(filepath) | isempty(filename)
		[filename,filepath] = uigetfile('*',['Select the VMAP0 file']);
		if filename == 0 ; return; end
	end
	
	fid = fopen([filepath,filename],'rb', 'ieee-le');

	if fid == -1
		filename = lower(filename);
		fid = fopen([filepath,filename],'rb', 'ieee-le');
		if fid == -1
			filename = [filename '.'];
			fid = fopen([filepath,filename],'rb', 'ieee-le');
			if fid == -1
				[filename,filepath] = uigetfile(filename,['Where is ',filename,'?']);
				if filename == 0 ; return; end
				fid = fopen([filepath,filename],'rb', 'ieee-le');
			end
		end
	end
elseif nargin ==0
	[filename,filepath] = uigetfile('*',['Select a VMAP0 file']);
	if filename == 0 ; return; end
	fid = fopen([filepath,filename],'rb', 'ieee-le');
elseif nargin~= 3 | nargin~= 5
	error('Incorrect number of arguments')
end

% find end of file

fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,0,-1);
pos = ftell(fid);


% read the header string. This will be parsed to get the file format

headerstring = [];
headerstring = vmap0rhead(filepath,filename,fid);
headerstring(1) = [];                                % extra character added in vmap0

if strcmp(headerstring(1),';') + strcmp(headerstring(length(headerstring)),';') ~=2
	fclose(fid);
	error('File is not in General VMAP0 format')
end

%
% parse the header
%

if nargin < 5
	[field,varlen,description,narrativefile] =  vmap0phead(headerstring);
end

%
% Having parsed the file format, read the data. Can read a selected
% records or all data. If all data is fixed format, take advantage
% of fixed format to speed parsing.
%

if isempty(varlen) & nargin <= 2
% 	disp('Fixed length records, all')
	selectfields = num2cell(1:length(field));
	struc = vmap0fixlen(fid,field,selectfields);
elseif isempty(varlen) & nargin > 2 & iscell(recordIDs)
% 	disp('Selected fixed length fields')
	struc = vmap0fixlen(fid,field,recordIDs);
elseif isempty(varlen) & nargin > 2
% 	disp('Selected fixed length records')
	struc = vmap0fixsub(fid,field,recordIDs);
elseif ~isempty(varlen) & nargin <=2
% 	disp('Variable length records, all')
	struc = vmap0varlen(fid,field,varlen);
elseif ~iscell(recordIDs)
% 	disp('Variable length records, selected records')
	xfilename = filename;
	xfilename(length(xfilename))='X';
	if isunix; xfilename = lower(xfilename); end
	xfid = fopen([filepath xfilename],'r');
	if xfid == -1; 
		xfilename(length(xfilename))='x';
		xfid = fopen([filepath xfilename],'r');
		if xfid == -1; error(['Index file ' xfilename ' not found']); end
	end
	fclose(xfid);

	X = vmap0rdx(filepath,xfilename);
	X = X(1,:);

	struc = vmap0varsub(fid,field,varlen,X(recordIDs));
else 
% 	disp('Variable length records, selected fields')
	struc = vmap0varlenFields(fid,field,varlen,recordIDs);
end

fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = linewrap(str)
%LINEWRAP wraps a string to fit on screen
%
% replaces spaces near the end of the line with carriage returns
% for single strings or padded string arrays
%

if isempty(str); return; end

sz = size(str);
linelen = 80;

if sz(2) < linelen; return; end

for j=1:sz(1)
	substr = str(j,:);
	spaceindx  = find(substr==32);

	mx = max(spaceindx);


	for i=1:floor(mx/linelen)

		enddist = abs(spaceindx - i*linelen);
		breakpos = find(min(enddist)==enddist);
		substr(spaceindx(breakpos))=char(13);
	end

	str(j,1:sz(2)) = substr;

 end %for j

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = vmap0varsub(fid,field,varlen,byteoffsets)
%VMAP0VARSUB reads selected records from a Digital Chart of the World (VPF) file with variable length records
%
%%%%%%%%%%%%%%%%%%%%%%%%%

% find end of file

pos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,pos,-1);

struc = [];
for j=1:length(byteoffsets)

	fseek(fid,byteoffsets(j),-1);

%    if mod(j,100) == 0 ; disp(pos/eof); end
	for i=1:length(field)

		switch field(i).type

		case 'T'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			str = fread(fid, len, 'char');
			str = deblank(setstr(str'));
			str = linewrap(str);
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'F'

			num = fread(fid, field(i).length , 'real*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'R'

			num = fread(fid, field(i).length , 'real*8');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'S'

			num = fread(fid,1,'integer*2');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'I'

			num = fread(fid,1,'integer*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'C'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'B'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Z'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Y'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'D'

			str = fread(fid, [field(i).length 20], 'char');
			str = setstr(str);
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'K'

% read the type bytes. this is list of four two-bit integers indicating
% the lengths of the following integer fields. Only 3 fields are used; the
% last type byte is reserved.

			typebytes   = fliplr(fread(fid,4,'ubit2')');

			triplet = [];
			for k=1:3
				if typebytes(k)==0
					break
				elseif typebytes(k)==1
					id = fread(fid,1,'uint8');  %'integer*1'
					triplet = [triplet id];
				elseif typebytes(k)==2
					id = fread(fid,1,'uint16'); % 'integer*2'
					triplet = [triplet id] ;
				else                          %if typebytes(i)==3
					id = fread(fid,1,'uint32');  %'integer*4'
					triplet = [triplet id] ;
				end
			end
			eval(['struc(j).' field(i).name '= triplet;'  ]);

		case 'X'

		otherwise

			error(['Field type ' field(i).type ' not implemented'])

		end %switch
	end % for i

   pos = ftell(fid);

end % while

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = vmap0varlen(fid,field,varlen)
%VMAP0VARLEN reads a Digital Chart of the World (VPF) file with variable length records
%
%%%%%%%%%%%%%%%%%%%%%%%%%

% find end of file

pos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,pos,-1);

struc = [];
j=0;
while( pos ~= eof);
   j=j+1;
%    if mod(j,100) == 0 ; disp(pos/eof); end
	for i=1:length(field)

		switch field(i).type

		case 'T'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			str = fread(fid, len, 'char');
			str = deblank(setstr(str'));
			str = linewrap(str);
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'F'

			num = fread(fid, field(i).length , 'real*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'R'

			num = fread(fid, field(i).length , 'real*8');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'S'

			num = fread(fid,1,'integer*2');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'I'

			num = fread(fid,1,'integer*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'C'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'B'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Z'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Y'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'D'

			str = fread(fid, [field(i).length 20], 'char');
			str = setstr(str);
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'K'

% read the type bytes. this is list of four two-bit integers indicating
% the lengths of the following integer fields. Only 3 fields are used; the
% last type byte is reserved.

			typebytes   = fliplr(fread(fid,4,'ubit2')');

			triplet = [];
			for k=1:3
				if typebytes(k)==0
					break
				elseif typebytes(k)==1
					id = fread(fid,1,'uint8');  %'integer*1'
					triplet = [triplet id];
				elseif typebytes(k)==2
					id = fread(fid,1,'uint16'); % 'integer*2'
					triplet = [triplet id] ;
				else                          %if typebytes(i)==3
					id = fread(fid,1,'uint32');  %'integer*4'
					triplet = [triplet id] ;
				end
			end
			eval(['struc(j).' field(i).name '= triplet;'  ]);

		case 'X'

		otherwise

			error(['Field type ' field(i).type ' not implemented'])

		end %switch
	end % for i

   pos = ftell(fid);

end % while


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = vmap0varlenFields(fid,field,varlen,fieldIDs)
%VMAP0VARLENFields reads selected fields from a file with variable length records
%
%%%%%%%%%%%%%%%%%%%%%%%%%

% find end of file

pos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,pos,-1);


fieldIDs = [fieldIDs{:}];

struc = [];
j=0;
while( pos ~= eof);
   j=j+1;
%    if mod(j,100) == 0 ; disp(pos/eof); end
	for i=1:length(field)

		switch field(i).type

		case 'T'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			str = fread(fid, len, 'char');
			if ismember(i,fieldIDs)
				str = deblank(setstr(str'));
				str = linewrap(str);
				eval(['struc(j).' field(i).name '=  str;'  ]);
			end
		case 'F'

			num = fread(fid, field(i).length , 'real*4');
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'R'

			num = fread(fid, field(i).length , 'real*8');
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'S'

			num = fread(fid,1,'integer*2');
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'I'

			num = fread(fid,1,'integer*4');
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'C'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*4')';
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'B'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [2 len], 'real*8')';
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'Z'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*4')';
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'Y'

			len = field(i).length;
			if ismember(i,varlen)
				len = fread(fid,1,'integer*4');
			end

			num = fread(fid, [3 len], 'real*8')';
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= num;'  ]);
			end
		case 'D'

			str = fread(fid, [field(i).length 20], 'char');
			str = setstr(str);
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '=  str;'  ]);
			end
		case 'K'

% read the type bytes. this is list of four two-bit integers indicating
% the lengths of the following integer fields. Only 3 fields are used; the
% last type byte is reserved.

			typebytes   = fliplr(fread(fid,4,'ubit2')');

			triplet = [];
			for k=1:3
				if typebytes(k)==0
					break
				elseif typebytes(k)==1
					id = fread(fid,1,'uint8');  %'integer*1'
					triplet = [triplet id];
				elseif typebytes(k)==2
					id = fread(fid,1,'uint16'); % 'integer*2'
					triplet = [triplet id] ;
				else                          %if typebytes(i)==3
					id = fread(fid,1,'uint32');  %'integer*4'
					triplet = [triplet id] ;
				end
			end
			if ismember(i,fieldIDs)
				eval(['struc(j).' field(i).name '= triplet;'  ]);
			end
		case 'X'

		otherwise

			error(['Field type ' field(i).type ' not implemented'])

		end %switch
	end % for i

   pos = ftell(fid);

end % while

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = vmap0fixlen(fid,field,selectfields)
%VMAP0FIXLEN reads a Digital Chart of the World (VPF) file with fixed length records
%

%
% With fixed length records, the data can be read in one vectorized command.
% This is potentially much faster than parsing the fields on each line.
%

%
% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads.
%

recordlen = 0;

for i=1:length(field)

	switch field(i).type
	case 'T'							% text characters
		recordlen = recordlen + 1*field(i).length;
	case 'F'							% floating point (4 bytes)
		recordlen = recordlen + 4*field(i).length;
	case 'R'							% double precision floating point (8 bytes)
		recordlen = recordlen + 8*field(i).length;
	case 'S'							% short integer (2 bytes)
		recordlen = recordlen + 2*field(i).length;
	case 'I'							% long integer (4 bytes)
		recordlen = recordlen + 4*field(i).length;
	case 'C'							% real coordinate pair-(2x4 bytes)
		recordlen = recordlen + 8*field(i).length;
	case 'B'							% double coordinate pair-(2x8 bytes)
		recordlen = recordlen + 16*field(i).length;
	case 'Z'							% real coordinate triple-(3x4 bytes)
		recordlen = recordlen + 12*field(i).length;
	case 'Y'							% double coordinate triple-(3x8 bytes)
		recordlen = recordlen + 24*field(i).length;
	case 'D'							% date (20 characters)
		recordlen = recordlen + 20*field(i).length;
	case 'X'                            % null field
	otherwise
		error(['Field type ' field(i).type ' not implemented'])
	end %switch
end % for i



%
% Now read all the data for each field in succession. Put the data into a
% cellarray so that it may be converted to a structure of the same format
% as that created in reading variable length records.
%

bod = ftell(fid);	%beginning of data
carray = {};			% empty cell array; concatenate elements one field at a time

struc = [];
for i=1:length(field)

	switch field(i).type

	case 'T' % text characters

%
% Can't vectorize reading more than one element, so read all the data as
% strings, then subscript in to get the bytes we need. The reading is
% not very time-consuming when vectorized, and it's certainly much faster
% than going line by line.
%
% Reading all the data at once to then extract only a small fraction of it
% can lead to memory problems. Instead read a block of lines, extract the
% data, and repeat.
%

		pos = ftell(fid); %get the file position at the beginning of the field
		fseek(fid,bod,'bof'); % reposition to just after the first field

		fieldlen = 1*field(i).length; % bytes

		if ismember(i,[selectfields{:}])

			skip =  recordlen-fieldlen;

			strcell = {};
			blocksize = 200; %lines of data
			while 1

				[str,count] = fread(fid, [recordlen blocksize], 'char'); % read all the records and subscript in later; can't read adjacent data and then skip

				str = str'	;
				str = linewrap(setstr(str(:,pos-bod+1:pos-bod+fieldlen)));
				strcell = [strcell ; deblank(num2cell(str,2)) ];

				if count < blocksize; break; end % must have run into end of file

			end %while

			carray = [carray strcell];
			clear str substr strcell

		end % if

		fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

	case 'F' % floating point (4 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 4; %bytes

		if ismember(i,[selectfields{:}])
			[data,count] = fread(fid,inf,'real*4', recordlen-fieldlen);

			carray = [carray num2cell(data,2)];
			clear data
		end %if

		fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

	case 'R' % double precision floating point (8 bytes)


		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 8; %bytes

		if ismember(i,[selectfields{:}])
			[data,count] = fread(fid,inf,'real*8', recordlen-fieldlen);

			carray = [carray num2cell(data,2)];
			clear data
		end %if

		fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

	case 'S' % short integer (2 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 2; %bytes

		if ismember(i,[selectfields{:}])
			[data,count] = fread(fid,inf,'integer*2', recordlen-fieldlen);

			carray = [carray num2cell(data,2)];
			clear data

		end % if

		fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

	case 'I' % long integer (4 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 4; %bytes

		if ismember(i,[selectfields{:}])

			[data,count] = fread(fid,inf,'integer*4', recordlen-fieldlen);

			carray = [carray num2cell(data,2)];
			clear data

		end %if

		fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

	case 'C' % real coordinate pair-(2x4 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 4; %bytes (but two columns of them)

		if ismember(i,[selectfields{:}])

			datarray = [];
			for j=1:2

				[data,count] = fread(fid,inf,'real*4', recordlen-fieldlen);
				datarray = [datarray data];
				fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

			end %j

			carray = [carray num2cell(datarray,2)];
			clear data

		end %if

	case 'B' % double coordinate pair-(2x8 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 8; %bytes (but two columns of them)

		if ismember(i,[selectfields{:}])

			datarray = [];
			for j=1:2

				[data,count] = fread(fid,inf,'real*8', recordlen-fieldlen);
				datarray = [datarray data];
				fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

			end %j

			carray = [carray num2cell(datarray,2)];
			clear data

		end %if

	case 'Z' % real coordinate triple-(3x4 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 4; %bytes (but three columns of them)

		if ismember(i,[selectfields{:}])

			datarray = [];
			for j=1:3

				[data,count] = fread(fid,inf,'real*4', recordlen-fieldlen);
				datarray = [datarray data];
				fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

			end %j

			carray = [carray num2cell(datarray,2)];
			clear data

		end %if

	case 'Y' % double coordinate triple-(3x8 bytes)

		pos = ftell(fid); %get the file position at the beginning of the field
		fieldlen = 8; %bytes (but three columns of them)

		if ismember(i,[selectfields{:}])

			datarray = [];
			for j=1:3

				[data,count] = fread(fid,inf,'real*8', recordlen-fieldlen);
				datarray = [datarray data];
				fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

			end %j

			carray = [carray num2cell(datarray,2)];
			clear data

		end %if

	case 'D' % date (20 characters)


%
% Can't vectorize reading more than one element, so read all the data as
% strings, then subscript in to get the bytes we need. The reading is
% not very time-consuming when vectorized, and it's certainly much faster
% than going line by line.
%
% Reading all the data at once to then extract only a small fraction of it
% can lead to memory problems. Instead read a block of lines, extract the
% data, and repeat.
%

		pos = ftell(fid); %get the file position at the beginning of the field
		fseek(fid,bod,'bof'); % reposition to just after the first field

		fieldlen = 20*field(i).length; % bytes

		if ismember(i,[selectfields{:}])

			skip =  recordlen-fieldlen;


			strcell = {};
			blocksize = 200; %lines of data
			while 1

				[str,count] = fread(fid, [recordlen blocksize], 'char'); % read all the records and subscript in later; can't read adjacent data and then skip

				str = str'	;
				str = setstr(str(:,pos-bod+1:pos-bod+fieldlen));
				strcell = [strcell ; deblank(num2cell(str,2)) ];

				if count < blocksize; break; end % must have run into end of file

			end %while

			carray = [carray strcell];
			clear str substr strcell

		end % if

		fseek(fid,pos+fieldlen,'bof'); 	% reposition to just after the first field

	case 'X'
		selectfields{i} = NaN;			% remove from list of fields later
	otherwise

		error(['Field type ' field(i).type ' not implemented'])

	end %switch
end % for i

if ~isempty(carray)
	struc = cell2struct(carray,{field(find(~isnan([selectfields{:}]))).name},2);
else
	struc = [];
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = vmap0fixsub(fid,field,recordIDs)
%VMAP0FIXSUB reads selected records from a Digital Chart of the World (VPF) file with fixed length records
%
%%%%%%%%%%%%%%%%%%%%%%%%%

% find end of file

datastartpos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,datastartpos,-1);

%
% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads.
%

recordlen = 0;

for i=1:length(field)

	switch field(i).type
	case 'T'							% text characters
		recordlen = recordlen + 1*field(i).length;
	case 'F'							% floating point (4 bytes)
		recordlen = recordlen + 4*field(i).length;
	case 'R'							% double precision floating point (8 bytes)
		recordlen = recordlen + 8*field(i).length;
	case 'S'							% short integer (2 bytes)
		recordlen = recordlen + 2*field(i).length;
	case 'I'							% long integer (4 bytes)
		recordlen = recordlen + 4*field(i).length;
	case 'C'							% real coordinate pair-(2x4 bytes)
		recordlen = recordlen + 8*field(i).length;
	case 'B'							% double coordinate pair-(2x8 bytes)
		recordlen = recordlen + 16*field(i).length;
	case 'Z'							% real coordinate triple-(3x4 bytes)
		recordlen = recordlen + 12*field(i).length;
	case 'Y'							% double coordinate triple-(3x8 bytes)
		recordlen = recordlen + 24*field(i).length;
	case 'D'							% date (20 characters)
		recordlen = recordlen + 20*field(i).length;
	case 'X'
	otherwise
		error(['Field type ' field(i).type ' not implemented'])
	end %switch
end % for i


%
% read the data
%

struc = [];
j=0;
for k=recordIDs

	j=j+1;
%	disp([j k])

%
% jump to begining of a desired record and then parse fields
%
	fseek(fid,datastartpos+(k-1)*recordlen,-1);

	for i=1:length(field)

		switch field(i).type

		case 'T'

			len = field(i).length;
			str = fread(fid, len, 'char');
			str = setstr(str');
			str = deblank(linewrap(str));
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'F'

			num = fread(fid, field(i).length , 'real*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'R'

			num = fread(fid, field(i).length , 'real*8');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'S'

			num = fread(fid,1,'integer*2');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'I'

			num = fread(fid,1,'integer*4');
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'C'

			len = field(i).length;

			num = fread(fid, [2 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'B'

			len = field(i).length;

			num = fread(fid, [2 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Z'

			len = field(i).length;

			num = fread(fid, [3 len], 'real*4')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'Y'

			len = field(i).length;

			num = fread(fid, [3 len], 'real*8')';
			eval(['struc(j).' field(i).name '= num;'  ]);

		case 'D'

			str = fread(fid, [field(i).length 20], 'char');
			str = setstr(str);
			eval(['struc(j).' field(i).name '=  str;'  ]);

		case 'K'

% read the type bytes. this is list of four two-bit integers indicating
% the lengths of the following integer fields. Only 3 fields are used; the
% last type byte is reserved.

			typebytes   = fliplr(fread(fid,4,'ubit2')');

			triplet = [];
			for k=1:3
				if typebytes(k)==0
					break
				elseif typebytes(k)==1
					id = fread(fid,1,'uint8');  %'integer*1'
					triplet = [triplet id];
				elseif typebytes(k)==2
					id = fread(fid,1,'uint16'); % 'integer*2'
					triplet = [triplet id] ;
				else                          %if typebytes(i)==3
					id = fread(fid,1,'uint32');  %'integer*4'
					triplet = [triplet id] ;
				end
			end
			eval(['struc(j).' field(i).name '= triplet;'  ]);

		case 'X'

		otherwise

			error(['Field type ' field(i).type ' not implemented'])

		end %switch
	end % for i

   pos = ftell(fid);

end % while

return

