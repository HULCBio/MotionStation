function [h,msg] = displaym(varargin)

%DISPLAYM  Project data in a geographic data structure
%
%  DISPLAYM(mstruct) will project the data contained in the input
%  structure onto the current axes.  The current axes must have a
%  valid map definition.  The input mstruct must be a valid Mapping
%  Toolbox Geographic Data Structure.
%
%  DISPLAYM(mstruct,'object') will display vector data from
%  entries in the Mapping Toolbox Geographic Data structure whose
%  tag begins the 'object' string.  The output vectors use NaNs to
%  separate the individual entries in the map structure.  Matches of
%  the tag string must be vector data (lines and patches) to be
%  included in the output. The search is not case-sensitive.
%
%  DISPLAYM(mstruct,objects), where objects is a character
%  array or a cell array or strings, allows more than one object to
%  be the basis for the search. Character array objects will have 
%  trailing spaces stripped before matching.
%
%  [lat,lon]=DISPLAYM(mstruct,objects,'searchmethod') controls the method 
%  used to match the objects input.  Search method 'strmatch' searches for 
%  matches at the beginning of the tag, similar to the MATLAB STRMATCH 
%  function.  Search method 'findstr' searches within the tag, similar to 
%  the MATLAB FINDSTR function.  Search method 'exact' requires an exact 
%  match. If omitted, search method 'strmatch' is assumed. The search is 
%  case-sensitive.
%
%  h = DISPLAYM(mstruct) returns the handles to the objects projected.
%
%  See also MLAYERS, EXTRACTM

%  Written by:  E. Byrns, E. Brown, W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.15.4.1 $ $Date: 2003/08/01 18:18:18 $

%  Programmer's note:  The second output argument msg is provided for
%  the operation of mlayers.  It is not intended as a user output, because
%  msg only returns the errors encountered in the plotting routines, but
%  not other errors which may be encountered (eg:missing structure fields, etc)

%  Initialize output if necessary

if nargout ~= 0;  h = [];  msg = [];  end

% handle cell arrays from rootlayr or vmap0ui
if nargin >= 1 & iscell(varargin{1}) & size(varargin{1},2) == 2
   h0 = [];
   c=varargin{1};
   for i=1:size(c,1)
      if nargin == 1
         hi = displaym(c{i,1});
      else
         hi = displaym(c{i,1},varargin{2:end});
      end
      
      if ~isempty(hi)
         h0 = [h0 hi];
      end
   end
   return
end


if nargin == 0;  error('Incorrect number of arguments');  
elseif nargin == 1; 
  mstruct = varargin{1};
  if isempty(mstruct); return; end
  indx = 1:length(mstruct);
elseif nargin == 2 | nargin == 3; 
  mstruct = varargin{1};varargin(1) = [];
  if isempty(mstruct); return; end   
  w = warning; warning off
  [lat,lon,indx] = extractm(mstruct,varargin{:});
  warning(w)
  h0 = displaym(mstruct(indx));
  if nargout > 0;  h = h0;  end
  return
end

clrcount = 0;                                %  Variables for coloring of
colororder = get(gca,'ColorOrder');          %  lines if no properties supplied
cdataoffset = length(get(gca,'Children'));   %  Indexing of patch face color

utags = unique(strvcat(mstruct.tag),'rows'); %  unique tags, for coloring

%  Loop through the structure, plotting each member
h0 = [];

for i = 1:length(mstruct)
   
   if isempty(mstruct(i).altitude); 
      
      switch mstruct(i).type
      case {'patch','regular'}
         alt = 0;
      otherwise      
         alt = 0*ones(size(mstruct(i).lat));
      end
      
   else;
      
      alt = mstruct(i).altitude;
      
   end
   
  
  %  Plot using other properties if they're supplied. 
  %  If applying properties causes an error, try again without. This may
  %  result in some residue on the plot.
  
  if ~isempty(mstruct(i).otherproperty) & iscell(mstruct(i).otherproperty)
    
    switch mstruct(i).type
    case 'light'
       try
        [htemp,msg] = lightm(mstruct(i).lat,mstruct(i).long,alt,...
           mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = lightm(mstruct(i).lat,mstruct(i).long,alt);
       end
     
      case 'line'
        
       try
        [htemp,msg] = linem(mstruct(i).lat,mstruct(i).long,alt,...
           mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = linem(mstruct(i).lat,mstruct(i).long,alt);
       end
      case 'patch'
       try
        [htemp,msg] = patchesm(mstruct(i).lat,mstruct(i).long,alt,...
            mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = patchesm(mstruct(i).lat,mstruct(i).long,alt);
       end
      case 'regular'
       try
        [htemp,msg] = meshm(mstruct(i).map,mstruct(i).maplegend,...
            mstruct(i).meshgrat,alt,...
            mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = meshm(mstruct(i).map,mstruct(i).maplegend,...
            mstruct(i).meshgrat,alt);
       end
      case 'surface'
       try
        [htemp,msg] = surfacem(mstruct(i).lat,mstruct(i).long,...
            mstruct(i).map,alt,...
            mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = surfacem(mstruct(i).lat,mstruct(i).long,...
            mstruct(i).map,alt);
       end
      case 'text'
       try
        [htemp,msg] = textm(mstruct(i).lat,mstruct(i).long,alt,...
            mstruct(i).string,...
            mstruct(i).otherproperty{:});
       catch
        [htemp,msg] = textm(mstruct(i).lat,mstruct(i).long,alt,...
            mstruct(i).string);
       end
    end
  else     %  No other properties
    switch mstruct(i).type
      case 'light'
        [htemp,msg] = lightm(mstruct(i).lat,mstruct(i).long,alt);
      case 'line'
        % to color all similarly tagged objects the same
        indx = strmatch(mstruct(i).tag,utags,'exact');
        % no match, tag was empty
        if isempty(indx); indx = i;  end              
        %  Adjust the default color spec
        clrcount = 1+mod(indx,size(colororder,1)) ;    
        clrstring = colororder(clrcount,:);
        
        [htemp,msg] = linem(mstruct(i).lat,mstruct(i).long,alt,...
            'Color',clrstring);
      case 'patch'     %  Use face color indexing as a default
        
        % to color all similarly tagged objects the same
        indx = strmatch(mstruct(i).tag,utags,'exact');  
        if isempty(indx); indx = i;  end            % no match, tag was empty
        
        [htemp,msg] = patchesm(mstruct(i).lat,mstruct(i).long,alt,...
            'Cdata',cdataoffset+indx,'FaceColor','flat');
      case 'regular'
        [htemp,msg] = meshm(mstruct(i).map,mstruct(i).maplegend,...
            mstruct(i).meshgrat,alt);
      case 'surface'
        [htemp,msg] = surfacem(mstruct(i).lat,mstruct(i).long,...
            mstruct(i).map,alt);
      case 'text'
         [htemp,msg] = textm(mstruct(i).lat,mstruct(i).long, ...
            alt,...
            mstruct(i).string);
    end
  end
  
  if ~isempty(msg)        % htemp will be empty if error exists.
    if nargout < 2;  error(msg);  end
    return
  else
    h0 = [h0 htemp(:)'];   set(htemp,'Tag',mstruct(i).tag)
  end
end


%  Set output arguments if necessary

if nargout > 0;  h = h0;  end

