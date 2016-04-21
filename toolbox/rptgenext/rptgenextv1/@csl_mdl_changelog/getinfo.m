function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_MDL_CHANGELOG)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:58 $

out=getprotocomp(c);

out.Name = xlate('Model Change Log');
out.Type = 'SL';
out.Desc = xlate('Shows the revision history of a Simulink model');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isAuthor=logical(0);
out.att.isVersion=logical(0);
out.att.isDate=logical(1);
out.att.isComment=logical(1);

%out.att.DateFormat = 1;

out.att.isLimitRevisions=logical(0);
out.att.numRevisions=12;

out.att.TableTitle='Model History';
out.att.isBorder=logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isLimitRevisions.String='Limit displayed revisions to: ';

out.attx.isAuthor.String='Author name';
out.attx.isVersion.String='Version';
out.attx.isDate.String='Date changed - Format: ';
out.attx.isComment.String='Description of change';

out.attx.numRevisions.String='';
out.attx.numRevisions.NumberRange=[0 100];

out.attx.TableTitle.String = 'Table title: ';
out.attx.isBorder.String='Display table border';

%dateVals={
%   'dd-mmm-yyyy HH:MM:SS'
%   'dd-mmm-yyyy'
%   'mm/dd/yy'  
%   'mmm'      
%   'm'             
%   'mm'              
%   'mm/dd'
%   'dd'         
%   'ddd'           
%   'd'               
%   'yyyy'      
%   'yy'             
%   'mmmyy'       
%   'HH:MM:SS'
%   'HH:MM:SS PM'
%   'HH:MM'       
%   'HH:MM PM'    
%   'QQ-YY'  
%   'QQ' 
%};

%currDate=now;
%for i=length(dateVals):-1:1
%   dateDisplay{i,1}=datestr(currDate,dateVals{i});
%end

%out.attx.DateFormat = struct(...
%  'String'   ,'',...
%  'Type'     ,'ENUM',...
%  'enumValues',{dateVals}, ...
%  'enumNames',{dateDisplay}, ...
%  'UIcontrol','popupmenu');
