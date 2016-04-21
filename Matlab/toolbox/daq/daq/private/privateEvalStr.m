function ListString = privateEvalStr(ListString)
%PRIVATEEVALSTR Convert EVALC string to a usable ListBox string.
%
%    STR1 = PRIVATEEVALSTR(STR) converts the output from evalc, STR, into 
%    a string, STR1, that can be used for the String property of a ListBox 
%    uicontrol.
%
%    This is a helper function for the DAQSCHOOL demos.
%
%    Example:
%       str = evalc('ai = analoginput(''winsound'')');
%       str = privateevalstr(str);
%

%    MP 01-05-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:42:17 $


% Replace single quotes with double single quotes.
ListString=strrep(ListString,'''',''''''); 

% Find the last carriage return.
LastLoc=max(find(ListString~=abs(sprintf('\n')))); 

% Replace the carriage returns with ','
ListString=[ 'char('''...
      strrep(ListString(1:LastLoc),sprintf('\n'),''',''') ''')' ];

% Evaluate expression and output.
ListString=eval(ListString);


