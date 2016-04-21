function varargout=worldhi(varargin)

% WORLDHI returns data from the 1:1,000,000 WORLDHI atlas data file
% 
%   WORLDHI types a list of the atlas data variables in the WORLDHI Mat-file to
%   the screen.
%   
%   s = WORLDHI('request') returns the requested variable.  Valid requests 
%   are 'POpatch', 'POtext', 'PPpoint', 'PPtext', and any country name in the
%   WORLDHI database. Multiple countries can be requested by string matrices
%   or cell arrays of string. The result is returned as a geographic data 
%   structure. This command can be used as an argument to other commands, such 
%   as DISPLAYM(WORLDHI('POtext')) or DISPLAYM(WORLDHI('france')). The WORLDHI 
%   database contains country outlines and text originally compiled at a scale 
%   of 1:1,000,000. 
%
%   s = WORLDHI('countryname',minarea) removes small islands from the output.
%   Only polygon faces with an area greater than minarea (in units of square 
%   kilometers) are returned.
%
%   s = WORLDHI('countryname','searchmethod') controls the method used to
%   match the country name input.  Search method 'strmatch' searches for 
%   matches at the beginning of the name, similar to the MATLAB STRMATCH 
%   function.  Search method 'findstr' searches within the name, similar to 
%   the MATLAB FINDSTR function.  Search method 'exact' requires an exact 
%   match. If omitted, search method 'strmatch' is assumed. The search is not
%   case-sensitive.
%  
%   s = WORLDHI('countryname','searchmethod',minarea) controls both the minumum
%   area and the string matching method.
%
%   s = WORLDHI(latlim,lonlim) returns all countries within a quadrangle. Latlim
%   and lonlim are two element vectors in units of degrees positive or negative
%   from the prime meridian. Islands or noncontiguous parts of the countries that
%   fall completely outside the requested region are omitted from the output.
%
%   s = worldhi(latlim,lonlim,minarea) also removes small islands from the output.
%   Only polygon faces with an area greater than minarea (in units of square 
%   kilometers) are returned.
%
%   See also WORLDLO, COAST, USAHI, USALO, WORLDHI.MAT, DISPLAYM

%  Copyright 1996-2003 The MathWorks, Inc.




if nargin == 0                                           %worldhi
      
   worldhilist
   return
   
elseif nargin==1 & isstr(varargin{1}) & strmatch(lower(varargin{1}),'popatch') %worldhi POpatch 
   
   gstruct=worldhigetall;

elseif nargin==1 & isstr(varargin{1}) & strmatch(lower(varargin{1}),'potext') %worldhi POtext 
   
   s=load('worldhi','POtext');gstruct=s.POtext;
   
elseif nargin==1 & isstr(varargin{1}) & strmatch(lower(varargin{1}),'pppoint') %worldhi PPpoint 
   
   s=load('worldhi','PPpoint');gstruct=s.PPpoint;
   
elseif nargin==1 & isstr(varargin{1}) & strmatch(lower(varargin{1}),'pptext') %worldhi PPtext 
   
   s=load('worldhi','PPtext');gstruct=s.PPtext;
   
elseif nargin==1                                         %worldhi(countryname) 
   
   countryname=varargin{1};
   gstruct=worldhigetcountries(countryname);
   
elseif nargin==2 & ( isstr(varargin{1}) | iscell(varargin{1}) ) & isnumeric(varargin{2})  % worldhi(countryname,minarea)
   countryname=varargin{1};
   method='strmatch';
   minarea=varargin{2};   
   gstruct=worldhigetcountries(countryname,method,minarea);
   
elseif nargin==2 & (isstr(varargin{1}) | iscell(varargin{1})) & isstr(varargin{2})  % worldhi(countryname,'method')
               
   countryname=varargin{1};
   method=varargin{2};  
   gstruct=worldhigetcountries(countryname,method);
   
elseif nargin==3 & (isstr(varargin{1}) | iscell(varargin{1})) & ...
                  isstr(varargin{2}) &   isnumeric(varargin{3})      % worldhi(countryname,'method',minarea)
               
   countryname=varargin{1};
   method=varargin{2};  
   minarea=varargin{3};   
   gstruct=worldhigetcountries(countryname,method,minarea);
   
elseif nargin==2 & max(size(varargin{1}))==2 & max(size(varargin{2}))==2  % worldhi(latlim,lonlim)
   
   latlim=varargin{1};
   lonlim=varargin{2};
   gstruct=worldhigetbylims(latlim,lonlim);
   
elseif nargin==3 & max(size(varargin{1}))==2 & max(size(varargin{2}))==2 & ...
      isnumeric(varargin{3}) & length(varargin{3})==1 % worldhi(latlim,lonlim,minarea)
   
   latlim=varargin{1};
   lonlim=varargin{2};
   minarea=varargin{3};
   gstruct=worldhigetbylims(latlim,lonlim,minarea);
   
else
   
   error('Incorrect calling form')
   
end

varargout{1}=gstruct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function worldhilist;

s=load('worldhi','POpatch');
POpatch=s.POpatch;

disp('    ')
disp('WORLDLO atlas data:')
disp('    ')
%disp(description)
disp('    ')
disp('  Geographic Data Structures: ')
disp('    ')
disp('    POpatch       - Countries as patches')
disp('    POtext        - Names of water bodies as text')
disp('    PPpoint       - Major cities as points')
disp('    PPtext        - Major cities as text labels')
disp('    ')
disp('  Countries in the WORLDHI database:')
disp('    ')
disp([char(32)*ones(length(POpatch),4) strvcat(POpatch.tag)])
disp('    ')
disp(sprintf('If the list has scrolled off the top of your screen, try: \n    more on; worldhi listcountries; more off'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gstruct=worldhigetall;

s=load('worldhi','POpatch');
POpatch=s.POpatch;

indx=1:length(POpatch);

gstruct=worldhigetbyindx(POpatch,indx);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gstruct=worldhigetcountries(objects,method,minarea);

if nargin < 2; method='strmatch'; end
if nargin < 3; minarea=0; end

%load structure containing information about all the countries, but not the
%outlines of the countries

s=load('worldhi','POpatch');
mstruct=s.POpatch;


%identify the indices of the requested countries. Request may be string matrix
%or cell array of strings

if isempty(objects)
  indx = 1:length(mstruct);
else
  indx = [];
  if iscell(objects)
    for i=1:length(objects)
       thisindx = findstrmat(lower(str2mat(mstruct(:).tag)),...
          lower(objects{i}),method);
      indx = [indx; thisindx];
    end % for
  else
    for i=1:size(objects,1)
      thisindx = findstrmat(lower(str2mat(mstruct(:).tag)),...
            deblank(lower(objects(i,:))),method);
      indx = [indx; thisindx];
    end % for i
  end % if iscell(objects)
  if isempty(indx);   error('Object string not found');  end
end

indx = unique(indx);

gstruct=worldhigetbyindx(mstruct,indx,minarea);

%*********************************************************************
function gstruct=worldhigetbylims(latlim,lonlim,minarea)

if nargin < 3; minarea=0; end

%load structure containing information about all the countries, but not the
%outlines of the countries

s=load('worldhi','POpatch');
POpatch=s.POpatch;

%identify the indices of countries that overlap the requested quadrangle

      objlatlim = cat(1,POpatch.latlim);
      objlonglim = cat(1,POpatch.longlim);
      
      indx = ...
         find( ...
         (...
         (latlim(1) <= objlatlim(:,1) & latlim(2) >= objlatlim(:,2)) | ... % object is completely within region
         (latlim(1) >= objlatlim(:,1) & latlim(2) <= objlatlim(:,2)) | ... % region is completely within object
         (latlim(1) >  objlatlim(:,1) & latlim(1) <  objlatlim(:,2)) | ... % min of region is on object
         (latlim(2) >  objlatlim(:,1) & latlim(2) <  objlatlim(:,2))   ... % max of region is on object
         ) ...
         &...
         (...
         (lonlim(1) <= objlonglim(:,1) & lonlim(2) >= objlonglim(:,2)) | ... % object is completely within region
         (lonlim(1) >= objlonglim(:,1) & lonlim(2) <= objlonglim(:,2)) | ... % region is completely within object
         (lonlim(1) >  objlonglim(:,1) & lonlim(1) <  objlonglim(:,2)) | ... % min of region is on object
         (lonlim(2) >  objlonglim(:,1) & lonlim(2) <  objlonglim(:,2))   ... % max of region is on object
         )...
         );
      
gstruct=worldhigetbyindx(POpatch,indx,minarea,latlim,lonlim);

%*********************************************************************
function gstruct=worldhigetbyindx(POpatch,indx,minarea,latlim,lonlim)

if nargin < 3; minarea = 0; end
if nargin < 4; latlim = []; end
if nargin < 5; lonlim = []; end

if isempty(indx); 
    gstruct = [];    
    return
end

for i=1:length(indx)
   s=load('worldhi',POpatch(indx(i)).sname);
   t=struct2cell(s);
   gstruct(i)=t{:};
   
   [lat,lon]=deal(gstruct(i).lat,gstruct(i).long);
   
   if minarea > 0
      indxa=find(POpatch(indx(i)).area < minarea);
      [latcells,loncells]=polysplit(lat,lon);
      latcells(indxa)=[];
      loncells(indxa)=[];
      [lat,lon]=polyjoin(latcells,loncells);
      gstruct(i).lat=lat;
      gstruct(i).long=lon;
      gstruct(i).latlims(indxa,:)=[];
      gstruct(i).longlims(indxa,:)=[];
   end
   
   if ~isempty(latlim) & ~ isempty(lonlim)
      objlatlim = cat(1,gstruct(i).latlims);
      objlonglim = cat(1,gstruct(i).longlims);
      
      do = ...
         find( ...
         (...
         (latlim(1) <= objlatlim(:,1) & latlim(2) >= objlatlim(:,2)) | ... % object is completely within region
         (latlim(1) >= objlatlim(:,1) & latlim(2) <= objlatlim(:,2)) | ... % region is completely within object
         (latlim(1) >  objlatlim(:,1) & latlim(1) <  objlatlim(:,2)) | ... % min of region is on object
         (latlim(2) >  objlatlim(:,1) & latlim(2) <  objlatlim(:,2))   ... % max of region is on object
         ) ...
         &...
         (...
         (lonlim(1) <= objlonglim(:,1) & lonlim(2) >= objlonglim(:,2)) | ... % object is completely within region
         (lonlim(1) >= objlonglim(:,1) & lonlim(2) <= objlonglim(:,2)) | ... % region is completely within object
         (lonlim(1) >  objlonglim(:,1) & lonlim(1) <  objlonglim(:,2)) | ... % min of region is on object
         (lonlim(2) >  objlonglim(:,1) & lonlim(2) <  objlonglim(:,2))   ... % max of region is on object
         )...
         );
      
      if isempty(do);
         [lat,lon]=deal([],[]);
      else
         [latcells,loncells]=polysplit(lat,lon);
         latcells=latcells(do);
         loncells=loncells(do);
         [lat,lon]=polyjoin(latcells,loncells);
         gstruct(i).area=gstruct(i).area(do);
         gstruct(i).latlims=gstruct(i).latlims(do,:);
         gstruct(i).longlims=gstruct(i).longlims(do,:);
         
      end
      
      gstruct(i).lat=lat;
      gstruct(i).long=lon;
   end
   
end

for i=length(indx):-1:1
   if isempty(gstruct(i).lat); gstruct(i)=[];end
end


   

%*********************************************************************
%*********************************************************************

function indx = findstrmat(strmat,searchstr,method)

% find matches in vector

switch method
  case 'findstr'
    strmat(:,end+1) = 13; % add a lineending character to prevent matches across rows
    % make string matrix a vector
    sz = size(strmat);
    strmat = strmat';
    strvec = strmat(:)';
    vecindx = findstr(searchstr,strvec);
    % vector indices to row indices
    indx = unique(ceil(vecindx/sz(2)));
  case 'strmatch'
    indx = strmatch(searchstr,strmat);
  case 'exact'
    indx = strmatch(searchstr,strmat,'exact');
  otherwise
    error('Recognized methods are ''exact'', ''strmatch'' and ''findstr''')
end

