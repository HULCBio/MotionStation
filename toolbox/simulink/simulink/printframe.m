function val = printframe(action, varargin)
%PRINTFRAME Verify and fill frame files for Simulink Printing.
%   Simulink helper function for printing models with Print
%   Frames.  See the FRAMEEDIT documentation for information
%   on creating and using Print Frames.
%
%   See also FRAMEEDIT

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.24 $
%   j. H. Roh

persistent param;

switch lower(action)
   
% printframeH = printframe('create', filename, nPagesToPrint [, baseSysOrFig]);
case 'create'
   val = 0;
   try
      error(nargchk(3,4,nargin));
      
      filename = varargin{1};
      nPagesToPrint = varargin{2};
      if nargin==4
         baseSys = varargin{3};
         if ischar(baseSys)
            baseSys = get_param(baseSys,'handle');
         end
      else
         baseSys = [];
      end
      
      printframeH = 0;
      try
         printframeH = hgload(filename);
         if LValidityCheck(printframeH)
            error('Invalid Figure file');
         else
            set(printframeH,...
                    'Toolbar','none',...
                    'Menubar','none',...
                    'Renderer','painters');
            axHandles=findall(allchild(printframeH),'flat','type','axes');
            set(axHandles,...
                    'Xtick',[],...
                    'Ytick',[],...
                    'Ztick',[],...
                    'XtickLabel',[],...
                    'YtickLabel',[],...
                    'ZtickLabel',[]);
         end
      catch
         if ~isempty(printframeH) & printframeH & ishandle(printframeH)
            delete(printframeH);
         end
         error('Invalid Figure file');
      end
   
      param = [];  % instead of clear param, so it remains persistent

      % get paper settings from the printframe
      UD = findall(printframeH,'Tag','PrintFramePaperSettings');
      template = get(UD,'UserData');
      % these lists are hardcoded in frameedit.m, both the order
      % and the elements must stay in sync.
      % template.propList = ...
      %   {'PaperType' 'PaperOrientation' 'PaperUnits' ...
      %    'PaperPosition' 'PaperPositionMode'}
      % template.valueList = {'usletter' 'landscape' ...}
      % template.modelDataPosition = [L B W H] 
      %    in data (print area normal) units
      % template.margins = [L B R T]
      % template.marginUnits = ...
      
      % get global paper settings
      if ~isempty(baseSys)
         % get paper settings from the base system (or figure)
         % so that users can choose paper type and orientation

         propList = {...
                 'PaperType', ...
                 'PaperOrientation'};
         % ignore PaperPosition settings: these will be
         % determined (in normal units) by the printframe
         
         if LIsSystem(baseSys)
            paperSettings = Lget_param(baseSys,propList);
         else
            paperSettings = get(baseSys,propList);
         end

         % Don't warn if the paper orientation is different 
         
         % if strcmp(paperSettings,template.valueList(1:2))
         %    % paper settings are what we expect
         % else
         %    % the user has specified a paper type or
         %    % orientation different from the print frame
         %    CR = sprintf('\n');
         %    warningStr = ...
         %       ['The specified print frame file was originally formatted ' CR ...
         %        'for printing on ' template.valueList{1} ' paper in ' ...
         %        template.valueList{2} ' mode.' CR CR ...
         %        'Reformatting for ' paperSettings{1} ' paper in ' ...
         %        paperSettings{2} ' mode.' CR];
         %    warning(warningStr);
         % end
            
         % save normal units position before making a change
         oldPosition = get(printframeH, 'PaperPosition');
            
         % match printframe to base system settings (size & orientation)
         set(printframeH, propList, paperSettings);

         % reset margins to fixed values if possible
         L = template.margins(1);
         B = template.margins(2);
         R = template.margins(3);
         T = template.margins(4);
            
         set(printframeH,'PaperUnits',template.marginUnits);
         newPaperSize = get(printframeH,'PaperSize');
         newPaperPosition = ...
                 [L  B  newPaperSize(1)-L-R newPaperSize(2)-T-B];
         try
            set(printframeH,'PaperPosition',newPaperPosition);
         catch
            warning(...
                    ['Could not reset margins to original values.', CR...
                       'Resizing margins in normalized mode...']);
            set(printframeH,...
                    'PaperUnits','normal',...
                    'PaperPosition',oldPosition);
         end
         
         template.valueList(1:2) = paperSettings(1:2);
      end

      
      % set model paperposition based on new margin settings
      % dPoint = point in data (print area normal) units
      % pPoint = point in paper normal units
      dML = template.modelDataPosition(1);
      dMW = template.modelDataPosition(3);
      dMB = template.modelDataPosition(2);
      dMH = template.modelDataPosition(4);

      set(printframeH,'PaperUnits','inches');
      % paper position of print area in inches
      pPosition = get(printframeH,'PaperPosition');
      pL = pPosition(1);
      pW = pPosition(3);
      pB = pPosition(2);
      pH = pPosition(4);

      % scale and offset model print area.
      pML = pL + dML*pW;
      pMW = dMW*pW;
      
      pMB = pB + dMB*pH;
      pMH = dMH*pH;
           
      modelPaperPos = [pML pMB pMW pMH];             % model position in inches
      % inset by 1/4 inch on all sides
      insetModelPaperPos = modelPaperPos + [0.25 0.25 -0.5 -0.5];
      % verify that we have a valid PaperPosition
      if insetModelPaperPos(3:4)>.5  % both height and width greater than 1/2 inch
         template.valueList{4} = insetModelPaperPos; % PaperPosition         
      else % it's too small, so don't add any cell padding
         template.valueList{4} = modelPaperPos;
      end
      template.valueList{3} = 'inches';              % PaperUnits
      template.valueList{5} = 'manual';              % PaperPositionMode;
      
      param.template = template;

      % initialize temporarage storage for saving system/figure parameters
      param.pageFigV = [];
      param.pageSysV = [];

      % print job settings
      param.nPagesToPrint = nPagesToPrint;
      param.now = now;

      % temporary storage
      param.visTextObjV = [];
      param.textObjV = findall(printframeH,'Type','text');
      set(param.textObjV,'Visible','off');
      if ~isempty(param.textObjV)
         param.axes = get(param.textObjV(1),'Parent');
      else
         param.axes = [];
      end
      
      % return figure handle
      val = printframeH;
   catch
      clear param;
      val = 0; % error flag
   end
   
% err = printframe('newpage', [fig1 sys1 fig2 ... printframeH], iPage);
case 'newpage'
   val = 1;
   handleV = varargin{1};
   printframeH = handleV(end);

   iPage = varargin{2};
   if iPage > 0 & iPage <= param.nPagesToPrint
      val = 0;
   else
      % page out of range
      err = logical(1);
      return
   end
   
   % save settings for new page
   saveProperties = param.template.propList;
   

   pageV = handleV(1:end-1);
   % separate figures from systems
   param.pageSysV = pageV(find(LIsSystem(pageV)));
   param.pageFigV = pageV(find(~LIsSystem(pageV)));
   
   % every system and figure has paper properties

   param.pageFigValues = get(param.pageFigV, ...
           saveProperties);
   param.pageSysValues = Lget_param(param.pageSysV, ...
           saveProperties);
   
   % unlock and open each subsystem, so we get the correct
   % auto paperposition below
   [param.pageSysExtras, param.pageRootExtras] = Lsafe_open(param.pageSysV);
   
   % set temporary values for printing
   try
      printValues = param.template.valueList;
      frameModelPos = printValues{4};

      centerX = frameModelPos(1)+frameModelPos(3)/2;
      centerY = frameModelPos(2)+frameModelPos(4)/2;
      for a = param.pageSysV
         % get the auto paper position for each subsystem
         set_param(a, ...
                 'PaperType',printValues{1},...
                 'PaperOrientation',printValues{2},...
                 'PaperUnits','inches',...         
                 'PaperPositionMode','auto');
         
         autoPos = get_param(a,'PaperPosition');
         if autoPos(3:4)<frameModelPos(3:4);  % it fits
            % then simply center it...
            frameModelPos(3:4) = autoPos(3:4);
            frameModelPos(1:2) = ...
                    [centerX-autoPos(3)/2 centerY-autoPos(4)/2];
            printValues{4} = frameModelPos;
         else % it is too big so scale it down...
            % no change in printValues required...
            % Let Simulink take care of preserving aspect ratio...
         end
         Lset_param(a, saveProperties, printValues);
      end

      printValues = param.template.valueList;
      frameModelPos = printValues{4};

      for a = param.pageFigV
         % let stateflow adjust for the new window size ( reduced by printframe )
			sfprint( {a, 'inches', frameModelPos}, 'printframe_adjust'  );     % 
		   set(a, ...
                 'PaperType',printValues{1},...
                 'PaperOrientation',printValues{2},...
                 'PaperUnits','inches' ...
				);

         %ax = findobj(a,'type','axes','Tag','TARGET_AXES');
         %autoPos = get( ax, 'Position' );

         %frameModelPos(3:4) = autoPos(3:4);
         %frameModelPos(1:2) = ...
         %        [centerX-autoPos(3)/2 centerY-autoPos(4)/2];
         printValues{4} = frameModelPos;
         
         %set(a, saveProperties, printValues);
      end

      param = LSubVariables(printframeH, handleV(1:end-1), iPage, param);
   catch
      warning(['Unable to set frame correctly for page ' ...
                 num2str(iPage) '.']);
      % error substituting values
      err = logical(1);
      
      % restore paper settings for aborted page.
      set(param.pageFigV, ...
              saveProperties, param.pageFigValues);
      Lset_param(param.pageSysV, ...
              saveProperties, param.pageSysValues);
      
      Lsafe_restore(param.pageSysV, param.pageSysExtras, param.pageRootExtras);
   end
   
% err = printframe('finishpage', printframeH);
case 'finishpage'
   val = 1;
   printframeH = varargin{1};
   saveProperties = param.template.propList;
   if ishandle(printframeH)
      % restore values for the last page
      if ~isempty(param.pageFigV)
         set(param.pageFigV,saveProperties, param.pageFigValues);
      end
      if ~isempty(param.pageSysV)
         Lset_param(param.pageSysV,saveProperties, param.pageSysValues);
         Lsafe_restore(param.pageSysV, param.pageSysExtras, param.pageRootExtras);
      end
      val = 0;
   end
   
   delete(param.visTextObjV);
   param.visTextObjV = [];
   param.pageFigV = [];
   param.pageSysV = [];
   param.pageFigValues = [];
   param.pageSysValues = [];
   param.pageSysExtras = [];

   
% printframe('edit', filename)
case 'edit'
   switch nargin
   case 1
      frameedit;
   case 2
      frameedit(varargin{:});
   end
   
% printframe('close', printframeH)
case 'close'
   printframeH = varargin{1};
   err = close(printframeH);
   val = ~err;
   
   clear param;
   
otherwise
   % urecognized action
end



function param = LSubVariables(printframeH, handleV, iPage, param);

searchPatterns = {...
   'blockdiagram', 'char(32)',
   'page', 'num2str(iPage)',
   'date', 'datestr(param.now,1)',
   'time', 'datestr(param.now,15)',
   'npages', 'num2str(param.nPagesToPrint)'};

simSearchPatterns = {...
   'system', 'LGetSystemName(handleV)',
   'fullsystem', 'LGetSystemFullName(handleV)',   
   'filename', 'LGetSystemFileName(handleV)',
   'fullfilename', 'LGetSystemPathName(handleV)'   };

sfSearchPatterns = {...
   'system', 'LGetSFName(handleV)',
   'fullsystem', 'LGetSFFullName(handleV)',
   'filename', 'LGetSFFileName(handleV)',   
   'fullfilename', 'LGetSFPathName(handleV)'   };


if isempty(param.textObjV)
   return
end

delete(param.visTextObjV);

param.visTextObjV = copyobj(param.textObjV, param.axes);
visTextObjV = param.visTextObjV;
set(visTextObjV,'Visible','on');

% for now: work with only the first item
handleV = handleV(1);

textV = get(visTextObjV,'String');
if isempty(textV)
   return
end

try
   for i = 1:length(searchPatterns)
      a = searchPatterns{i,1};
      b = searchPatterns{i,2};
      textV = Lstrrep(textV,['%<' a '>'], eval(b));
   end
   if LIsSystem(handleV)
      for i = 1:length(simSearchPatterns)
         a = simSearchPatterns{i,1};
         b = eval(simSearchPatterns{i,2});
         textV = Lstrrep(textV, ['%<' a '>'], b);
      end
   else % it is a stateflow chart
      for i = 1:length(sfSearchPatterns)
         a = sfSearchPatterns{i,1};
         b = eval(sfSearchPatterns{i,2});
         textV = Lstrrep(textV, ['%<' a '>'], b);
      end
   end
catch
   warning('problems setting values for some variable fields.');
end
set(visTextObjV,{'String'}, textV);
% set turns strings with newlines into string matrices!


function val = Lfindstr(s1,s2)
% s1 can be a string matrix or a cell array of strings
s1 = cellstr(s1);
s1 = cat(2, s1{:});
val = findstr(s1, s2);

   
function chartId = LGetSFChartId( handleV )
portal = get(handleV,'UserData');
chartId = sf('get', portal, '.chart');


function str = LGetSystemName(handleV)
str = LSlashEscape(get_param(handleV,'Name'));
% replace carriage returns with space
str = strrep(str,char(10),' ');
   
function str = LGetSFName(handleV),
portal = get(handleV, 'userdata');
obj = sf('get', portal, '.viewObject');
str = sf('get', obj, '.name');
str = LSlashEscape(str);
str = strrep(str,char(10),' ');


function str = LGetSystemFullName(handleV)
% for now, only need to operate on one at a time
str = LSlashEscape(getfullname(handleV));
str = strrep(str,char(10),' ');

function str = LGetSFFullName(handleV)
portal = get(handleV, 'userdata');
obj    = sf('get', portal, '.viewObject');
str = LSlashEscape(sf('FullNameOf',obj,'/'));
str = strrep(str,char(10),' ');

function str = LGetSystemFileName(handleV)
myroot = bdroot(handleV);
str = get_param(myroot,'FileName');
if isempty(str)
   str = 'untitled';
else
   str = [LSlashEscape(get_param(myroot,'Name')) '.mdl'];
end

function str = LGetSFFileName(handleV)
model = LGetChartModel(handleV);
str = LGetSystemFileName(model);

function str = LGetSFPathName(handleV)
model = LGetChartModel(handleV);
str = LGetSystemPathName(model);

function model = LGetChartModel(handleV)
for i=1:length(handleV)
   chart = LGetSFChartId( handleV );
   machine = sf('get',chart,'chart.machine');
   model(i) = sf('get',machine,'machine.simulinkModel');
end

function str = LGetSystemPathName(handleV)
myroot = bdroot(handleV);
str = LSlashEscape(get_param(myroot,'FileName'));
if isempty(str)
   str = 'untitled';
end



function val = LIsSystem(handleV)
val = zeros(1,length(handleV));
for i = 1:length(handleV)
   try
      get_param(handleV(i),'Name');
      val(i) = logical(1);
   catch
      val(i) = logical(0);
   end
end


function str = LSlashEscape(str)
str = strrep(str,'\','\\');
str = strrep(str,'_','\_');
str = strrep(str,'^','\^');
str = strrep(str,'{','\{');
str = strrep(str,'}','\}');



function s = Lstrrep(s1,s2,s3)
% unlike strrep, s1 can be a cell array containing
% strings, character matrices, or cell arrays of strings

if isempty(s1)
   s = s1;   
elseif ischar(s1) & size(s1,1)==1         % simple string
   s = strrep(s1,s2,s3);
elseif ischar(s1) & size(s1,1)>1      % string matrix
   s = strrep(cellstr(s1),s2,s3);   
elseif iscell(s1)                     % cell array
   s = cell(size(s1));
   for i=1:length(s1)
      s{i} = Lstrrep(s1{i},s2,s3);
   end
else
   s = s1;
end
   



function err = LValidityCheck(hndl)
err = ~ishandle(hndl);
if ~err
   err = ~strcmp('PrintFrameFigure',get(hndl,'Tag'));
end


function val = Lget_param(sysV, propList)
% sysV:      is a 1 by M row vector of system handles
% propList:  is a 1 by N cell array row vector of strings
%
% val:       is an M by N cell array of parameter values a la get
M = length(sysV);
N = length(propList);
val = cell(M,N);
for iProp = 1:N
   tmp = get_param(sysV, propList{iProp});
   if iscell(tmp)
      val(:,iProp) = tmp;
   else
      val(:,iProp) = {tmp};
   end
end

function Lset_param(sysV, propList, valueList)
M = length(sysV);
N = length(propList);
for iSys = 1:M
   args = reshape(cat(1,propList, valueList(iSys,:)),1,2*N);
   set_param(sysV(iSys),args{:});
end
   

% these assume that there is only one sysV
function [oldSysSettings,oldRootSettings] = Lsafe_open(sysV)
rootProps = {'Dirty' 'Lock'};
sysProps = {'Open'};
myRoots = unique(bdroot(sysV));

oldSysSettings = Lget_param(sysV,sysProps);
oldRootSettings = Lget_param(myRoots,rootProps);
Lset_param(myRoots, {'Lock'}, {'off'});
Lset_param(sysV, {'Open'}, {'on'});

   
function Lsafe_restore(sysV,oldSysSettings,oldRootSettings)
rootProps = {'Dirty' 'Lock'};
sysProps = {'Open'};
myRoots = unique(bdroot(sysV));

Lset_param(sysV,sysProps,oldSysSettings);
Lset_param(myRoots,{'Dirty'},oldRootSettings(:,1));
Lset_param(myRoots,{'Lock'},oldRootSettings(:,2));



