function out=tableref(c,action,varargin)
%TABLEREF interface for generic property table
%   OUT=TABLEREF(CHGFIGPROPTABLE,'ACTION')
%   Valid 'ACTION' strings:
%   GetPropList(filter) - called whenever the filter changes. 
%      Gives a list of properties for the filter.
%   GetFilterList - called on startup.  Gets a list of all 
%      valid filters
%   GetFormatList - called on startup.  Gets a list of valid
%      rendering options for the "display property as" popup
%   GetPropCell(cell,property) - called during execution.  Gives
%      the unparsed cell structure as well as the parsed property
%      name.
%   GetPresetList-get a list of all preset tables for the "apply
%      preset table" popup menu.
%   GetPresetTable(tablename) - returns a new attributes array
%      for the table.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:16 $

switch action
case {'GetPresetList' 'GetPresetTable'}
   out=feval(action,varargin{:});
otherwise
   out=tableref(rptproptable,c.zhgmethods,'Figure',action,varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=GetPresetList

list={'Default'
   'Callbacks'
   'Graphics'
   'Printing'
   'Blank 4x4'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=GetPresetTable(tablename)

defaultRender='P v';
switch tablename
case 'Default'
   title=xlate('Figure Properties');
   colWid=[1 4];
   pnames={'%<Name>'
      '%<FileName>'   
      '%<Tag>'
      '%<Children>'};
   singleVal=logical(1);
case 'Printing'
   title='Print Properties';
   colWid=[1 1.5];
   singleVal=logical(0);   
   pnames={'%<PaperPositionMode>' 'PaperPosition: %<PaperPosition> %<PaperUnits>' 
      '%<PaperType>' 'PaperSize: %<PaperSize> %<PaperUnits>'
      '%<PaperOrientation>' '%<InvertHardcopy>'};
   defaultRender='p:v';
case 'Callbacks'
   title='Callback and Function Properties';
   colWid=[1 2.5];
   singleVal=logical(1);
   pnames={'%<BusyAction>'
      '%<Interruptible>'      
      '%<CreateFcn>'
      '%<CloseRequestFcn>' 
      '%<DeleteFcn>'
      '%<KeyPressFcn>'
      '%<ButtonDownFcn>'
      '%<WindowButtonDownFcn>'
      '%<WindowButtonMotionFcn>'
      '%<WindowButtonUpFcn>'
      '%<Resize>'
      '%<ResizeFcn>'};
case 'Graphics'
   title='Graphics Properties';
   colWid=[1 1 1 1];
   singleVal=logical(1);
   pnames={'%<BackingStore>' '%<DoubleBuffer>'        
      '%<RendererMode>' '%<Renderer>'
      '%<MinColormap>' '%<ShareColors>' 
      '%<Visible>' '%<Clipping>'};   
otherwise %blank 4x4
   title='Title';
   colWid=[1 1 1 1];
   singleVal=logical(0);
   [pnames{1:4,1:4}]=deal('');
end

if singleVal
   defaultAlign='c';
else
   defaultAlign='l';
end

content=struct('align',defaultAlign,...
   'text',pnames,...
   'border',3,...
   'render',defaultRender);

out=struct('TableTitle',title,...
   'SingleValueMode',singleVal,...
   'ColWidths',colWid,...
   'TableContent',content);

if strcmp(tablename,'Printing')
   out.TableContent(1,2).render='v';
   out.TableContent(2,2).render='v';
end




