function [mtextstruc,mpointstruc] = dcwgaz(varargin)
%DCWGAZ Search for entries in a Digital Chart of the World Gazette file.
%
% DCWGAZ(LIBRARY, OBJECT) searches the DCW gazette for items beginning with
% the object string.  There are four CD's, one for each library: 'NOAMER'
% (North America), 'SASAUS' (Southern Asia and Australia), 'EURNASIA'
% (Europe and Northern Asia) and 'SOAMAFR' (South America and Africa).
% Items which exactly match or begin with the object string are displayed
% on screen.
%
% MTEXTSTRUCT = DCWGAZ(LIBRARY, OBJECT) displays the matched items on
% screen and returns a Mapping Toolbox Geographic Data Structure with the
% matches as text entries.  This structure contains the latitude, longitude
% and theme.
%
% [MTEXTSTRUC, MPOINTSTRUC] = DCWGAZ(LIBRARY, OBJECT) returns the matches
% in structures formatted as text and as points.
%
% [...] = DCWGAZ(DEVICENAME, LIBRARY, OBJECT) specifies the logical device
% name of the CD-ROM for computers which do not automatically name the
% mounted disk.
%
% See also DCWDATA, DCWREAD, DCWRHEAD, MLAYERS, DISPLAYM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:20:49 $

%
% check inputs
%

if nargin == 2 % no devicename required?
	diskname = varargin{1};
	object = varargin{2};
	devicename = diskname;
elseif nargin ==3 ;
	devicename = varargin{1};
	diskname = varargin{2};
	object = varargin{3};
else
	error('Incorrect number of arguments');
end


% set up to print to screen

prnt =1;

% Check that the top of the database file heirarchy is visible,
% and note the case of the directory and filenames.

filepath = fullfile(devicename,filesep);
dirstruc = dir(filepath);
if isempty(strmatch('DCW',upper(strvcat(dirstruc.name)),'exact'))
	error(['DCW disk ' upper(diskname) ' not mounted or incorrect devicename ']); 
end

if ~isempty(strmatch('DCW',{dirstruc.name},'exact'))
	filesystemcase = 'upper';
elseif ~isempty(strmatch('dcw',{dirstruc.name},'exact'))
	filesystemcase = 'lower';
else
	error('Unexpected mixed case filenames')
end


% build the pathname so that [pathname filename] is the full filename

switch filesystemcase
case 'upper'
	filepath = fullfile(devicename,'DCW',upper(diskname),'GAZETTE',filesep);
	filename = 'GAZETTE.PFT';
case 'lower'
	filepath = fullfile(devicename,'dcw',lower(diskname),'gazette',filesep);
	filename = 'gazette.pft';
end

dirstruc = dir(filepath);
if isempty(dirstruc)
	error(['DCW disk ' upper(diskname) ' not mounted or incorrect devicename ']); 
end

% open feature table

fid = fopen([filepath,filename],'rb', 'ieee-le');
if fid == -1
	[filename,filepath] = uigetfile(filename,['Where is ',filename,'?']);
	if filename == 0 ; return; end
	fid = fopen([filepath,filename],'rb', 'ieee-le');
end

% find end of file

fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,0,-1);
pos = ftell(fid);


% read the header string. This will be parsed to get the file format

headerstring = [];
headerstring = dcwrhead(filepath,filename,fid);

if strcmp(headerstring(1),';') + strcmp(headerstring(length(headerstring)),';') ~=2
	fclose(fid);
	error('File is not in General DCW format')
end

%
% parse the header
%

[field,varlen] =  dcwphead(headerstring);

%
% Having parsed the file format, cycle through the records searching
% for matches to the object
%

if isempty(varlen)

	struc = dcwgsrch(fid,field,object,eof,prnt);
	fclose(fid);

	if isempty(struc) ;
		mtextstruc = [];
		mpointstruc = [];
		return;
	end %if

	END = dcwread(filepath,'END',[struc.ID]);

	for i=1:length(struc)

		mtextstruc(i).type= 'text';
		mtextstruc(i).otherproperty= {'fontsize',[9]};


		mtextstruc(i).tag=deblank(struc(i).TYPE);
		mtextstruc(i).string=deblank(struc(i).PLACE_NAME);
		mtextstruc(i).altitude= [];


		ll = END(i).COORDINATE;
		mtextstruc(i).lat=ll(:,2);
		mtextstruc(i).long=ll(:,1);

		if length(ll(:,1)) > 1

			dx = ll(2,1) - ll(1,1);
			dy = ll(2,2) - ll(1,2);
			ang = 180/pi*(atan2(dy,dx));
			mtextstruc(i).otherproperty= {'fontsize',[9], 'rotation',ang};

		end %if

	end % for

	if nargout ==2
		mpointstruc = mtextstruc;

		for i=1:length(struc)
			mpointstruc(i).type = 'line';
			mpointstruc(i).otherproperty ={};

		end % for
	end %if
else
	error('Error reading Gazette file: variable length records')
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = dcwgsrch(fid,field,object,eof,prnt)
%dcwgsrch reads a Digital Chart of the World (VPF) file with fixed length records
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

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 8*field(i).length;
	case 'S'							% short integer (2 bytes)
		recordlen = recordlen + 2*field(i).length;
	case 'I'							% long integer (4 bytes)
		recordlen = recordlen + 4*field(i).length;
	case 'C'							% real coordinate pair-(2x4 bytes)

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 8*field(i).length;
	case 'B'							% double coordinate pair-(2x8 bytes)

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 16*field(i).length;
	case 'Z'							% real coordinate triple-(3x4 bytes)

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 12*field(i).length;
	case 'Y'							% double coordinate triple-(3x8 bytes)

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 24*field(i).length;
	case 'D'							% date (20 characters)

		struc = dcwvarlen(fid,field,[])
		return

		recordlen = recordlen + 20*field(i).length;
	case 'X'
	otherwise
		error(['Can''t read field type ' field(i).type])
	end %switch
end % for i

%
% Now read all the data for each field in succession. Put the data into a
% cellarray so that it may be converted to a structure of the same format
% as that created in reading variable length records.
%
%


struc = [];
k=0;
blocksize = 2000; %lines of data

while 1


	pos = ftell(fid);

	for i=1:length(field)

		bod = ftell(fid);	%beginning of data

		switch field(i).type
		case 'T'

%
% Can't vectorize reading more than one element, so read all the data as
% strings, then subscript in to get the bytes we need. The reading is
% not very time-consuming when vectorized, and it's certainly much faster
% than going line by line.
%
% Reading all the data at once to then extract only a small percentage of it
% can lead to memory problems. Instead read a block of lines, extract the
% data, and repeat.
%

			pos = ftell(fid); %get the file position at the beginning of the field
			fseek(fid,bod,'bof'); % reposition to just after the first field

			fieldlen = 1*field(i).length; % bytes
			skip =  recordlen-fieldlen;

			str = [];
			[substr,count{i}] = fread(fid, [recordlen blocksize], 'char'); % read all the records and subscript in later; can't read adjacent data and then skip
			substr =substr'	;


			savedata{i} =  setstr(substr(:,pos-bod+1:pos-bod+fieldlen));

			clear  substr

			fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

		case 'I'


			pos = ftell(fid); %get the file position at the beginning of the field
			fieldlen = 4; %bytes
			[data,count{i}] = fread(fid,blocksize,'integer*4', recordlen-fieldlen);

			savedata{i} = data;

			clear data

			fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

		otherwise

			error(['Unexpected field type ' field(i).type ' in Gazette File'])

		end %switch
	end % for i

	indx = strmatch(lower(object(:)'), lower(savedata{2}));

	for n=1:length(indx)

		if prnt; disp(savedata{2}(indx(n),:)); end

		k=k+1;

		for i=1:length(field)
			eval(['struc(k).' field(i).name '=  savedata{i}(indx(n),:);'  ]);

		end
	end

	if count{1} < blocksize; break; end % must have run into end of file

	pos = ftell(fid); %get the file position at the beginning of the field
	fseek(fid,pos+(blocksize-1)*recordlen,'bof'); % reposition to just after the first field
end %while



return

