function txt=mxdom2m(dom)
% MSDOM2M Converts an MScript DOM to a Codepad-formatted M file.
%   TXT = MSDOM2M(DOM) returns a char array of the new m-file. 

% Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $  $Date: 2002/09/26 01:52:04 $

txt=xslt(dom,which('mxdom2m.xsl'),'-tostring');
