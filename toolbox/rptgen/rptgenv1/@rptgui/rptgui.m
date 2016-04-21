function out=rptgui(input)
%RPTGUI This is the constructor for the @rptgui class
%   G=RPTGUI(G) where G is a RPTGUI object saves the GUI
%             object in persistent memory
%   G=RPTGUI(S) where S is an RPTSETUPFILE or RPTSP object
%             will create an RPTGUI object if none exists
%             or will append S to the object's list of
%             setup files if the object does exist.
%   G=RPTGUI    will create an RPTGUI object if none exists.
%
%   RPTGUI will always return an RPTGUI object.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:01 $

%persistent KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE
%mlock

emptyFlag=logical(1);
KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=[];


if nargin>0
   if isa(input,'rptgui') | isempty(input)
      KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=input;
   elseif isa(input,'rptsp') | isa(input,'rptsetupfile')
      if emptyFlag
         KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=...
            LocCreateObject(rptsp(input));
      else
         KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=...
            LocAmmendObject(...
            KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE,...
            rptsp(input));
      end
   else
      KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=...
         LocCreateObject(rptsetupfile);
   end
elseif emptyFlag
   KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=...
         LocCreateObject(rptsetupfile);
end

out=KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocCreateObject(s);

%HG defaults
out.hg.all=struct('Units','points',...
   'HandleVisibility','off');


%Report Setup File
out.s=LocPrep(s);

out.c=rptcp;

%Handles
out.h=struct('fig',[],...
   'title',[]);


%Reference
out.ref=struct('OpenSetfiles',double(s),...
   'allcomps',[],... %a structure with all possible component names
   'ComponentPointer',[],...
   'grud','rgstoregui',...
   'Pointer','',...
   'ObjectBrowserHandle',[]);
   
%out.ref.PointerShapeCData=[];
%out.ref.PointerShapeHotSpot=[];

%Layout Info;

r=rptparent;
bH=layoutbarht(r);

ppx=pointsperpixel(r);

BS=25*4/3*ppx;
PD=bH/3;

out.layout=struct('statbarht',bH,...
   'tabht',bH*4/3,...
   'padding',PD,...
   'btnside',BS,...
   'outlinewidth',300,...
   'tabbodywidth',700,...
   'tabbodyht',0,...
   'minTabBodyWidth',8*bH,...
   'minOutlineWidth',8*bH*3/7,...
   'minTabBodyHt',7*BS+4*PD,...
   'figWidth',0,...
   'figHeight',0);


out = class(out,'rptgui',r);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g=LocAmmendObject(g,s);

g.s=LocPrep(s);
g.ref.OpenSetfiles(end+1)=double(s);
g.h.Main.outline=outlinehandle(s,g.hg.all);
g.c=rptcp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=LocPrep(s);

%we start with the dirty flag engaged
s.ref.changed=logical(0);
