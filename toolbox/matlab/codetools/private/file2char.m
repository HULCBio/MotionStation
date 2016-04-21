function c = file2char(filename)

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.3 $  $Date: 2004/04/22 01:35:49 $

f = fopen(filename);
if strncmpi(get(0,'Language'),'ja',2)
   % Assume the file is encoded in Shift_JIS.  Use Java to convert it.
   c = toCharArray(java.lang.String(fread(f),'Shift_JIS'))';
else
   c = fread(f,'char=>char')';
end
fclose(f);
