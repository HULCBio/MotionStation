function varargout = dcwrhead(filepath,filename,fid)
%DCWRHEAD Read the Digital Chart of the World file headers.
%
%  DCWRHEAD(FILEPATH,FILENAME) reads from the specified file.  The
%  combination [FILEPATH FILENAME] must form a valid complete filename.
%  DCWRHEAD allows the user to select the file interactively.
%
%  DCWRHEAD(FILEPATH,FILENAME,FID) reads from the already open file
%  associated with fid.
%
%  DCWRHEAD(...),  with no output arguments, displays the formatted header
%  information on the screen.
%
%  STR = DCWRHEAD...  returns a string containing the DCW header

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:20:52 $

if nargin == 0;   % allow user to select file interactively

   [filename, filepath] = uigetfile('*', 'select a DCW file');
	if filename == 0 ; return; end
	fid = fopen([filepath,filename],'rb', 'ieee-le');

elseif nargin == 2   % user specifed filename, file not open

    ind = findstr(filename,'.');
    if isempty(ind) & isunix ; filename = [filename '.']; end


	fid = fopen([filepath,filename],'rb', 'ieee-le');

	if fid == -1
		[filename,pathname] = uigetfile(filename,['Where is ',filename,'?']);
		if filename == 0 ; return; end
		fid = fopen([pathname,filename],'rb', 'ieee-le');
	end

elseif nargin==3    % file already open
	if fid == -1 
      eid = sprintf('%s:%s:fileNotOpen', getcomp, mfilename);
      error(eid,'%s','File not open?');
   end
else
	eid = sprintf('%s:%s:incorrectInputs', getcomp, mfilename);
   error(eid,'%s','Incorrect number of input arguments');

end

%
% read the header, check for validity in calling function
%

headerlength = fread(fid, 1, 'long');
headerstring = fread(fid, headerlength, 'char');
headerstring = setstr(headerstring');

if nargout == 0;
	linebreakchar = sprintf('\n');
	printstring = strrep( strrep(headerstring,'\:','  ') ,':',linebreakchar);
	disp(strrep(printstring,';',linebreakchar))
elseif nargout ==1
	varargout(1) = {headerstring};
else
	wid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
   warning(wid,'%s','Incorrect number of output arguments')
end

if nargin ~=3;fclose(fid);end

