function [varargout] = textscan(varargin)
%TEXTSCAN Read formatted data from text file.
%   C = TEXTSCAN(FID,'FORMAT')
%   C = TEXTSCAN(FID,'FORMAT',N)
%   C = TEXTSCAN(FID,'FORMAT',PARAMETER,VALUE, ...)
%   C = TEXTSCAN(FID,'FORMAT',N,PARAMETER,VALUE, ...) reads data from the text
%   file identified by FID into cell array C. The data are parsed into
%   fields and converted according to the conversions specified in the
%   string, FORMAT. The number of cells in C will equal the number of
%   conversion specifiers in FORMAT.  The type of each cell is determined
%   by FORMAT. 
%
%	If TEXTSCAN fails to convert a data field, it stops reading and returns
%	all fields read before the failure. You may resume reading from the
%	file by calling TEXTSCAN again, with the original FID as the first
%	argument. When finished reading from the file, you should close the
%	file by calling FCLOSE(FID).
%
%   TEXTSCAN regards a text file as consisting of blocks. Each block
%   consists of a number of internally consistent fields. Each field
%   consists of a group of characters delimited by a field delimiter
%   character (DLM). The fields may span over a number of rows. Each row is
%   delimited by an End-Of-Line (EOL) character sequence.    
%
%   The FORMAT string is of the form: 		%<WIDTH>.<PREC><SPECIFIER>
%   <WIDTH> is optional and specifies the number of characters in a field
%		to read. Setting <WIDTH> to * causes TEXTSCAN to skip the particular
%		field in the input and no output cell is created for this
%		conversion.
%   <PREC> only applies to the family of %f specifiers and states the
%		number of significant fractional digits to be converted. 
%   <SPECIFIER> must be given and determines the conversion output type.
%
%   Supported FORMAT specifiers:
%       %n   - read and convert a number to double
%       %d   - read and convert a number to int32
%       %d8  - read and convert a number to int8
%       %d16 - read and convert a number to int16
%       %d32 - read and convert a number to int32
%       %d64 - read and convert a number to int64 
%       %u   - read a number and convert to uint32 
%       %u8  - read and convert a number to uint8 
%       %u16 - read and convert a number to uint16
%       %u32 - read a number and convert to uint32 
%       %u64 - read a number and convert to uint64 
%       %f   - read a number and convert to double
%       %f32 - read a number and convert to single
%       %f64 - read a number and convert to double
%       %s   - read a string
%       %q   - read a (possibly double-quoted) string
%       %c   - read a character, including whitespace
%       %[...]  - reads characters matching characters between the
%                 brackets until first non-matching character or
%                 whitespace. Use %[]...] to include ] in the set.
%       %[^...] - reads characters not matching characters between the
%                 brackets until first matching character or whitespace.
%                 Use %[^]...] to exclude ] in the set.
%
%
%	If N is specified, FORMAT is reused N times.  If N is -1, or unspecified,
%   TEXTSCAN reads the entire file. 
%
%	Multiple PARAMETER and VALUE pairs may be used, in any order.  A VALUE
%	must immediately follow its PARAMETER.
%
%   Possible PARAMETER options are:
%        'bufSize'      - maximum string length in bytes (default is 4095)
%        'commentStyle' - one of:
%			- a single string.  Characters following the string until the
%			  end of a line or file, will be ignored.
%			- a cell array of two strings.  The first string indicates the 
%			  beginning of a comment, the second, the end, e.g.  {'/*','*/'} 
%			  for C-style comments.
%        'delimiter'    - delimiter characters (default is none)
%        'emptyValue'   - Value to use when an empty field is encountered 
%						  (default is NaN).
%        'endOfLine'    - end of line character (default determined from file).
%        'expChars'     - exponent characters (default is 'eEdD').
%        'headerLines'  - number of lines at beginning of file to skip.
%        'whitespace'   - whitespace characters (default is ' \b\t')
%        'returnOnError'- behavior on failing to read or convert (1=true or 0) 
%                         (default is 1).
%		 'treatAsEmpty'	- specify one or more strings to be treated in the
%						  same way as empty values.  Either a single
%						  string or a cell array of strings may be used.
%
%   EXAMPLES:
%   Suppose the text file 'mydata.dat' contains data in the following form:
%				Sally    Type1 12.34 45 1.23e10 inf NaN Yes
%				Joe      Type2 23.54 60 9e19 -inf 0.001 No
%				Bill     Type3 34.90 12 2e5 10 100 No
%          
%   Example 1:  Read each column into a variable
%       fid = fopen('mydata.dat');
%       C = textscan(fid,'%s%s%f32%d8%u%f%f%s');
%       fclose(fid);
%				C{1}=>	'Sally','Joe','Bill'
%				C{2}=>	'Type1','Type2','Type3'
%				C{3}=>	[12.34;23.54;34.9]		%class single
%				C{4}=>	[45;60;12]				%class int8
%				C{5}=>	[1.23e10;9e19;2e5]		%class uint32
%				C{6}=>	[Inf;-Inf;10]			%class double
%				C{7}=>	[NaN;0.001;100]			%class double 
%				C{8}=>	'Yes','No','No'
%
%   Example 2: Read the first column, skipping the rest of the line:
%       fid = fopen('mydata.dat');
%       names = textscan(fid,'%s%*[^\n]');
%       fclose(fid);
%
%   Example 3: Read the file as a fixed-format file, skipping the third field
%       fid = fopen('mydata.dat');
%       C = textscan(fid,'%9c%5s%*f%d8%u%f%f%s');
%       fclose(fid);
%				C{3}=>	[45;60;12]				%class int8
%
%   Example 4: Read the file and match 'Type' literal in second field
%       fid = fopen('mydata.dat');
%       C = textscan(fid,'%sType%f%f32%d8%u%f%f%s');
%       fclose(fid);
%				C{1}=>	'Sally','Joe','Bill'
%				C{2}=>	[1;2;3]  %'Type' in field two has been skipped. 
%
%   Example 5: Read the file using -Inf in empty cells:
%	Suppose data.csv contains:
%							1,2,3,4,,6
%							7,8,9,,11,12
%
%		fid = fopen('data.csv');
%       C = textscan(fid,'%f%f%f%f%u64%f','delimiter',',','emptyValue',-inf);
%		fclose(fid);
%				C{4}=>	[4;-Inf]	%class double
%				C{5}=>	[0;11]		%class uint64 (uint64(-Inf) == 0)
%         
%	Example 6: Read files with custom empty values and comments.  
%	Suppose data.csv contains:
%							abc,2,NA,3,4
%							//Comment here
%							def,na,5,6,7
%
%		fid = fopen('data.csv');
%		C = textscan(fid,'%s%n%n%n%n','delimiter',',',...
%				'treatAsEmpty',{'NA','na'},'commentStyle', '//')
%		fclose(fid);
%				C(1)=>	'abc','def'
%				C(2)=>	[2;NaN]
%				C(3)=>	[NaN;5]				
%
%   See also FOPEN, FREAD, FREWIND, FSEEK, FCLOSE, LOAD, SSCANF, IMPORTDATA.

%   Adapted by JP Barnard. Based on dataread.c by Clay M. Thompson 3-3-98
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $ $Date: 2004/04/16 22:07:06 $

%   Package: libmwbuiltins
%   Built-in function.

if nargout == 0
  builtin('textscan', varargin{:});
else
  [varargout{1:nargout}] = builtin('textscan', varargin{:});
end
