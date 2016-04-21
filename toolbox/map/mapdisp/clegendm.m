function clegendm(varargin)
%CLEGENDM	Add a legend labels to a map contour plot.
%
%  CLEGENDM(CS,H) adds a legend specifying the contour line heights
%  to the current map contour plot.  CS and H are the contour matrix
%  output and object handle outputs from CONTOURM or CONTOUR3M.
%
%  CLEGENDM(CS,H,Pos) places the legend in the specified location:
%        0 = Automatic placement (default)
%        1 = Upper right-hand corner
%        2 = Upper left-hand corner
%        3 = Lower left-hand corner
%        4 = Lower right-hand corner
%       -1 = To the right of the plot
%
%  CLEGENDM(...,UNITSTR) appends the character string UNITSTR to each 
%  entry in the legend.
%
%  CLEGENDM(...,STR) uses the strings specified in cell array STR.  STR must 
%  have same number of entries as H.
%
%  Examples:
%
%    % Load topographic data measured in meters                                 
%    load topo;                                                                 
%    axesm robinson; framem                                                     
%    [cs,h] = contourm(topo,topolegend,3);                                       
%    % Create Legend in Upper Right Hand Corner (Elevation in meters)
%    clegendm(cs,h,2);                                                          
%
%    % Load topographic data measured in meters                                 
%    load topo;                                                                 
%    axesm robinson; framem                                                     
%    [cs,h] = contourm(topo,topolegend,3); 
%    % Create Legend with units in Upper Right Hand Corner (Elevation in meters)
%    clegendm(cs,h,2,' m');  
%
%    % Load topographic data measured in meters                                 
%    load topo;                                                                 
%    axesm robinson; framem                                                     
%    [cs,h] = contourm(topo,topolegend,3); 
%    % Create Legend with user specified string
%    str = {'low altitude','medium altitude','high altitude'}
%    clegendm(cs,h,2,str);  
%
%
%  See also CLABELM, CONTOURM, CONTOUR3M.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.1 $ $Date: 2003/08/01 18:17:53 $
%  Written by:  E. Byrns, E. Brown



checknargin(1,4,nargin,mfilename);
if nargin == 1
     legend(varargin{1})
elseif nargin == 2
     c = varargin{1};    h = varargin{2};   Pos = 0;            Str = {};
elseif nargin == 3
     c = varargin{1};    h = varargin{2};   Pos = varargin{3};  Str = {};
     if isempty(Pos); Pos = 0; end
else
     c = varargin{1};    h = varargin{2};   Pos = varargin{3};  
     Str = varargin{4};
     if isempty(Pos); Pos = 0; end
end


% character string entered, expand into cell array of strings
if iscell(Str) == 0 
    
	% Get the contour line data values.
	values = char(get(h,'Tag'));
	
	% Construct a string matrix consisting of the units value.
	unitsStr = repmat(Str,size(values,1),1);
	
	% Concatenate the data and units string matrices and convert
	% the resulting string matrix to a cell array of strings.
	Str = cellstr(strcat(values,unitsStr));
    
end


%  Test that a map axes is present

if ~ismap   
   eid = sprintf('%s:%s:invalidMapAxes', getcomp, mfilename);
   error(eid,'%s','Map axes are not current');    
end
axishndl = gca;  %  Save current axes handle.  Legend creates a new axes

%  Get the levels for each contour line drawn

level = zeros(size(h));    startpt = 1;
for i = 1:length(h)
        level(i) = c(1,startpt);
        startpt = startpt + c(2,startpt) + 1;
end

%  Sort the contour levels and corresponding handles

[level,indx] = sort(level);
h = h(indx);

%  Determine if any contour levels are duplicated

difflevels = diff(level);
indx = find(difflevels == 0);
if ~isempty(indx);   level(indx+1)=[];   h(indx+1) = [];   end

%  Add a legend to the current plot

if isempty(Str)
	legend(h,num2str(level),Pos)
else
    legend(h,char(Str),Pos)
end

set(get(axishndl,'Parent'),'CurrentAxes',axishndl)  %  Reset current axes

%  Assign the SCRIBE callbacks to the legend objects

legndhndl = findobj(gcf,'Type','axes','Tag','legend');
children = get(legndhndl,'Children');
set(children,'ButtonDownFcn','uimaptbx')
