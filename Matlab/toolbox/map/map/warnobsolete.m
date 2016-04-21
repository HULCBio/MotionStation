function warnobsolete(filename)
%WARNOBSOLETE Issue a warning indicating the filename is obsolete.
%
%   WARNOBSOLETE(FILENAME) issues a warning that the FILENAME is obsolete
%   and may be removed in the future.
%
%   See also CONTENTS.
%
%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:20:40 $

wid = sprintf('%s:%s:obsoleteFunction',getcomp, filename);
str1= sprintf('%s is obsolete and may be removed in the future.',filename);
str2 = 'See product release notes for more information.';
warning(wid,'%s\n%s',str1,str2);
