function ok=rpt_event_newmodel(z,varargin)
%RPT_EVENT_NEWMODEL broadcasts a model change event
%    RPT_EVENT_NEWMODEL is called every time a model is looped on
%    from zslmethods/loopobject.  The loopobject method searches 
%    for all methods named RPT_EVENT_NEWMODEL, creates the parent
%    object, then runs the method with the syntax 
%
%    ok=rpt_event_newmodel(helper_object,mdlStruct)
%
%    where mdlStruct is a structure with fields
%       m.MdlName      name of current model
%       m.SysLoopType  rule for looping on "current" system
%       m.MdlCurrSys   list of "current" systems
%       m.isMask       look under masks rule
%       m.isLibrary    follow library links rule
%
%    ok is logical(1) if the method executed properly
%
%    See also ZSLMETHODS/LOOPOBJECT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:51 $

mdlStruct=varargin{1};

d=rgstoredata(z);      

d.Model=mdlStruct.MdlName;
d.System=[];
d.Block=[];
d.Signal=[];

d.MdlCurrSys=mdlStruct.MdlCurrSys;
d.SysLoopType=mdlStruct.SysLoopType;
d.isMask=mdlStruct.isMask;
d.isLibrary=mdlStruct.isLibrary;

d.ReportedSystemList=[];
d.ReportedBlockList=[];
d.ReportedSignalList=[];

d.WordAllList=[];
d.WordFunctionList=[];
d.WordVariableList=[];

%d.TlcContext=[]; 
d.SortedBlockList=[];

rgstoredata(z,d);

ok=logical(1);
