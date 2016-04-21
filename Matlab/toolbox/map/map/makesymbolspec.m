function symbolspec = makesymbolspec(Geometry,varargin)
%MAKESYMBOLSPEC Construct layer symbolization specification. 
%
%   SYMBOLSPEC = MAKESYMBOLSPEC(GEOMETRY,RULE1,RULE2,...RULEN) constructs a
%   Symbol Specification structure for symbolizing a shape layer in the Map
%   Viewer or when using MAPSHOW.  GEOMETRY is one of 'Point',
%   'MultiPoint', 'Line', 'Polygon', or 'Patch'.  RULEN, defined in detail
%   below, is the rule to use to determine the graphics properties for each
%   feature of the layer.  RULEN may be a default rule that is applied to
%   all features in the layer or it may limit the symbolization to only
%   features that have a particular value for a specified attribute.
%   Features that don't match any rules will be displayed using the default
%   graphics properties.
%
%   To create a rule that applies to all features, a default rule, use the
%   following syntax for RULEN:
%
%      {'Default',Property1,Value1,Property2,Value2,...,PropertyN,ValueN}
%
%   To create a rule that applies to only features that have a particular
%   value or range of values for a specified attribute, use the following
%   syntax:
%
%      {AttributeName,AttributeValue,Property1,Value1,...
%       Property2,Value2,...,PropertyN,ValueN}
%
%      AttributeValue and ValueN can each be a two element vector, [low
%      high], specifying a range. If AttributeValue is a range, ValueN may
%      or may not be a range. 
%
%   The following is a list of allowable values for PropertyN.  
%
%      Lines: 'Color', 'LineStyle', 'LineWidth', and 'Visible.'
%    
%      Points or Multiponts: 'Marker', 'Color', 'MarkerEdgeColor',
%      'MarkerFaceColor','MarkerSize', and 'Visible.'
%    
%      Polygons: 'FaceColor', 'FaceAlpha', 'LineStyle', 'LineWidth',
%      'EdgeColor', 'EdgeAlpha', and 'Visible.'
%
%   Data for Examples
%   -----------------
%   roads = shaperead('concord_roads.shp');
%
%   Example 1 
%   ---------
%   % Setting Default Color
%   blueRoads = makesymbolspec('Line',{'Default','Color',[0 0 1]});
%   mapshow(roads,'SymbolSpec',blueRoads);
%
%   Example 2 
%   ---------
%   % Setting Discrete Attribute Based
%   roadColors = makesymbolspec('Line',{'CLASS',2,'Color','r'},...
%                                      {'CLASS',3,'Color','g'},...
%                                      {'CLASS',6,'Color','b'},...
%                                      {'Default','Color','k'});
%   mapshow(roads,'SymbolSpec',roadColors);
%
%   Example 3 
%   ---------
%   % Using a Range of Attribute Values
%   lineStyle = makesymbolspec('Line',{'CLASS',[1 3],'LineStyle','-.'},...
%                                     {'CLASS',[4 6],'LineStyle',':'});
%   mapshow(roads,'SymbolSpec',lineStyle);
%
%   Example 4 
%   ---------
%   % Using a Range of Attribute Values and a Range of Property Values
%   colorRange = makesymbolspec('Line',{'CLASS',[1 6],'Color',summer(10)});
%   mapshow(roads,'SymbolSpec',colorRange);
%
%   See also: MAPSHOW, MAPVIEW, UPDATEGEOSTRUCT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:28 $

%   The output structure (the Symbol Spec) is a "datatype" that will be
%   used as input into other (MathWorks developed) functions or into the
%   Map Viewer.  It is expected that users will always use MAKESYMBOLSPEC
%   to create the Symbol Spec, that they won't rely on it as input into
%   their own functions, and therefore the structure can be changed from
%   release to release without breaking backwards compatibility.  It
%   currently has the following form:
%
%   spec.ShapeType = ShapeType
%   spec.(HGPropertyName) = {AttributeName, AttributeValue, HGPropertyValue}
%   spec.(HGPropertyName) = {'Default','',HGPropertyValue}

checkinput(Geometry,'char','nonempty',mfilename,'GEOMETRY',1);
symbolspec.ShapeType = getGeometry(Geometry);
checkrules(varargin{:});

defaultStrs = {};
for i=1:length(varargin)
  rule = varargin{i};
  if isdefault(rule) 
    for j=2:2:length(rule)
      if isfield(symbolspec,rule{j})
        symbolspec.(rule{j}) = cat(1,symbolspec.(rule{j}),{'Default','',rule{j+1}});
      else
        symbolspec.(rule{j}) = {'Default','',rule{j+1}};
      end
      if strmatch(lower(rule{j}),defaultStrs,'exact')
        eid = sprintf('%s:%s:defaultRuleSet', getcomp, mfilename);
        msg = sprintf('%s','The default rule for property, ''', ...
                           rule{j}, ''', has already been set.');
        error(eid, '%s', msg);
      end
      defaultStrs{end+1} = lower(rule{j});
    end
  else
    for j=3:2:length(rule)
      if isfield(symbolspec,rule{j})
        symbolspec.(rule{j}) = cat(1,symbolspec.(rule{j}),rule([1 2 j+1]));
      else
        symbolspec.(rule{j}) = rule([1 2 j+1]);
      end
    end
  end
end
checkSymbolSpec(symbolspec);

%----------------------------------------------------------------------
function checkSymbolSpec(symbolspec)
% Check and verify the symbolspec

fnames = fieldnames(symbolspec);
if length(fnames) <= 1
  eid = sprintf('%s:%s:noRule', getcomp, mfilename);
  msg = 'The SymbolSpec does not contain any valid rules.';
  error(eid, '%s', msg);
end

pointProperties   = {'marker','color','markeredgecolor','markerfacecolor', ...
                     'markersize','visible'};
lineProperties    = {'color','linestyle','linewidth','visible'};
polygonProperties = {'facecolor','facealpha','edgealpha','linestyle', ...
                     'linewidth','edgecolor','visible'};

idx = strmatch('shapetype',lower(fnames),'exact');
if ~isempty(idx)
  geometry = lower(symbolspec.(fnames{idx}));
  fnames(idx) = [];
else
  eid = sprintf('%s:%s:internalErrror', getcomp, mfilename);
  msg = 'The SymbolSpec does not contain fieldname ''ShapeType''.';
  error(eid, '%s', msg);
end

switch geometry
  case 'point'
    properties = pointProperties;
    geometry = 'point or multipoint';
  case 'line'
    properties = lineProperties;
  case 'polygon'
    properties = polygonProperties;
    geometry = 'polygon or patch';
end

for i=1:length(fnames)
  idx = strmatch(lower(fnames{i}),properties,'exact');
  if isempty(idx)
    eid = sprintf('%s:%s:invalidProperty', getcomp, mfilename);
    msg = sprintf('%s%s%s%s%s', 'The property, ''', fnames{i}, ...
                  ''', is invalid for ', geometry, ' geometry.');
    error(eid, '%s', msg);
  end
end

%----------------------------------------------------------------------
function b = isdefault(rule)
% Return true if 'Default' is in the command line inputs.

b = false;
if strcmp(lower(rule{1}),'default')
  b = true;
end
    
%----------------------------------------------------------------------
function geometry = getGeometry(type)
% Verify and obtain the type of Geometry.

switch lower(type)
 case {'line','polyline'}
  geometry = 'Line';
 case {'point','multipoint'}
  geometry = 'Point';
 case {'polygon','patch'}
  geometry = 'Polygon';
 otherwise
  eid = sprintf('%s:%s:invalidGeometry', getcomp, mfilename);
  msg = sprintf('%s\n%s', 'Geometry must be either ''Point'', ''MultiPoint'',', ...
                          '''Line'',  ''Polygon'', or ''Patch''.');
  error(eid, '%s', msg);
end

%----------------------------------------------------------------------
function checkrules(varargin)
% Verify the symbolspec rule

for i=1:length(varargin)
  rule = varargin{i};
  if ~iscell(rule)
    eid = sprintf('%s:%s:ruleNotCell', getcomp, mfilename);
    msg = sprintf('%s%i%s\n%s','RULE number ',i,' is invalid.', ...
                               'RULE must be a cell array.');
    error(eid, '%s', msg);
  end

  if isempty(rule)
    eid = sprintf('%s:%s:ruleIsEmpty', getcomp, mfilename);
    msg = sprintf('%s%i%s\n%s','RULE number ',i,' is invalid.', ...
                                'A RULE must be defined.');
    error(eid, '%s', msg);
  end

  if ischar(rule{1}) && strcmp(lower(rule{1}),'default')
    % ('Default', ..., PropertyNameN, PropertyValueN, ...)
    if ~rem(length(rule),2) 
      % Default Rule, requires odd number of inputs
      eid = sprintf('%s:%s:defaultRuleNotOdd', getcomp, mfilename);
      msg = sprintf('%s%i%s\n%s\n%s', ...
                    'RULE number,',i,' is invalid. ', ...
                    'The first element is ''Default'' ', ...
                    'but an even number of PropertyN and ValueN pairs are not present.');
      error(eid, '%s', msg);
    end

    if numel(rule) == 1 
      eid = sprintf('%s:%s:emptyDefaultRule', getcomp, mfilename);
      msg = sprintf('%s%i%s\n%s\n%s', ...
                    'RULE number,',i,' is invalid. ', ...
                    'The first element is ''Default'' ', ...
                    'but PropertyN and ValueN are not present.');
      error(eid, '%s', msg);
    end
    checkParamValuePairs(rule{2:end});

  else 
    % (AttributeName, AttributeValue, ..., PropertyNameN, PropertyValueN, ...)
    if numel(rule) < 4
      eid = sprintf('%s:%s:invalidNumel', getcomp, mfilename);
      msg = sprintf('%s%i%s\n%s','RULE number ',i,' is invalid.', ...
            'An Attribute Name/Value pair must preceede a Property Name/Value pair');
      error(eid, '%s', msg);
    end

    if ~ischar(rule{1})
      eid = sprintf('%s:%s:badAttributeName', getcomp, mfilename);
      msg = sprintf('%s%i%s\n%s','RULE number ',i,' is invalid.', ...
          'The AttributeName must be a character string.');
      error(eid, '%s', msg);
    end

    if isstruct(rule{2}) || (numel(rule{2}) > 2) && ~ischar(rule{2})
      eid = sprintf('%s:%s:badAttributeValue', getcomp, mfilename);
      msg = sprintf('%s%i%s\n%s\n%s','RULE number ',i,' is invalid.', ...
          'The AttributeValue must be a single number or character string,', ...
          'or a 2 element numeric array.');
      error(eid, '%s', msg);
    end
    checkParamValuePairs(rule{1:end});
  end

end

%----------------------------------------------------------------------
function checkParamValuePairs(varargin)
% Verify the inputs are in 'Parameter', value pairs syntax form,
%  by checking for pairs (even) and a string first pair. 

pairs = varargin;
if length(pairs) > 0
  if rem(length(pairs),2)
    eid = sprintf('%s:%s:invalidPairs', getcomp, mfilename);
    msg = sprintf('The PropertyN and ValueN inputs must always occur as pairs.');
    error(eid, '%s',msg)
  end
  params = pairs(1:2:end);
  for i=1:length(params)
    if ~ischar(params{i})
      eid = sprintf('%s:%s:invalidPropString', getcomp, mfilename);
      msg = sprintf('The PropertyN and ValueN pairs must be a string followed by value.');
      error(eid, '%s',msg)
    end
  end
end
