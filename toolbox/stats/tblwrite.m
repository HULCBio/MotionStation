function tblwrite(data,varnames,casenames,filename,delimiter)
%TBLWRITE Writes data in tabular form to the file system.
%   TBLWRITE(DATA, VARNAMES, CASENAMES, FILENAME,DELIMITER) writes
%   a space delimited file with variable names in the first row,
%   case names in the first column and data in columns under each
%   variable name. FILENAME is the complete path to the desired file.
%   VARNAMES is a character array or cell array of strings containing the
%   variable names.  CASENAMES is a character array or cell array of
%   strings containing the names of each observation.  DATA is a numeric
%   matrix with a value for each variable-observation pair.
%
%   DELIMITER can be any of the following: ' ', '\t', ',', ';', '|' or their
%   corresponding string names 'space', 'tab', 'comma', 'semi', 'bar'. If
%   it is not given, the default is to place multiple spaces between columns.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.17.4.2 $  $Date: 2004/01/24 09:36:59 $

if nargin < 5
   delimiter = '   ';
else
   switch delimiter
   case {'tab', '\t'}
      delimiter = sprintf('\t');
   case 'space'
      delimiter = ' ';
   case 'comma'
      delimiter = ',';
   case 'semi'
      delimiter = ';';
   case 'bar'
      delimiter = '|';
   otherwise
      delimiter = delimiter(1);   
   end
end

ld = length(delimiter);
if nargin<3, casenames = ''; end
if iscell(casenames) && ~isempty(casenames)
   lc = max(cellfun('length',casenames));
   ncasenames = numel(casenames);
elseif ~isempty(casenames)
   [ncasenames, lc] = size(casenames);
end

if nargin < 4 || isempty(filename)
   [F,P]=uiputfile('*');
   filename = [P,F];
end


% Make sure input arguments conform
[nobs, nvars] = size(data);

if ~ischar(casenames) && ~isempty(casenames) && ~iscellstr(casenames)
   error('stats:tblwrite:CharacterRequired',...
         'CASENAMES must be a character array or cell array of strings.');
end
if ~ischar(varnames) && ~isempty(varnames) && ~iscellstr(varnames)
   error('stats:tblwrite:CharacterRequired',...
         'VARNAMES must be a character array or cell array of strings.');
end

if ~isempty(casenames) && ncasenames~=nobs
   error('stats:tblwrite:InputSizeMismatch',...
         'Number of case names must equal number of data rows.');
end

if iscell(varnames)
   nvarnames = numel(varnames);
else
   nvarnames = size(varnames,1);
end

if nvars ~= nvarnames
   error('stats:tblwrite:InputSizeMismatch',...
         'Number of variable names must equal number of data columns.');
end

% Get ready to display default case names if none supplied
nocasenames = isempty(casenames);
if nocasenames
   digits = floor(log10(nobs))+1;
   caseformat = ['%',int2str(digits),'d'];
   lc = digits;
end

% Write the line of variable names
if iscell(varnames)
   varnames = char(varnames);
end
maxl = size(varnames,2);
for i = 1:nvarnames
   j = maxl;
   while (varnames(i,j) == ' ')
      j = j-1;
      if j == 0, break, end
   end
   if (j > 0)
      a = findstr(varnames(i,1:j), ' ');
      varnames(i,a) = '_';
   end
end
      
lv = maxl;

marker1 = delimiter(ones(nvars,1),:);

varnames = [marker1 varnames]';
varnames = varnames(:)';
marker1 = char(32);
marker1 = marker1(ones(1,lc));
varnames = [marker1 varnames];

% Create the correct line separator for this computer
lf = sprintf('\n');
varnames = [varnames(:)' lf];

% Write lines with case names and data
blankline = [repmat(' ',1,lc), delimiter];
for rows = 1:nobs
   if nocasenames
      cn = sprintf(caseformat,rows);
   else
      if iscell(casenames)
         cn = casenames{rows};
      else
         cn = casenames(rows,:);
      end
      cn = deblank(cn);
      cn(cn==' ') = '_';
   end
   sr = blankline;
   sr(1:length(cn)) = cn;

   for cols = 1:nvars
      s = num2str(data(rows,cols));
      sr = [sr s];
      if cols ~= nvars
         ps = max(1,lc+cols*(ld+lv)+ld-length(sr));
         if isequal(delimiter,'   ')
            sr = [sr delimiter(ones(1,ps))];
         else
            sr = [sr delimiter];
         end
      end
   end
   if rows == 1
      maxl = length(sr);
      l = length(sr);
      lines = sr;
   else
      blank = ' ';
      l = length(sr);
       deltal = l - maxl;
      if deltal > 0
           lines = [lines blank(ones(rows-1,1),ones(deltal,1))];
        maxl = l;
      elseif deltal < 0
         sr = [sr blank(1,ones(-deltal,1))];
      end
      lines = [lines;sr];
   end
end
lines = [lines lf(ones(nobs,1),1)];
  
fid = fopen(filename,'wt');

if fid == -1
   disp('Unable to open file.');
   return
end

fprintf(fid,'%s',varnames);
fprintf(fid,'%s',lines');
fclose(fid);
