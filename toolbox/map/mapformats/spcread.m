function mat = spcread(fname,cols)
%SPCREAD Read columns of data from an ascii text file.
%
%  MAT = SPCREAD reads two columns of data from an ascii text file into the
%  workspace.  The file name is supplied by a dialog box. This function
%  reads the file significantly faster than DLMREAD when a space delimiter
%  is supplied.
%
%  MAT = SPCREAD(FILENAME) reads the data from the file name specified.
%
%  MAT = SPCREAD(COLS) and mat = SPCREAD(FILENAME, COLS) assumes that the
%  ascii text file contains the number of columns specified by cols.
%
%  See also DLMREAD

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2003/08/01 18:23:58 $
%  Written by:  E. Byrns, E. Brown


%  Note:  This function operates 100x faster than DLMREAD when
%         a space is the delimiter.  I think that this is due
%         to all the parsing that DLMREAD does for non-space
%         delimited files.  Maybe DLMREAD with a space delimiter
%         should adopt this fscanf approach.  The speed test
%         was carried out using grnland.bnd


%  Argument checks and default settings.

if nargin == 0
	  cols = 2;      fname = [];

elseif nargin == 1
      if isstr(fname)
	  	  cols = 2;           path = [];
	  else
	      cols = fname;    fname = [];
	  end

elseif nargin == 2
      path = [];

end

%  Use file dialog box if no fname is supplied

if isempty(fname)
     [fname,path] = uigetfile('','Data File');
     if fname == 0;  return;   end         %  UIGETFILE was canceled
end

%  Open data file for read purposes.

[fid,message] = fopen([path,fname],'r');
if fid == -1;  error(message);  end

%  Construct the format string so that the number of %g equals
%  the number of columns in the data file.

formatstr = [' '; '%'; 'g'];
formatstr = formatstr(:,ones(1,cols));
formatstr = formatstr(:);   formatstr = formatstr';

%  Read the data file

mat = fscanf(fid,formatstr, [cols inf])';
fclose(fid);

