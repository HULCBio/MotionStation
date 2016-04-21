function casewrite(strmat,filename)
%CASEWRITE Writes casenames from a string matrix to a file.
%   CASEWRITE(STRMAT,FILENAME) writes a list of names to a file, one per line. 
%   FILENAME is the complete path to the desired file. If FILENAME does not
%   include directory information, the file will appear in the current directory.
%
%   CASEWRITE with just one input displays the File Open dialog box allowing
%   interactive naming of the file.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.1 $  $Date: 2003/11/01 04:25:22 $

if (nargin == 0)
   error('stats:casewrite:TooFewInputs',...
         'CASEWRITE requires at least one argument.');
end
if nargin == 1
   [F,P]=uiputfile('*');
   filename = [P,F];
end
fid = fopen(filename,'wt');

if fid == -1
   disp('Unable to open file.');
   return
end

if strcmp(computer,'MAC2')
   lf = setstr(13);
else
   lf = setstr(10);
end

lf = lf(ones(size(strmat,1),1),:);
lines  = [strmat lf]';

fprintf(fid,'%s',lines);
fclose(fid);
