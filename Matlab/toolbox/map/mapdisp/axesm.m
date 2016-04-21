function [h,msg] = axesm(varargin)
%AXESM Create a new map axes/define a map projection. 
%
%  AXESM activates a GUI to define a map projection for the current axes.
%
%  AXESM(PROPERTYNAME, PROPERTYVALUE,...) uses the map properties in the
%  input list to define a map projection for the current axes. For a list
%  of map projection properties, execute GETM AXES.  All standard
%  (non-mapping) axes properties are controlled using the axes command. For
%  a list of available projections, execute MAPS.
%
%  AXESM(MSTRUCT,...) uses the map structure specified by MSTRUCT to
%  initialize the map projection.
%
%  AXESM(PROJFCN,...) uses the m-file specified by the string PROJFCN to
%  initialize the map projection.  If this form is used, PROJFCN must
%  correspond to an m-file on the user's path and is case-sensitive.
%
%  See also AXES, GETM, MAPLIST, MAPS, MFWDTRAN, MINVTRAN, PROJFWD,
%  PROJINV, PROJLIST, SETM.

%  Copyright 1996-2004 The MathWorks, Inc.
%  $Revision: 1.14.4.3 $  $Date: 2004/03/24 20:41:18 $
%  Written by:  E. Byrns, E. Brown


%  Initialize output variables

if nargout ~= 0;  h = [];  msg = [];   end
msg0 = [];

%  Initialize default map structure.
%  Save each of the field names to compare with passed in properties

mstruct = defaultm;               %  AXESM algorithm requires mfields to
mfields = fieldnames(mstruct);    %  always remain a cell array.

%  Test input arguments

if (nargin > 0) && any(ishandle(varargin{1}))
   eid = sprintf('%s:%s:invalidFirstParam', getcomp, mfilename);
   error(eid,'%s','First argument must be a map property name or map structure')
end

if nargin == 0
   if ~ismap(gca)
      [list,defproj] = maplist; % get the default projection
      mstruct.mapprojection = defproj;
      mstruct = feval(mstruct.mapprojection,mstruct);
      mstruct = defaultm(mstruct);
      set(gca,'NextPlot','Add', 'UserData',mstruct,...
         'DataAspectRatio',[1 1 1],...
         'Box','on', 'ButtonDownFcn','uimaptbx')
      set(gca,'XLimMode','auto', 'YLimMode', 'auto')  %  Special for non-map axes
      showaxes off                                    %  since may not hit mapprojection case
      set(gcf,'renderer','zbuffer');
   end
   cancelflag = axesmui;
   if nargout ~= 0;  h = cancelflag;  end
   return
   
elseif nargin == 1 && ~ischar(varargin{1}) && ~isstruct(varargin{1})
   [mflag,msg] = ismap(varargin{1});
   if ~mflag
      eid = sprintf('%s:%s:invalidMap', getcomp, mfilename);
      error(eid,'%s',msg)
   else
      axes(varargin{1});
      return
   end
   
elseif rem(nargin,2)
   if isstruct(varargin{1})                         %  Passed in structure
      mstruct    = varargin{1};                   %  Make sure all fields
      newfields  = char(fieldnames(mstruct));     %  are present
      testfields = char(mfields);    %  Perform tests on string matrices
      startpt   = 2;
      
      newfields  = sortrows(char(fieldnames(mstruct)));     %  are present
      testfields = sortrows(char(mfields));    %  Perform tests on string matrices
      
      if any(size(testfields) ~= size(newfields)) || ...
           any(any(testfields ~= newfields))
         msg0 = 'Incorrect map structure supplied';
         if nargout <= 1
            eid = sprintf('%s:%s:invalidMap', getcomp, mfilename);
            error(eid,'%s',msg0);
         else
            msg = msg0;
            return
         end
      end
      
   else
      startpt = 2;
      [mstruct.mapprojection,msg0] = maps(varargin{1});
      if isempty(msg0)
         mstruct = feval(mstruct.mapprojection,mstruct);
      elseif exist(varargin{1}) == 2
         mstruct = feval(varargin{1},mstruct); %  Initialize default structure
      else
         msg0 = 'Unspecified map axis property value';
         if nargout <= 1
            eid = sprintf('%s:%s:undefinedMapAxis', getcomp, mfilename);
            error(eid,'%s',msg0);
         else
            msg = msg0;   
            return
         end
      end
   end
else
   startpt = 1;
end

%  Permute the property list so that AngleUnits (if supplied) is first
%  and Projection is second.  AngleUnits must be processed first so
%  that all defaults end up in the proper units.  Projection must
%  be processed second so that any supplied parameter, such as
%  Parallels, is not overwritten by the defaults in the Projection m-file.

indx = (startpt:2:nargin-1)';
if ~isempty(indx)
   newindx = indx;
   properties = lower(char(varargin(indx)));
   
   indxa = strmatch('an',properties);     %  Use minimal form for AngleUnits
   indxp = strmatch('mappr',properties);  %  Use minimal form for Projection
   
   if ~isempty([indxa; indxp])
      newindx([indxa;indxp]) = [];
      if isempty(newindx)
         newindx = 2*[indxa; indxp]+startpt-2;
      else
         newindx = [2*[indxa; indxp]+startpt-2; newindx];
      end
      
      varargin(indx) = varargin(newindx);        %  Move property names
      varargin(indx+1) = varargin(newindx+1);    %  Move property values
   end
end


%  Cycle through all inputs.  Assumed form is (..., 'Property', value, ...)

for j = startpt : 2 : nargin-1
   
   %  Get the property name and test for validity
   
   indx = strmatch(lower(varargin{j}),mfields);
   if isempty(indx)
      msg0 = ['Unrecognized property:  ',varargin{j}];
      if nargout <= 1
         eid = sprintf('%s:%s:unknownProperty', getcomp, mfilename);
         error(eid,'%s',msg0)
      else
         msg = msg0;   
         return;    
      end
      
   elseif length(indx) == 1
      propname = mfields{indx};
   else
      msg0 = ['Property ',varargin{j},...
            ' name not unique - supply more characters'];
      if nargout <= 1
         eid = sprintf('%s:%s:nonUniqueName', getcomp, mfilename);
         error(eid,'%s',msg0)
      else
         msg = msg0;   
         return;    
      end
   end
   
   
   %  Get the property value and convert to lower case if necessary
   %  Ensure a row vector for all property values
   
   propvalu = varargin{j+1};      propvalu = propvalu(:)';
   if ischar(propvalu);    propvalu = lower(propvalu);   end
   
   %  Set the appropriate elements in the map structure corresponding
   %  to the property name
   
   switch propname
      
      %************************
      %  General Map Properties
      %************************
      
   case 'angleunits'
      if j ~= startpt
         msg0 = 'AngleUnits must be processed first';
         if nargout <= 1
            eid = sprintf('%s:%s:processError', getcomp, mfilename);
            error(eid,'%s',msg0);
         else
            msg = msg0;   
            return;    
         end
      end
      oldunits = mstruct.angleunits;
      [mstruct.angleunits,msg0] = unitstr(propvalu,'angles');
      if isempty(msg0);  mstruct = mapangles(mstruct,oldunits);  end
      
   case 'aspect'
      validparm = {'normal','transverse'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.aspect = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'geoid'
      if ischar(propvalu)
         if exist(propvalu) == 2
            mstruct.geoid = feval(propvalu,'geoid');
         else
            msg0 = ['Incorrect ',upper(propname),' property'];
         end
      else
         [mstruct.geoid,msg0] = geoidtst(propvalu);
         if isempty(msg0) && mstruct.geoid(1) == 0
            msg0 = 'Positive Geoid radius required';
         end
      end
      
   case 'maplatlimit'
      if ischar(propvalu) || (length(propvalu) ~= 2 && length(propvalu) ~= 0)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.maplatlimit = propvalu;
      end
      
   case 'maplonlimit'
      if ischar(propvalu) || (length(propvalu) ~= 2 && length(propvalu) ~= 0)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.maplonlimit = propvalu;
      end
      
   case 'mapparallels'
      if ischar(propvalu) || length(propvalu) > 2
         msg0 = ['Incorrect ',upper(propname),' property'];
      elseif mstruct.nparallels == 0
         msg0 = 'PARALLELS can not be specified for this projection';
      elseif length(propvalu) > mstruct.nparallels
         msg0 = 'Too many PARALLELS for this projection';
      else
         mstruct.mapparallels = propvalu;
      end
      
   case 'mapprojection'
      [mstruct.mapprojection,msg0] = maps(propvalu);
      if isempty(msg0);   
         
         switch mstruct.mapprojection
         case 'utm'
            mstruct.origin = []; % origin determined by ZONE
         end
         
         mstruct = feval(mstruct.mapprojection,mstruct);   
      end
      
      
   case 'origin'
      if ischar(propvalu) || length(propvalu) > 3
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         if length(propvalu) == 3 && ~isempty(mstruct.fixedorient)
            wid = sprintf('%s:%s:FixedOrientationWarn', getcomp, mfilename);
            warning(wid,'%s','Fixed Orientation supplied this projection')
         end
         
         switch mstruct.mapprojection
         case 'utm'
            wid = sprintf('%s:%s:UTMZoneWarn', getcomp, mfilename);
            warning(wid,'%s','Origin of a UTM projection is determined by the Zone property')
         otherwise
            mstruct.origin = propvalu;
         end
      end
      
   case 'zone'
      switch mstruct.mapprojection 
      case 'ups'
         if isempty(strmatch(propvalu,'north')) && ...
               isempty(strmatch(propvalu,'south'))
            msg0 = ['Incorrect ',upper(propname),' property. Recognized zones are ''north'' and ''south''.'];
         end
         if isempty(msg0);
            mstruct.zone =  propvalu;
            mstruct = feval(mstruct.mapprojection,mstruct);
            mstruct.maplatlimit = [];
            mstruct.flatlimit = [];
            mstruct.origin = [];
            mstruct.mlabelparallel = [];
            mstruct.mlinelimit = [];
         end
      case 'utm'
         [ltlim,lnlim,txtmsg] = utmzone(propvalu);
         if ~isempty(txtmsg)
            msg0 = sprintf(['Incorrect ',upper(propname),' property. Recognized zones are integers \nfrom 1 to 60 or numbers followed by letters from C to X.']);
         else
            mstruct.zone = upper(propvalu);
            mstruct.geoid = [];
            mstruct.maplatlimit = [];
            mstruct.maplonlimit = [];
            mstruct.flatlimit = [];
            mstruct.flonlimit = [];
            mstruct.origin = [];
            mstruct.mlinelocation = [];
            mstruct.plinelocation = [];
            mstruct.mlabellocation = [];
            mstruct.plabellocation = [];
            mstruct.mlabelparallel = [];
            mstruct.plabelmeridian = [];
            mstruct.falsenorthing = [];
         end
      otherwise
         msg0 = 'ZONE cannot be specified for this projection';
      end
      
   case 'scalefactor'
      if ~isnumeric(propvalu) || length(propvalu) > 1 ||  propvalu == 0
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         if strcmp(mstruct.mapprojection,'utm') || ...
               strcmp(mstruct.mapprojection,'ups')
            msg0 = 'SCALEFACTOR cannot be specified for this projection';
         else
            mstruct.scalefactor = propvalu;
         end
      end
      
   case 'falseeasting'
      if ~isnumeric(propvalu) || length(propvalu) > 1
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         if strcmp(mstruct.mapprojection,'utm') || ...
               strcmp(mstruct.mapprojection,'ups')
            msg0 = 'FALSEEASTING cannot be specified for this projection';
         else
            mstruct.falseeasting = propvalu;
         end
      end
      
   case 'falsenorthing'
      if ~isnumeric(propvalu) || length(propvalu) > 1
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         if strcmp(mstruct.mapprojection,'utm') || ...
               strcmp(mstruct.mapprojection,'ups')
            msg0 = 'FALSENORTHING cannot be specified for this projection';
         else
            mstruct.falsenorthing = propvalu;
         end
      end
      
      
      %******************
      %  Frame Properties
      %******************
      
   case 'frame'
      validparm = {'on','off','reset'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         if indx == 3;   indx = 1;  end  %  Reset becomes on
         mstruct.frame = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'fedgecolor'
      if ischar(propvalu) || ...
            (length(propvalu) == 3 && all(propvalu <= 1 & propvalu >= 0))
         mstruct.fedgecolor = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'ffacecolor'
      if ischar(propvalu) || ...
            (length(propvalu) == 3 && all(propvalu <= 1 & propvalu >= 0))
         mstruct.ffacecolor = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'ffill'
      if ~ischar(propvalu)
         mstruct.ffill = max([propvalu,2]);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'flatlimit'
      if ischar(propvalu) || length(propvalu) > 2
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.flatlimit = propvalu;
      end
      
   case 'flinewidth'
      if ~ischar(propvalu)
         mstruct.flinewidth = max([propvalu(:),0]);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'flonlimit'
      if ischar(propvalu) || (length(propvalu) ~= 2 && length(propvalu) ~= 0)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.flonlimit = propvalu;
      end
      
      
      %*************************
      %  General Grid Properties
      %*************************
      
   case 'grid'
      validparm = {'on','off','reset'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         if indx == 3;   indx = 1;  end  %  Reset becomes on
         mstruct.grid = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'galtitude'
      if ~ischar(propvalu)
         mstruct.galtitude = propvalu(1);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'gcolor'
      if ischar(propvalu) || ...
            (length(propvalu) == 3 && all(propvalu <= 1 & propvalu >= 0))
         mstruct.gcolor = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'glinestyle'
      [lstyle,lcolor,lmark,msg0] = colstyle(propvalu);
      if ~isempty(msg0)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.glinestyle = lstyle;
         if isempty(lstyle)
            wid = sprintf('%s:%s:missingGridLineStyle', getcomp, mfilename);
            warning(wid,'%s','Missing grid line style.');  
         end
      end
      
   case 'glinewidth'
      if ~ischar(propvalu)
         mstruct.glinewidth = max([propvalu(:),0]);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
      
      %**************************
      %  Meridian Grid Properties
      %**************************
      
   case 'mlineexception'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.mlineexception = propvalu;
      end
      
   case 'mlinefill'
      if ~ischar(propvalu)
         mstruct.mlinefill = max([propvalu, 2]);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'mlinelimit'
      if ischar(propvalu) || length(propvalu) ~= 2
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.mlinelimit = propvalu;
      end
      
   case 'mlinelocation'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      elseif length(propvalu) == 1
         mstruct.mlinelocation = abs(propvalu);
      else
         mstruct.mlinelocation = propvalu;
      end
      
   case 'mlinevisible'
      validparm = {'on','off'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.mlinevisible = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
      
      %**************************
      %  Parallel Grid Properties
      %**************************
      
   case 'plineexception'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.plineexception = propvalu;
      end
      
   case 'plinefill'
      if ~ischar(propvalu)
         mstruct.plinefill = max([propvalu, 2]);
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'plinelimit'
      if ischar(propvalu) || length(propvalu) ~= 2
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.plinelimit = propvalu;
      end
      
   case 'plinelocation'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      elseif length(propvalu) == 1
         mstruct.plinelocation = abs(propvalu);
      else
         mstruct.plinelocation = propvalu;
      end
      
   case 'plinevisible'
      validparm = {'on','off'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.plinevisible = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
      
      %**************************
      %  General Label Properties
      %**************************
      
   case 'fontangle'
      validparm = {'normal','italic','oblique'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.fontangle = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'fontcolor'
      if ischar(propvalu) || ...
            (length(propvalu) == 3 && all(propvalu <= 1 & propvalu >= 0))
         mstruct.fontcolor = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'fontname'
      if ischar(propvalu)
         mstruct.fontname = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'fontsize'
      if ischar(propvalu) || length(propvalu) ~= 1
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.fontsize = propvalu;
      end
      
   case 'fontunits'
      validparm = {'points','normalized','inches',...
         'centimeters','pixels'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.fontunits = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'fontweight'
      validparm = {'normal','bold'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.fontweight = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'labelformat'
      validparm = {'compass','signed','none'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.labelformat = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'labelunits'
      [mstruct.labelunits,msg0] = unitstr(propvalu,'angles');
      
   case 'labelrotation'
      validparm = {'on','off'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         mstruct.labelrotation = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
      
      %***************************
      %  Meridian Label Properties
      %***************************
      
   case 'meridianlabel'
      validparm = {'on','off','reset'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         if indx == 3;   indx = 1;  end  %  Reset becomes on
         mstruct.meridianlabel = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'mlabellocation'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      elseif length(propvalu) == 1
         mstruct.mlabellocation = abs(propvalu);
      else
         mstruct.mlabellocation = propvalu;
      end
      
   case 'mlabelparallel'
      if ischar(propvalu)
         validparm = {'north','south','equator'};
         indx = strmatch(propvalu,validparm);
         if length(indx) == 1
            mstruct.mlabelparallel = validparm{indx};
         else
            msg0 = ['Incorrect ',upper(propname),' property'];
         end
      elseif length(propvalu) == 1
         mstruct.mlabelparallel = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'mlabelround'
      if ischar(propvalu) || length(propvalu) ~= 1
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.mlabelround = round(propvalu);
      end
      
      
      %***************************
      %  Parallel Label Properties
      %***************************
      
   case 'parallellabel'
      validparm = {'on','off','reset'};
      indx = strmatch(propvalu,validparm);
      if length(indx) == 1
         if indx == 3;   indx = 1;  end  %  Reset becomes on
         mstruct.parallellabel = validparm{indx};
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'plabellocation'
      if ischar(propvalu)
         msg0 = ['Incorrect ',upper(propname),' property'];
      elseif length(propvalu) == 1
         mstruct.plabellocation = abs(propvalu);
      else
         mstruct.plabellocation = propvalu;
      end
      
   case 'plabelmeridian'
      if ischar(propvalu)
         validparm = {'east','west','prime'};
         indx = strmatch(propvalu,validparm);
         if length(indx) == 1
            mstruct.plabelmeridian = validparm{indx};
         else
            msg0 = ['Incorrect ',upper(propname),' property'];
         end
      elseif length(propvalu) == 1
         mstruct.plabelmeridian = propvalu;
      else
         msg0 = ['Incorrect ',upper(propname),' property'];
      end
      
   case 'plabelround'
      if ischar(propvalu) || length(propvalu) ~= 1
         msg0 = ['Incorrect ',upper(propname),' property'];
      else
         mstruct.plabelround = round(propvalu);
      end
      
   otherwise
      msg0 = ['Read only property ',upper(propname), ' can not be modified'];
   end
   
   %  Process an error condition if it exists
   
   if ~isempty(msg0)
      if nargout <= 1
         eid = sprintf('%s:%s:axesmError', getcomp, mfilename);
         error(eid,'%s',msg0)
      else
         msg = msg0;   
         return;    
      end
   end
end


%  Check for defaults to be computed.

[mstruct,msg0] = defaultm(mstruct);
if ~isempty(msg0)
   if nargout <= 1
      eid = sprintf('%s:%s:defaultmError', getcomp, mfilename);
      error(eid,'%s',msg0)
   else
      msg = msg0;   
      return;    
   end
end

%  Set the properties of the map axes

set(gca,'NextPlot','Add', 'UserData',mstruct,...
   'DataAspectRatio',[1 1 1],...
   'Box','on', 'ButtonDownFcn','uimaptbx')

set(gcf,'renderer','zbuffer');

%  Show the axes background but not the axes labels

showaxes('off');

%  Display grid and frame if necessary

if strcmp(mstruct.frame,'on');          framem('reset');   end
if strcmp(mstruct.grid,'on');           gridm('reset');    end
if strcmp(mstruct.meridianlabel,'on');  mlabel('reset');   end
if strcmp(mstruct.parallellabel,'on');  plabel('reset');   end

%  Set output variable if necessary

if nargout >= 1;   h = gca;   end


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************

function mstruct = mapangles(mstruct,oldunits)

%MAPANGLES  Changes the angle units of a map structure
%
%  MAPANGLES changes the angle units of the appropriate elements of
%  a map structure from the oldunits (input) to the mstruct.angleunits
%  (new units).  This is necessary if a user changes the angle units
%  using a setm command.  It should have no significant effect on
%  a straightforward axesm call.

newunits = mstruct.angleunits;

mstruct.fixedorient    = angledim(mstruct.fixedorient,oldunits,newunits);
mstruct.maplatlimit    = angledim(mstruct.maplatlimit,oldunits,newunits);
mstruct.maplonlimit    = angledim(mstruct.maplonlimit,oldunits,newunits);
mstruct.mapparallels   = angledim(mstruct.mapparallels,oldunits,newunits);
mstruct.origin         = angledim(mstruct.origin,oldunits,newunits);
mstruct.flatlimit      = angledim(mstruct.flatlimit,oldunits,newunits);
mstruct.flonlimit      = angledim(mstruct.flonlimit,oldunits,newunits);
mstruct.mlineexception = angledim(mstruct.mlineexception,oldunits,newunits);
mstruct.mlinelimit     = angledim(mstruct.mlinelimit,oldunits,newunits);
mstruct.mlinelocation  = angledim(mstruct.mlinelocation,oldunits,newunits);
mstruct.plineexception = angledim(mstruct.plineexception,oldunits,newunits);
mstruct.plinelimit     = angledim(mstruct.plinelimit,oldunits,newunits);
mstruct.plinelocation  = angledim(mstruct.plinelocation,oldunits,newunits);
mstruct.mlabellocation = angledim(mstruct.mlabellocation,oldunits,newunits);
mstruct.mlabelparallel = angledim(mstruct.mlabelparallel,oldunits,newunits);
mstruct.plabellocation = angledim(mstruct.plabellocation,oldunits,newunits);
mstruct.plabelmeridian = angledim(mstruct.plabelmeridian,oldunits,newunits);
mstruct.trimlat        = angledim(mstruct.trimlat,oldunits,newunits);
mstruct.trimlon        = angledim(mstruct.trimlon,oldunits,newunits);

