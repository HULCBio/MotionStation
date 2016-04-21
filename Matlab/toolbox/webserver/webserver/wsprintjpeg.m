function status = wsprintjpeg(fig, jpegfilename)
%WSPRINTJPEG Screen or non-screen capture jpeg file creation.
%   STATUS = WSPRINTJPEG(FIG, JPEGFILENAME) creates a jpeg
%   file called JPEGFILENAME.  It first attempts to use
%   PRINT with the -DJPEG format.  If this fails it creates
%   a temporary pcx file and then converts it to a jpeg file.
%   Uses IMWRITE and IMREAD in this second case to avoid screen
%   capture.  Returns STATUS 0=success or <0=failures.
%
%   Note that the preferred method for creating jpeg files is
%   with the -DJPEG format.  This method is significantly faster
%   than printing a pcx file and converting it.
%
%   See also PRINT, IMWRITE, and IMREAD

%   Author(s): M. Greenstein 1998/06/03
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/25 18:49:34 $  

status = 0;

% Validate arguments.
if (nargin ~= 2), status = -1; return; end;
try 
   ftype = get(fig, 'Type');
catch
   status = -2;
   return;
end
if (~strcmp(ftype, 'figure')), status = -3; return; end
if (~ischar(jpegfilename)), status = -4; return; end

% Workaround to avoid bad toolbar/figure window interaction
% when visibility is off.
set(fig, 'toolbar', 'none');

% Create a jpeg file.
try 
   % Attempt to print using screen capture.
   print(fig, '-djpeg', '-r0', jpegfilename);
   return;
catch
   % Non-screen capture method.
	% Find the position of the last dot in the file name.
   dots = findstr(jpegfilename, '.');
   lastdot = length(dots);
   if (lastdot == 0), status = -5; return; end

   % Create a temporary pcx file, read, write as jpeg,
   % delete temporary pcx file.
   tempfile = [jpegfilename(1:dots(lastdot)) 'pcx'];
   print(fig, '-dpcx24b', tempfile);
   tempmatrix = imread(tempfile, 'pcx');
   imwrite(tempmatrix, jpegfilename, 'jpeg');
   delete(tempfile);
end

