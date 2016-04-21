function ok=rpt_event_newmodel(z,varargin)
%RPT_EVENT_NEWMODEL
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

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:56:46 $

d=rgstoredata(z);      

d.SignalInfo=[];

rgstoredata(z,d);

ok=logical(1);
