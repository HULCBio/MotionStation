function display(sys)
%DISPLAY   Pretty-print for LTI models.
%
%   DISPLAY(SYS) is invoked by typing SYS followed
%   by a carriage return.  DISPLAY produces a custom
%   display for each type of LTI model SYS.
%
%   See also LTIMODELS.

%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.14 $  $Date: 2002/04/10 06:18:03 $

maxCols = 80;

sysName = inputname(1);
if isempty(sysName)
   sysName = 'ans';
end

freq = sys.Frequency;
Ts = getst(sys.lti);  % sampling time
StaticFlag = isstatic(sys);

sizes = size(sys.ResponseData);
sizes(3:min(3,end)) = [];  % ignore frequency dimension

% Handle empty cases
if isempty(sys.ResponseData)
   disp('Empty frequency response model.')
   return
else   
   % I/O channel names
   inputNames = get(sys.lti,'InputName');
   outputNames = get(sys.lti,'OutputName');
   for inputIndex = 1:sizes(2)
      if isempty(inputNames{inputIndex})
         inputNames{inputIndex} = sprintf('input %d',inputIndex);
      else
         inputNames{inputIndex} = sprintf('input ''%s''',inputNames{inputIndex});
      end
   end
   for outputIndex = 1:sizes(1)
      if isempty(outputNames{outputIndex})
         outputNames{outputIndex} = sprintf('output %d',outputIndex);
      end
   end
   
   [fCol,fColWidth] = colPrint(freq,sprintf('Frequency(%s)',sys.Units));
   colSpace = repmat(' ',[size(fCol,1),1]);
   
   % set up array indices for display purposes
   arraySizes = [sizes(3:end) repmat(1,[1,length(sizes)==3])];
   nsys = prod(arraySizes);
   if nsys>1
      arrayIndices = zeros(nsys,length(arraySizes));
      for arrayDimension = 1:length(arraySizes)
         indexEntries = 1:arraySizes(arrayDimension);
         indexColumn = repmat(indexEntries,[prod(arraySizes(1:arrayDimension-1)) 1]);
         indexColumn = indexColumn(:);
         arrayIndices(:,arrayDimension) = ...
            repmat(indexColumn,[nsys/length(indexColumn) 1]);
      end
   end
   
   for arrayIndex = 1:nsys
      if nsys>1
         % display LTI array indices
         arrayHeader = sprintf('%d,',arrayIndices(arrayIndex,:));
         arrayHeader = sprintf('Model %s(:,:,%s)',sysName,arrayHeader(1:end-1));
         disp(sprintf('\n%s',arrayHeader));
         disp(repmat('=',[1 length(arrayHeader)]));
      end
      for inputIndex = 1:sizes(2)
         col = [colSpace colSpace fCol colSpace];
         colWidth = fColWidth + 3;
         header = sprintf('\n%sFrom %s to:\n',repmat('  ',[1 nsys>1]), ...
            inputNames{inputIndex});
         for outputIndex = 1:sizes(1)
            [newCol,newWidth] = ...
               colPrint(sys.ResponseData(outputIndex,inputIndex,:,arrayIndex), ...
               outputNames{outputIndex});
            if (colWidth+newWidth+1>maxCols) | (newWidth+fColWidth+1) > maxCols
               disp(header);
               disp(col);
               col = [fCol colSpace];
               colWidth = fColWidth + 1;
            end
            col = [col colSpace newCol];
            colWidth = colWidth+newWidth+1;
         end % outputIndex
         if colWidth > fColWidth+1  % col includes response data
            disp(header);
            disp(col);
         end
      end % inputIndex
      disp(' ');
      dispdelay(sys.lti,arrayIndex,repmat('  ',[1 nsys>1]));
   end % LTI Array indices
   disp(' ');
   % Display LTI properties (I/O groups, sample time)
   dispprop(sys.lti,StaticFlag);
end

if nsys>1  % FRD array
   ArrayDims = sprintf('%dx',arraySizes);
   if Ts==0
      ArrayType = 'continuous-time frequency response data models';
   else
      ArrayType = 'discrete-time frequency response data models';
   end
   disp(sprintf('%s array of %s.',ArrayDims(1:end-1),ArrayType));
else % single model
   if Ts==0
      disp('Continuous-time frequency response data model.');
   else
      disp('Discrete-time frequency response data model.');
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [column,colWidth] = colPrint(vector,title)
% Return character matrix COLUMN for display using TITLE as a header

if isempty(vector)
   column = '';
   
elseif ischar(vector)
   column = vector;
   
else
   
   vector = vector(:);
   sizes = size(vector);
   
   % constants
   realSignList = '-  ';
   imagSignList = '- +';
   
   realVector = real(vector);
   imagVector = imag(vector);
   
   if ~any(realVector)
      realColumn = repmat('0',[sizes(1) 1]);
   else
      realSigns = repmat(' ',[length(realVector),1]);
      realSigns(~isnan(realVector)) = realSignList(sign(realVector(~isnan(realVector))) + 2)';
      realSigns(isnan(realVector)) = ' ';
      realColumn = alignDecimal(abs(realVector));  % align decimals      
      realColumn = [realSigns realColumn];  % combine signs and numbers
   end
   
   if ~any(imagVector)
      imagColumn = repmat(' ',[sizes(1) 0]);
   else
      imagSigns = imagSignList(sign(imagVector) + 2)';  % determine signs
      imagSigns(isnan(imagVector)) = ' ';
      % align decimals, adding i's only for non-zero entries
      imagColumn = alignDecimal(abs(imagVector),'i',1);
      imagEs = (imagColumn=='e') | (imagColumn=='E');
      if any(imagEs(:))
         imagSigns = [ repmat(' ',[length(imagSigns) 1]) ...
               imagSigns repmat(' ',[length(imagSigns) 1]) ];
      end
      imagColumn = [imagSigns imagColumn];  % combine signs, numbers
   end
   
   % concatenate real and imag columns
   column = [realColumn imagColumn];
   
end

% add title above column
colSize = size(column);
title = [title; repmat('-',[1 size(title,2)])]; % add -------
titleSize = size(title);
if titleSize(2) > colSize(2)
   leading = ceil((titleSize(2) - colSize(2))/2);
   trailing = floor((titleSize(2) - colSize(2))/2);
   column = [repmat(' ',[colSize(1) leading]) ...
         column repmat(' ',[colSize(1) trailing])];
elseif titleSize(2) < colSize(2)
   leading = ceil((colSize(2) - titleSize(2))/2);
   trailing = floor((colSize(2) - titleSize(2))/2);
   title = [repmat(' ',[titleSize(1) leading]) ...
         title repmat(' ',[titleSize(1) trailing])];
end
column = [title; column];
   
colWidth = size(column,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function charMatrix = alignDecimal(vector,extra,supressZeros)
% take a vector of numbers, and an 'extra' string
% return the character matrix of numbers with the decimal points aligned,
% and the 'extra' string appended to each line.
% Set supressZeros to 1 to fill with blanks(not '0') for zero entries, and
% supress display of the 'extra' string.

if nargin == 1
   extra = '';
   supressZeros = 0;
elseif nargin == 2
   supressZeros = 0;
end

vector = vector(:);

floatMin = 1e-6;
floatMax = 1e6;
maxRatio = 1e6;

finiteVector = vector(isfinite(vector));
charCells = cell(length(vector),1);

if isempty(finiteVector) ...  % exponential format
      | min(finiteVector(finiteVector~=0))<floatMin ...
      | max(finiteVector)>floatMax ...
      | max(finiteVector)/min(finiteVector(finiteVector~=0))>maxRatio
   
   charString = sprintf('%e\n',vector);
   returns = [0 find(charString==sprintf('\n'))];
   for lineIndex = 1:length(returns)-1
      charCells{lineIndex} = ...
         charString(returns(lineIndex)+1:returns(lineIndex+1)-1);
   end
   charMatrix = char(charCells);
   lastAbs = findstr(charMatrix(1,:),'e')-1;
   while ~isempty(lastAbs) & all(charMatrix(:,lastAbs)=='0' & charMatrix(:,lastAbs-1)~='.')
      charMatrix(:,lastAbs)='';
      lastAbs = lastAbs-1;
   end
   charMatrix(vector>=1&vector<10,lastAbs+1:end) = ' '; % remove '000' exponent
   charMatrix(vector==0,2:end) = ' '; % display true zero as '0'
   
elseif floor(finiteVector)==finiteVector  % integer format
   charString = sprintf('%d\n',vector);
   returns = [0 find(charString==sprintf('\n'))];
   for lineIndex = 1:length(returns)-1
      charCells{lineIndex} = ...
         charString(returns(lineIndex)+1:returns(lineIndex+1)-1);
   end
   charMatrix = strjust(char(charCells),'right');
   
else  % floating point format
   charString = sprintf('%f\n',vector);
   returns = [0 find(charString==sprintf('\n'))];
   decimalPoints = find(charString=='.' ...
      | charString=='a' ... % set 'decimal' at center of 'NaN'
      | charString=='n'); % set 'decimal' at center of 'Inf'
   leadingDigits = decimalPoints - returns(1:end-1) - 1;
   leadingPlaces = max(leadingDigits);
   for lineIndex = 1:length(returns)-1
      thisEntry = charString(returns(lineIndex)+1:returns(lineIndex+1)-1);
      frontPadding = repmat('*',[1 leadingPlaces-leadingDigits(lineIndex)]);
      charCells{lineIndex} = [frontPadding thisEntry];
   end
   charMatrix = strjust(char(charCells),'left');
   charMatrix(charMatrix=='*') = ' ';  % replace marker with space
   % remove trailing zeros
   while all(charMatrix(:,end)=='0')
      charMatrix(:,end)='';
   end
   % display true zero as '0'
   charMatrix(vector==0,decimalPoints(1):end)=' ';
   
   
end

% add extra characters
charMatrix = [charMatrix repmat(extra,[lineIndex 1])];

if supressZeros
   charMatrix(~vector,:) = ' ';
end

