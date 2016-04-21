function struc = readfields(filename,field,recordIDs,machineformat, ...
                            fid,population)
%READFIELDS Read fields or records from a fixed format file.
% 
% struc = READFIELDS(filename,filestruct) reads all the records from a
% fixed  format file.  Filename is a string containing the name of the
% file. If it  is empty, the file is selected interactively. filestruct is
% structure defining  the format of the file. The contents of filestruct
% are described below. The  result is returned in a structure.
% 
% struc = READFIELDS(filename,filestruct,recordIDs) reads only the records 
% specified in the vector recordIDs.  For example, recordIDs = [1 2 4].
% All  of the fields in the selected records are read.
% 
% struc = READFIELDS(filename,filestruct,fieldIDs) reads only the fields 
% specified in the cell array fieldIDs. For example, fieldIDs = {1 2 4}.
% The  selected fields are read from all of the records. fieldIDs may be
% used  in place of recordIDs in all calling forms.
% 
% struc = READFIELDS(filename,filestruct,recordIDs,machineformat) opens the
% file  with the specified machine format.  machineformat must be
% recognized by  FOPEN.
% 
% struc = READFIELDS(filename,filestruct,recordIDs,machineformat,fid) reads
% from a  file that is already open. The records are read starting from the
% current  location in the file. 
% 
% The format of the file is described in the input argument filestruct.  
% filestruct is a structure with one entry for every field in the file.  
% filestruct has three required fields: length, name and type.  For fields 
% containing data binary data of the type that would be read by FREAD,
% length  is the number of elements to be read, name is a string containing
% the  fieldname under which the read data will be stored in the output
% structure,  and type is a format string recognized by FREAD. Repetition
% modifiers such  as '40*char' are NOT supported.  Fields with empty
% fieldnames are omitted  from the output.
% 
% The following filestruct definition is for a file with a 40 character 
% character field, a field containing two integers, and a field with a 
% single-precision floating point number.
% 
%   filestruct(1).length = 40;     
%   filestruct(1).name = 'character Field';  % spaced will be suppressed					
%   filestruct(1).type = 'char';
%   
%   filestruct(2).length = 2;     
%   filestruct(2).name = 'integer Field';  % spaced will be suppressed					
%   filestruct(2).type = 'int16';
%   
%   filestruct(3).length = 1;     
%   filestruct(3).name = 'float Field';  % spaced will be suppressed					
%   filestruct(3).type = 'real*4';
% 
% 
% The type can also be a FSCANF and SSCANF-style format string of the form 
% '%nX', where n is the number of characters within which the formatted
% data  is found, and X is the conversion character such as g or d.  For
% formatted  fields, the length entry in filestruct is the number of
% elements, each of  which have the width specified in the type string.
% Fortran-style double  precision output such as '0.0D00' may be read using
% a type string such as  '%nD', where n is the number of characters per
% element.  This is an  extension to the C-style format strings accepted by
% SSCANF. Users unfamiliar  with C should note that '%d' is preferred over
% '%i' for formatted integers.  MATLAB follows C in interpreting '%i'
% integers with leading zeros as octal.   Line ending characters in ASCII
% files must also be counted in the filestruct  specification. Note that
% the number of line ending characters differs across  platforms.
% 
% A field specification for a formatted field with two integers each 6 
% characters wide would be
% 
%   filestruct(4).length = 2;     
%   filestruct(4).name = 'Elevation Units';  					
%   filestruct(4).type = '%6d'
% 
% To summarize, length is number of elements for binary numbers, the number
% of characters for strings, and the number of elements for formatted data.
% 
% Fields can be omitted from all output by providing an empty string for
% the  filestuct name field.
% 
% See also READMTX, TEXTREAD, SPCREAD, DLMREAD

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:23:50 $

if nargin <= 3 & nargin > 0;
	machineformat = 'native';
	filewasopen = 0;
	population = 'full';
elseif nargin == 4
	filewasopen = 0;
	population = 'full';
elseif nargin == 5;
	filewasopen = 1;
	population = 'full';
elseif nargin == 6
	if isempty(fid) 
		filewasopen = 0;
	else
		filewasopen = 1;
	end
	warning(sprintf('Sparse option for READFIELDS is obsolete. READFIELDS will correctly read \nformatted files with empty elements'))
else
	error('Incorrect number of arguments')
end

switch population
case {'sparse','full'}
otherwise
	error('population must be ''sparse'' or ''full''')
end
	
if ~filewasopen
	fid = fopen(filename,'rb', machineformat);
	
	if fid == -1
		[filename,filepath] = uigetfile(filename,['Where is ',filename,'?']);
		if filename == 0 ; return; end
		fid = fopen([filepath,filename],'rb', machineformat);
	end
end

% remove spaces from field names

for i=1:length(field)
	field(i).name = leadblnk(shiftspc(field(i).name));
end


% % find end of file
% 
% fseek(fid,0,1);
% eof = ftell(fid);
% fseek(fid,0,-1);
% pos = ftell(fid);
% 

% Read the file



if nargin <= 2 
	selectfields = num2cell(1:length(field));
	struc = readcols(fid,field,selectfields,filewasopen,population); % Fixed length records, all
elseif nargin > 2 & iscell(recordIDs)
	struc = readcols(fid,field,recordIDs,filewasopen,population); % Selected fixed length fields
else
	struc = readrows(fid,field,recordIDs,filewasopen,population); % Selected fixed length records
end

if nargin < 5
	fclose(fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function struc = readcols(fid,field,selectfields,filewasopen,population)
%READCOLS reads columns from a file with fixed length records
%

%
% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads.
%

[recordlen,field] = recordlength(field);

% find end of file to verify fixed record lengths

datastartpos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,datastartpos,-1);

% If the file does not match inputs try to be as informative as possible.
% Try to detect text files that actually do have fixed record lengths, and 
% state the actual and expected record lengths.

if ~filewasopen & mod(eof-datastartpos,recordlen) ~= 0;

	strng = fread(fid,10000,'char');
	
	CRindx = find(strng==13);
	if ~isempty(CRindx) & all( diff(diff(CRindx))==0 )
		fseek(fid,datastartpos,-1);
		actualrecordlen = length(fgets(fid));
		fclose(fid);
		error(sprintf(['File size does not match inputs. \n' ...
					'Expected record length was ' num2str(recordlen) ' bytes.\n' ...
					'Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
					]))
	end
	
	linefeedindx = find(strng==10);
	if ~isempty(linefeedindx) & all( diff(diff(linefeedindx))==0 )
		fseek(fid,datastartpos,-1);
		actualrecordlen = length(fgets(fid));
		fclose(fid);
		error(sprintf(['File size does not match inputs. \n' ...
					'Expected record length was ' num2str(recordlen) ' bytes.\n' ...
					'Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
					]))
	end

	fclose(fid);
	error(sprintf(['File size does not match inputs. ' ...
				'File size of ' num2str(eof-datastartpos) ' bytes is not evenly \n' ...
				'divisible into  ' num2str(recordlen) ' byte records.\n' ...					
				]))
end		


%
% Now read all the data for each field in succession. Put the data into a
% cellarray so that it may be converted to a structure of the same format
% as that created in reading variable length records.
%

bod = ftell(fid);	%beginning of data
carray = {};			% empty cell array; concatenate elements one field at a time

fieldsfull = [];

for i=1:length(field)
	
	if ~isempty(field(i).name) % dont save data with empty fieldnames
		fieldsfull = [fieldsfull 1];
	else
		fieldsfull = [fieldsfull 0];
	end		

	pos = ftell(fid); %get the file position at the beginning of the field

	thisfield = field(i).type;
	if ~isempty(findstr('%',thisfield)) ; thisfield = '%'; end  % SCANF-style formatted data
	
	switch thisfield

    case {	'char'   , 'char*1',...         	% character,  8 bits, 1 byte
    		'uchar'  , 'unsigned char',...  	% unsigned character,  8 bits, 1 byte
    		'schar'  , 'signed char'}    		% signed character,  8 bits, 1 byte


		fieldlen = field(i).bytes*field(i).length; % total bytes

		if ismember(i,[selectfields{:}]) & ~isempty(field(i).name)


			skip =  recordlen-fieldlen;
			
			strng = fread(fid,inf,[num2str(fieldlen) '*' field(i).type] ,recordlen-fieldlen) ;
			strng = setstr(reshape(strng,fieldlen,length(strng)/fieldlen)');
			strcell = num2cell(strvcat(strng),2);

			carray = [carray strcell];
			clear strng substr strcell

		end % if

	case '%' % SCANF-style formatted data

		fieldlen = field(i).bytes*field(i).length; % total bytes

		if ismember(i,[selectfields{:}])  & ~isempty(field(i).name)
			

			skip =  recordlen-fieldlen;
			
			strng = fread(fid,inf,[num2str(fieldlen) '*' 'char'] ,recordlen-fieldlen) ;
			strng = char(reshape(strng,fieldlen,length(strng)/fieldlen)');
			
			thisfield = field(i).type;
			if ~isempty(findstr('D',thisfield)) % extension to C conversion characters for Fortran 0.0D00 data
				strng(strng == 'D') = 'e';
				thisfield = strrep(thisfield,'D','e');
			end
		
			switch thisfield(end)
			case 'c' % character string
                
              carray = [carray num2cell(strng,2)]; % preserves all spaces
              
			case 's' % character string
						
              carray = [carray deblank(num2cell(strng,2))];  % strips trailing spaces
              
            otherwise
			
			
				% parse a column of numbers at a time to handle numbers with no spaces between
                %
                % May fail with missing numbers
				
				bytes = field(i).bytes;
				data = [];
				for k = 1:field(i).length
					strng2 = strng(:,(k-1)*bytes+(1:bytes));
				
					% insert spaces between columns to ensure separation between numbers
				
					spacecol = char(32*ones(size(strng,1),1));
					strng2 = [strng2 spacecol];

					%parse the string
							
					datacol = sscanf(strng2',thisfield([1 end])); % transpose because MATLAB works columnwise
																	% convert something like '%15g' to '%g'
																	% Safe because of space added between fields
																	% Can't use field width to skip over unwanted
																	% data, which wouldn't make sense for this function.
					
					% if some rows were empty, try to recover gracefully if they were filled with spaces
					
					if size(datacol,1) ~= size(strng2,1) 
						emptyindx = strmatch(setstr(32*ones(1,size(strng2,2))),strng2,'exact');
						notemptyindx = setxor(emptyindx,1:size(strng2,1));
					
						if ~isempty(notemptyindx)
							datacol2 = NaN*ones(size(strng2,1),1);
							datacol2(notemptyindx) = datacol;
							datacol = datacol2;
						else
							error(['Data in field ' num2str(i) ' does not match format type'])
						end
					end
				
					data = [data datacol];
					
				end
	
				carray = [carray num2cell(data,2)];
				clear data


			end % switch
		end % if

		
	otherwise % numeric

		fieldlen = field(i).bytes*field(i).length; % total bytes

		if ismember(i,[selectfields{:}]) & ~isempty(field(i).name)
			[data,count] = fread(fid,inf,[num2str(field(i).length) '*' field(i).type], recordlen-fieldlen);

			% MATLAB stores data in columns. shuffles so we can concatenate correctly
			data = reshape(data,length(data(:))/field(i).length,field(i).length);
			data = reshape(data,field(i).length,length(data(:))/field(i).length);
			data = data';

			
			carray = [carray num2cell(data,2)];
			clear data
		end %if

	end %switch

	fseek(fid,pos+fieldlen,'bof'); % reposition to just after the first field

end % for i

if ~isempty(carray)
	% this was done with magic
	
	% associate columns of the cell array with field names and return
	% as a structure
	struc = cell2struct( ...
				carray, ...
				{field( ...
					[selectfields{ ...
						find( ...
							~isnan([selectfields{:}])  & ...
							fieldsfull([selectfields{:}]) ...
						) ...
					}] ...
				).name}, ...
			2);
else
	struc = [];
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = readrows(fid,field,recordIDs,filewasopen,population)

%READROWS reads selected records from a binary file with fixed length records

struc = [];

% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads.

[recordlen,field] = recordlength(field);

% find end of file to verify fixed record lengths

datastartpos = ftell(fid);
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,datastartpos,-1);

% If the file does not match inputs try to be as informative as possible.
% Try to detect text files that actually do have fixed record lengths, and 
% state the actual and expected record lengths.

if ~filewasopen
	if mod(eof-datastartpos,recordlen) ~= 0;
		strng = fread(fid,10000,'char');
		
		CRindx = find(strng==13);
		if all( diff(diff(CRindx))==0 )
			fseek(fid,datastartpos,-1);
			actualrecordlen = length(fgets(fid));
			fclose(fid);
			error(sprintf(['File size does not match inputs. \n' ...
						'Expected record length was ' num2str(recordlen) ' bytes.\n' ...
						'Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
						]))
		end
		
		linefeedindx = find(strng==10);
		if all( diff(diff(linefeedindx))==0 )
			fseek(fid,datastartpos,-1);
			actualrecordlen = length(fgets(fid));
			fclose(fid);
			error(sprintf(['File size does not match inputs. \n' ...
						'Expected record length was ' num2str(recordlen) ' bytes.\n' ...
						'Actual record length was ' num2str(actualrecordlen) ' bytes.\n' ...					
						]))
		end
	
		fclose(fid);
		error(sprintf(['File size does not match inputs. ' ...
					'File size of ' num2str(eof-datastartpos) ' bytes is not evenly \n' ...
					'divisible into  ' num2str(recordlen) ' byte records.\n' ...					
					]))
	end
end

%
% read the data
%

j=0;
for k=recordIDs

	j=j+1;

%
% jump to begining of a desired record and then read fields
%
	status = fseek(fid,datastartpos+(k-1)*recordlen,-1);
	if ftell(fid) >= eof | status == -1 ; 
		error('File does not contain the requested record'); 
	end

	for i=1:length(field)

		thisfield = field(i).type;
		if ~isempty(findstr('%',thisfield)) ; thisfield = '%'; end  % SCANF-style formatted data

		switch thisfield

        case {	'char'   , 'char*1',...         	% character,  8 bits, 1 byte
        		'uchar'  , 'unsigned char',...  	% unsigned character,  8 bits, 1 byte
        		'schar'  , 'signed char'}    		% signed character,  8 bits, 1 byte

			len = field(i).length;
			strng = fread(fid, len, field(i).type);
			strng = setstr(strng');
			strng = deblank(strng);
			
			if ~isempty(field(i).name)
				struc = setfield(struc,{j},field(i).name,strng);
			end
			
		case '%' % SCANF-style formatted data
			len = field(i).length*field(i).bytes;
			strng = fread(fid, len, 'char');
			strng = char(strng');
			strAsRead = strng;
			
			thisfield = field(i).type;
			if ~isempty(findstr('D',thisfield)) % extension to C conversion characters for Fortran 0.0D00 data
				strng = strrep(strng,'D','e');
				thisfield = strrep(thisfield,'D','e');
			end
			savestr = strng;
			
			switch thisfield(end)
			case 'c' % character string

				num = strng;
				
			otherwise
		
				if ~isempty(field(i).name)
					% process string to ensure that there are spaces between the fields
					% Do this because sscanf won't recognize fixed length scan strings ('%24e')
					% with data that has leading spaces. 
		
					if field(i).length > 1 % use a tricky vectorized method to insert spaces
						indxvec = zeros(1,len+field(i).length-1); 				% initialize index vector the size of the new string
						indxvec((1:field(i).length-1)*(field(i).bytes+1)) = 1; 	% stick in ones at the breaks between fields
						indxvec = cumsum(indxvec);								% all locations within a field now have field number minus one
						indxvec = -indxvec + (1:length(indxvec));				% these are now locations within the original vector
						indxvec((1:field(i).length-1)*(field(i).bytes+1)) = NaN;% use NaNs to avoid writing over newly inserted spaces
						
						newstr = char(32*ones(1,len+field(i).length-1));		% initialize string of spaces
						newstr(~isnan(indxvec)) = strng(indxvec(~isnan(indxvec)));					% map characters from old string into new on
						strng = newstr;
					end
					
					% parse the string
					[num,count] = sscanf(strng,thisfield([1 end])); % convert '%15g' to '%g'
																	% Safe because of space added between fields
																	% Can't use field width to skip over unwanted
																	% data, which wouldn't make sense for this function.
		
					if count ~= field(i).length  % Didn't read as many values as expected, so there may be empty elements in the field.
	
						num = [];
						bytes = field(i).bytes;
						for k = 1:field(i).length % Read each element. At least we gave the vecorized method a shot
							strng2 = strng(:,(k-1)*bytes+(k-1)+(1:bytes));
							[thisnum,count] = sscanf(strng2,thisfield([1 end]),1);
							if count~=1
								thisnum = NaN;
							end
							num = [num thisnum];
						end
								
					end
				end 	% ~isempty(field(i).name)		
			end % switch
		
			if ~isempty(field(i).name)
				struc = setfield(struc,{j},field(i).name,num(:)'); % ensure row vectors
			end
			
		otherwise

			num = fread(fid, field(i).length, field(i).type);
			struc = setfield(struc,{j},field(i).name,num);

		end %switch
	end % for i

   pos = ftell(fid);

end % while

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [recordlen,field] = recordlength(field,fid)

%RECORDLENGTH computes the length of a record by summing lengths of fields

% First determine how many bytes are in each record. Need this to know how
% many bytes to skip between successive reads. Can't simply read a record
% with FGETL and measure the length, because this may result in read the 
% whole file. Bad idea if files are very large.

recordlen = 0;

for i=1:length(field)

	switch field(i).type

% Platform indpendent precision strings

        case {	'char'   , 'char*1',...         	% character,  8 bits, 1 byte
        		'uchar'  , 'unsigned char',...  	% unsigned character,  8 bits, 1 byte
        		'schar'  , 'signed char',...    	% signed character,  8 bits, 1 byte
        		'int8'   , 'integer*1',...   		% integer, 8 bits, 1 byte
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
				numericCharindx = find( (double(precision) >= 48 & double(precision) <= 57) | double(precision) == 46 ) ; % numeric character ascii codes

				decimalpointindx = find(double(precision(numericCharindx)) == 46 ) ; % decimalpoint location
				if ~isempty(decimalpointindx) & decimalpointindx >1
						numericCharindx = numericCharindx(1:decimalpointindx-1); % in C, field length precedes the decimal point
				end
				
				if isempty(numericCharindx) | (  ~isempty(decimalpointindx) & decimalpointindx == 1);
					error(['Element ' num2str(i) ' type field needs a field width for formatted input. Example: ''%8g'' '])
				end
				onefieldlen = str2num(precision(numericCharindx));
				recordlen = recordlen + 1*onefieldlen*field(i).length;
				field(i).bytes = 1*onefieldlen;
			else
				fclose(fid)
				error(['Field type ' field(i).type ' not recognized'])
			end
		end

end % for i


