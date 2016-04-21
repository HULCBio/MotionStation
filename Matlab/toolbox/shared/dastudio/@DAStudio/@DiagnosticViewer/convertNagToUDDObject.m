function msgObject = ConvertNagToUDDObject(h,nag)
%  CONVERTNAGTOUDDOBJECT
%  This function will convert an old style
%  nag to a UDD object
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
 msgObject = DAStudio.DiagnosticMsg;
 msgObject.type = nag.type;
 nag.sourceFullName(nag.sourceFullName==10) = [];
 msgObject.SourceFullName = nag.sourceFullName;
 nag.sourceName(nag.sourceName==10) = [];
 msgObject.SourceName = nag.sourceName;
 nag.component(nag.component==10) = [];
 msgObject.Component = nag.component;
 for i = 1:length(nag.objHandles)
   objHandle = nag.objHandles(i);
   msgObject.AssocObjectHandles = [msgObject.AssocObjectHandles, objHandle];
   name = get_param(objHandle,'Name');
   msgObject.AssocObjectNames = [msgObject.AssocObjectNames; {name}];
 end
 if (~isempty(nag.sourceHId))
     objHandle = nag.sourceHId;
     msgObject.SourceObject = [msgObject.SourceObject, objHandle];
 end
 % copy the open function if there is one
 if (~isempty(nag.openFcn))
    msgObject.OpenFcn = nag.openFcn; 
 end
 c = DAStudio.DiagnosticMsgContents;
 message = nag.msg;
 message.type(message.type==10) = [];
 %message.details(message.details==10) = [];
 message.summary(message.summary==10) = [];
 c.Type = message.type;
 c.Details = message.details;
 c.Summary = message.summary;
 msgObject.HyperRefDir = nag.refDir;
 msgObject.Contents = c;


%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:26 $
