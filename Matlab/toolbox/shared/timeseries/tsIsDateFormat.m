function outflag = tsIsDateFormat(thisstr)
%TSISDATEFORMAT Utility to detect if a string is a valid data format
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:34:12 $

strs = {'dd-mmm-yyyy HH:MM:SS';
'dd-mmm-yyyy';
'mm/dd/yy'; 
'mmm';     
'm';       
'mm';        
'mm/dd';       
'dd';        
'ddd';         
'd';       
'yyyy';        
'yy';          
'mmmyy';       
'HH:MM:SS';    
'HH:MM:SS PM';
'HH:MM';     
'HH:MM PM';
'QQ-YY';  
'QQ';         
'dd/mm';      
'dd/mm/yy';    
'mmm.dd,yyyy HH:MM:SS';
'mmm.dd,yyyy';
'mm/dd/yyyy';
'dd/mm/yyyy';
'yy/mm/dd';
'yyyy/mm/dd';
'QQ-YYYY';    
'mmmyyyy';      
'yyyy-mm-dd';
'yyyymmddTHHMMSS';
'yyyy-mm-dd HH:MM:SS'};

outflag = any(strcmp(thisstr,strs));