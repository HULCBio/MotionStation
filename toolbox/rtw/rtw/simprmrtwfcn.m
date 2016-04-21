function varargout = simprmrtwfcn( varargin )
% SIMPRMRTWFCN - This functions is the composition of functions
% that are related to the real-time workshop part of the Simulation
% Parameters dialog, aka SIMPRM dialog. 
%
% See also SIMPRM.
%
%  Copyright 1994-2003 The MathWorks, Inc.
%  $Revision: 1.8.4.3 $

if nargin < 1
  error('Invalid call to function SIMPRMRTWFCN.');
else
  fcn = varargin{1};
end

switch ( lower(fcn) )
 
 case 'getrtwoptions'
  if nargin > 3
    error('Invalid call.');
  else
    modelName = varargin{2};
    editedSTF = [];  % the system target file name on simprm dialog
    if nargin == 3
      editedSTF = varargin{3};
    end
  end
  
  % get the common code generation options first
  commonOptions = rtwcommonoptions;

  options = getrtwoptions( modelName, editedSTF, commonOptions );

  % get the TargetProperties from the model
  try
    TargetProperties = get_param(modelName,'TargetProperties');
  catch
    TargetProperties = [];
    lasterr('');
  end

  if ~isempty(TargetProperties)
    myLastErr = lasterr;
    try
      addOptions = TargetProperties.GetCategory;
      options = [options addOptions];
    catch
      lasterr(myLastErr);
    end
  end

  varargout = { options };

 case 'commonoptions'
  if nargin > 1
    error('Invalid call.');
  end

  commonOptions = rtwcommonoptions;
  varargout = { commonOptions };
  
 case 'syncstruct'
  if nargin ~= 4
    error('Invalid call.');
  end
  
  array1   = varargin{2};
  array2   = varargin{3};
  keyfield = varargin{4};
  outputStruct = combinestruct(array1, array2, keyfield);
  varargout = { outputStruct };
  
 case 'struct2optarr'
  if nargin ~= 2
    error('Invalid call.');
  end
  
  rtwOptions = varargin{2};
  propValPairs = struct_optstr(optarr_struct(rtwOptions));
  
  varargout = { propValPairs };
  
 otherwise
  error('Invalid call to function GETRTWOPTIONS.');
end

% end of simprmrtwfcn


%******************************************************************************
% Function - Merge common options and system target file specific options.
%******************************************************************************
function rtwoptions = getrtwoptions(modelName, editedSTF, commonOptions)

hmodel   = get_param(modelName, 'handle');

%
% Modularize rtwoption collection and building
%
optionsTargetFile = getstfOptions(hmodel, editedSTF);

% combine the common options and target specific options together
combinedOptions = ...
    combinestruct(commonOptions, optionsTargetFile, 'tlcvariable');

% get the 'RTWOptions' from the model parameter
rtwOptions = get_param(hmodel, 'RTWOptions');

if ~isempty(rtwOptions)
  % convert the string of the 'RTWOptions' into a structure array
  rtwOptionsArray = optstr_struct(rtwOptions);

  % synchronize the rtw options value
  rtwoptions = LocalRTWStuffArray(combinedOptions, rtwOptionsArray, ...
				  {'tlcvariable', 'name'}, ...
				  {'default', 'value', 'MapFcn'}, ...
				  {'enable', 'enable', 'Passthru'});
  
else
  % This is a new model and we should put the 
  % common options into it.
  rtwoptions = combinedOptions;
end

%end getrtwoptions()



%******************************************************************************
% Function - 
% Copies the field values of one array to another array.  The description
% of the original RTWStuffArray is:
% RTWStuffArray(array1, array2, {primary_key, secondary_key}, ...
%                {field1, field1a}, {field2, field2a}, ...)
% results in the following:
% All cases where array1(i).primary_key == array2(j).secondary_key,
%   array1(i).field1 <-- array2(j).field1a
%   array1(i).field2 <-- array2(j).field2a
%                     .
%                     .
%                     .
% Example:
%  arr1(1).a = 'a';
%  arr1(1).b = 'b';
%  arr1(1).c = 'c';
%  arr1(2).a = 'a2';                  
%  arr1(2).b = 'b2';
%  arr1(2).c = 'c2';
%
%  arr2(1).d = 'a2';
%  arr2(1).e = 'e';
%  arr2(1).f = 'f';
%  arr2(2).d = 'a'; 
%  arr2(2).e = 'e2';
%  arr2(2).f = 'f2';
%  RTWStuffArray(arr1, arr2, {'a', 'd'}, {'b', 'e'})
%    would result in 
%  arr1(1).a,b,c = {'a', 'e2', 'c'}
%  arr1(2).a,b,c = {'a2', 'e', 'c2'}
% 
% This function extends RTWStuffArray in the following way:
% LocalRTWStuffArray(array1, array2, {primary_key, secondary_key}, ...
%                   {field1, field1a, mapfcn1}, {field2, field2a, mapfcn2}, ...)
% results in the following:
% All cases where array1(i).primary_key == array2(j).secondary_key,
%   array1(i).field1 <-- mapfcn1(array1(i), array2(j), array2(j).field1a)
%   array1(i).field2 <-- mapfcn2(array1(i), array2(j), array2(j).field2a)
%******************************************************************************
function output = LocalRTWStuffArray(varargin)

if nargin < 4
  error(['Need at least four arguments: Primary Array, Secondary' ...
	 ' Array, Key Fields, and Secondary Fields']);
end

array1 = varargin{1};
array2 = varargin{2};

% Not sure about the following behavior for empty arrays. May need to
% change it.
if (isempty(array1))
  output = array1;
  return;
elseif (isempty(array2))
  output = array2;
  return;
end

if (~(isstruct(array1) & isstruct(array2)))
  error(['Both the primary and secondary arrays must be struct arrays']);
end

keyPair = varargin{3};
if (~(iscell(keyPair) & (length(keyPair) == 2)))
  error(['The key fields must be a cell struct with two elements']);
end

primaryKey = keyPair{1};
secondaryKey = keyPair{2};

if (~isfield(array1, char(primaryKey)))
  error([primaryKey ' is not a field in the primary array.']);
elseif (~isfield(array2, char(secondaryKey)))
  error([secondaryKey ' is not a field in the secondary array.']);
end

% Do some more error checking.
for k = 4:length(varargin)
  fieldPair = varargin{k};
  if (isequal(fieldPair{1}, primaryKey))
    error(['A field being replaced,' fieldPair{1}, ' has the same name', ...
	    ' as the primary key field, ' primaryKey '.']);
  elseif (isequal(fieldPair{2}, secondaryKey))
    error(['A field being used for replacement,' fieldPair{2}, ' has', ...
	    ' the same name as the primary key field, ' secondaryKey '.']);
  end
end

for k = 1:length(array1)
  key1val = getfield(array1(k), primaryKey);
  for l = 1:length(array2)
    key2val = getfield(array2(l), secondaryKey);
    if (isequal(key1val, ...
		 key2val))
      
      for j = 4:length(varargin)
	fieldPair = varargin{j};
	primaryField = fieldPair{1};
	secondaryField = fieldPair{2};
	mapFcn = fieldPair{3};
	
	secondaryValue = getfield(array2(l), secondaryField);
	eval(['array1(k).' char(primaryField) '= ' mapFcn '(array1(k),' ...
	      ' array2(l), char(secondaryValue));']);
      end
    end
  end
end
output = array1;

%end LocalRTWStuffArray


function output = MapFcn(record1, record2, value)
if (isfield(record1,'type') & ~isempty(record1.type))
  switch(record1.type)
   case 'Popup'
    % Strip all quotation marks from the value fields (presumably inserted
    % for a popup)
    output = strrep(value, '"', '');
    return;
   case 'Edit'
    % Strip all quotation marks from the value fields (presumably inserted
    % for an edit string)
    output = strrep(value, '"', '');
    return;
   case 'Checkbox'
    if (isequal(value,'1'))
      output = 'on';
    else
      output = 'off';
    end
   otherwise
    output = value;
  end
else
  output = value;
end

function output = Passthru(record1, record2, value)
output = value;

function TargetFileOptions = getstfOptions(hmodel, editedSTF)
[systemTargetFileName,systemTargetFileId,prevfpos] = getstf(hmodel, editedSTF);
if (systemTargetFileId == -1)
  warningState = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  if isempty(systemTargetFileName)
    warningMsg = (['Unable to locate system target file: ', editedSTF]);
  else
    warningMsg = (['Unable to locate system target file: ', ...
		  systemTargetFileName]);
  end
  warning(warningMsg);
  warning(warningState);
  TargetFileOptions = [];
else
  % Get code generation options from the existing system target file.
  TargetFileOptions = tfile_optarr(systemTargetFileId);

  closestf(systemTargetFileId, prevfpos);
end

% [eof] rtwoptionsdlg.m





