function qbhelp(hflag)
%QBHELP Visual Query Builder help string.
%   QBHELP(HFLAG) returns the Visual Query Builder help string in a help window.
%   HFLAG determines which section of the Visual Query Builder help 
%   string to display.   HFLAG can be WHERE, GROUP BY, HAVING, ORDER BY,
%   DISPLAY DATA, DISPLAY CHART, or ALL.

%   Author(s): C.F.Garvin, 05-14-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $   $Date: 2003/01/16 12:50:33 $

if nargin == 0
  hflag = 'ALL';
end

%Determine topic_id input
switch hflag
  
  case 'WHERE'
    topic_id = 'vqb_where';
    
  case 'GROUP BY'
    topic_id = 'vqb_groupby';
    
  case 'HAVING'
    topic_id = 'vqb_having';
    
  case 'ORDER BY'
    topic_id = 'vqb_orderby';
    
  case {'ALL','Visual Query Builder'}
    topic_id = 'dbtb_vqb';
    
	case 'TOOLBOX'
		topic_id = 'dbtb_gs';
		
  case 'DISPLAY CHART'
    topic_id = 'vqb_charting';
    
  case 'Subquery'
    topic_id = 'vqb_subquery';
    
  case 'Preferences'
    topic_id = 'vqb_prefs';
    
  case 'Configure DataSource'
    topic_id = 'db_confds';
   
	case 'AboutDialog'
		aboutstring = {'The Database Toolbox for use with MATLAB(r)';...
				           ' ';...
									 'Version 2.3';...
									 ' ';...
									 'Copyright 1984-2003 The Mathworks, Inc.'};
    msgbox(aboutstring,'About Database Toolbox')
		return
		
  otherwise
    topic_id = 'vqb_dialogbox';
   
end  
  
%Open help window
helpview([docroot '\mapfiles\database.map'],topic_id)
