function aboutdspblks
%ABOUTDSPBLKS Displays version number of the Signal Processing Blockset  
%             and the copyright notice in a modal dialog box.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2003/12/06 15:22:24 $
 
a=ver('dspblks');
str1=a.Name;
str2=a.Version;
tmp=a.Date;b=tmp(end-3:end);
str3=['Copyright 1995-',b,' The MathWorks, Inc.'];
str = sprintf([str1,' ',str2,'\n',str3]);
msgbox(str,'About the Signal Processing Blockset','modal');

% [EOF] aboutdspblks.m
