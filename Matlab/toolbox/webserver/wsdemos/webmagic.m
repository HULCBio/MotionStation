function retstr = webmagic(instruct, outfile)
%WEBMAGIC Magic squares into HTML table.
%   WEBMAGIC(INSTRUCT) Outputs a magic square of dimension
%   MSIZE by MSIZE.  MSIZE is the name of the HTML form field.
%   Output is returned in RETSTR.
%   WEBMAGIC(INSTRUCT, OUTFILE) Outputs a magic square of dimension
%   MSIZE by MSIZE.  MSIZE is the name of the HTML form field.
%   Output is returned in RETSTR. OUTFILE is a valid spec
%   for test output.
%
%   INSTRUCT is a structure created by the matweb program.
%   It contains fields corresponding to the HTML form fields
%   in the HTML form, webmagic1.html.  In webmagic1.html there
%   is a hidden field, called INSTRUCT.MLMFILE that references
%   this webmagic.m M-file.
%

%       Author(s): M. Greenstein, 11-10-97
%       Copyright 1998-2001 The MathWorks, Inc.
%       $Revision: 1.13 $   $Date: 2001/04/25 18:49:29 $

% Initialize the return string.
retstr = char('');

% Get the msize (string) variable. Convert to a number.  
% Check the range.
if(~length(instruct.msize))
   msize = 3; % Default empty field.
else
   msize = str2double(instruct.msize);
   if (msize > 20), msize = 20; end % Max size.
   if (msize < 3), msize = 3; end % Min square.
end

% Save size as a char string in structure OUTSTRUCT.  The
% function HTMLREP requires the first argument to be a structure
% containing the variables referenced in the output template
% file, webmagic2.html.
outstruct.msize = msize;

% Create magic square in output structure OUTSTRUCT.
outstruct.msquare = magic(msize);

% Get column, row, and diagonal sum.  Put in OUTSTRUCT.
d = sum(outstruct.msquare,1); 
outstruct.msum = d(1,1);

% Output the results and optionally write as a file if the
% filename was given as the second argument to WEBMAGIC.
templatefile = which('webmagic2.html');
if (nargin == 1)
   retstr = htmlrep(outstruct, templatefile);
elseif (nargin == 2)
   retstr = htmlrep(outstruct, templatefile, outfile);
end


