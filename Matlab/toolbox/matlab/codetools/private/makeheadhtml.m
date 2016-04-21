function htmlOut = makeheadhtml
% MAKEHTMLHEAD  Add a head for a html file.
%   Charset iso-8859-1 is used to handle English and Western European
%   languages. Charset Shift-JIS and EUC-JP are used to handle Japanese on
%   PC(MAC) and UNIX, respectively.
%
%   Note: <html> and <head> tags have been opened but not closed. 
%   Be sure to close them in your HTML file.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/10/30 18:41:08 $ 

h1 = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
h2 = '<html xmlns="http://www.w3.org/1999/xhtml">';

% The character set depends on the language
lang=get(0,'language');
if strncmpi(lang, 'ja', 2)
    if strncmp(computer, 'PC', 2) || strncmp (computer, 'MAC', 3)
        h3 = '<head><meta http-equiv="Content-Type" content="text/html; charset=Shift-JIS" />';
    else 
        h3 = '<head><meta http-equiv="Content-Type" content="text/html; charset=EUC-JP" />';
    end
else
    h3 = '<head><meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />';
end

% Add cascading style sheet link
cssfile = which('styles.css');
h4 = sprintf('<link rel="stylesheet" href="file:///%s" type="text/css" />',cssfile);

htmlOut = [h1 h2 h3 h4];