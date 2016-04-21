function tc = readstdtcdata(filename)
%READSTDTCDATA read NIST STD DB 60 ITS-90 thermocouple data file
%
% synopsis:
%
%   tc = readstdtcdata('all.tab');
%
% This function reads all the table data and polynomial 
% coefficient data from the official NIST ITS-90 thermocouple
% database file.  NIST thermocouple database files can be 
% downloaded from:
%
%   http://srdata.nist.gov/its90/download/download.html
%
% To get all the data, you only need to download this file:
%
%   all.tab
%
% Individual data is also available at the above URL.  If the URL
% no longer works, please contact support@mathworks.com for updated
% information.  (URL current as of 05 Feb 2004).  
%
% Units are degrees Celsius for temperature and millivolts for voltage.
% Purely repeated entries at 0 degC are removed.
%
% Data is returned in an array of structures.  Each structure contains
% data for one type of thermocouple and has the following fields:
%
%          Type: 'B'
%         TData: [1821x1 double]
%         VData: [1821x1 double]
%      numCoefs: {[7]  [9]}
%    coefsRange: {[0 6.306150000000000e+02]  [6.306150000000000e+02 1820]}
%         coefs: {[7x1 double]  [9x1 double]}
%      expCoefs: []
%      invCoefs: {[9x1 double]  [9x1 double]}
%      invRange: []
%
%
% The polynomial coefficients and inverse coefficients are flipped by
% this routine to be compatible with MATLAB polyval() ordering.
%
% file format keys:
%   a line with * as the first non-white character is a comment
%   a line beginning with °C is a scale line
%     a scale line can increase to the right or decrease (!)
%     the first (or odd) one starts a table segment
%     the second (or even) ones end a table segment
%   a line beginning with ITS-90 Table is a table segment header
%   a line with Thermoelectric Voltage in mV is a units line
%   a data line begins with a temperature number and has >=1 emf entries
%
%   a line beginning with: 
%          name: is the beginning of a polynomial section (fwd or inv)
%          type: is the t/c type letter
%     emf units: gives the output units
%         range: has a beginning, an end, and the order of the polynomial
%                there can be multiple range sections, vertically stacked
%   exponential: (optional) gives coefficients for the exponential
%                "Inverse coefficients" - header for the inverse polynomial
%   			 "Temperature" - beginning of an inverse poly T range
%         Range: end of an inverse poly range for temp, volts, or error
%       Voltage: beginning of an inverse poly volts range
%
% NOTE: multiple columns indicate multiple ranges, range goes vertically
%
% A line beginning with a number below an inverse polynomial declaration 
% is a line of inverse data
%
% Error is the beginning  of an inverse poly voltage error
%
% an inverse polynomial declaration ends on a new table header (ITS-90 Table...) or EOF  
%
% a BLANK line (all whitespace) is ignored
%
%
% Assertions: 
%    table type, coefs, and inverse coefs do not mix
%

% roa 05 Feb 2004
% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $

tc = [];

% --- Open ITS-90 text/data file

f = fopen(filename); 
if (f < 0),
  error('File ''%d'' not found', filename);
end

state    = 'enter';
substate = '';

while ~feof(f)

  line = fgetl(f);

  % --- find type of line - check for comments before all else!

  if feof(f),
    lineType = 'EOF';
    
  elseif isempty(strtok(line)),
    lineType = 'blank';
    
  elseif line(1) == '*',
    lineType = 'comment';
    
  elseif ~isempty(strfind(line, 'ITS-90 Table')),
    lineType = 'tabHeader';
    
  elseif strcmp(strtok(line), '°C'),
    lineType = 'tabScale';
    
  elseif ~isempty(strfind(line, 'Thermoelectric Voltage in mV')),
    lineType = 'tabUnits';
    
  elseif ~isempty(strfind(line, 'name:')),
    lineType = 'cName';
    
  elseif ~isempty(strfind(line, 'type:')),
    lineType = 'cType';
    
  elseif ~isempty(strfind(line, 'temperature units:')),
    lineType = 'cTUnits';
    
  elseif ~isempty(strfind(line, 'emf units:')),
    lineType = 'cVUnits';
    
  elseif ~isempty(strfind(line, 'range:')),
    lineType = 'cRange';
    
  elseif ~isempty(strfind(line, 'exponential:')),
    lineType = 'cExponent';
    
  elseif ~isempty(strfind(line, 'Inverse coefficients for type')),
    lineType = 'iHead';
    
  elseif ~isempty(strfind(line, 'Temperature')),
    lineType = 'iTemp';
    
  elseif ~isempty(strfind(line, 'Voltage')),
    lineType = 'iVolts';
    
  elseif ~isempty(strfind(line, 'Error')),
    lineType = 'iError';
    
  elseif ~isempty(strfind(line, 'Range:')),
    lineType = 'iRange';
    
  elseif ~isempty(strfind(line, '=')) && strcmp(line(1:2),' a'),
    lineType = 'cEData';
        
  else
    %
    % --- must be some kind of data line or maybe a corrupt file
    %
    
    numbers = str2num(line);
    if ~isempty(numbers) && isnumeric(numbers),
      lineType = 'data';
    else
      lineType = 'unknown';
    end
    
  end

  
  % --- Process reader state

  if ~( strcmp(lineType, 'blank') || strcmp(lineType, 'comment') ),
    switch state
      case 'EOF'
        disp(sprintf('EOF encountered'));
        continue;
      case 'enter'
        if strcmp(lineType, 'tabHeader'),
          state = 'newTabHeader';
          %
          % --- initialize data structure
          %
          tcdata = locInitTCData;
        else
          state = 'lost';
        end
      case 'newTabHeader'
        if strcmp(lineType, 'tabScale'),
          state = 'tabScale';
        else
          state = 'lost';
        end
      case 'tabHeader'
        if strcmp(lineType, 'tabScale'),
          state = 'tabScale';
        else
          state = 'lost';
        end
      case 'tabScale'
        if strcmp(lineType, 'tabHeader'),
          state = 'tabHeader';
        elseif strcmp(lineType, 'tabUnits'),
          state = 'tabUnits';
        elseif strcmp(lineType, 'cName'),
          state = 'cName';
        else
          state = 'lost';
        end
      case 'tabUnits'
        if strcmp(lineType, 'data'),
          state = 'tabData';
        else
          state = 'lost';
        end
      case 'tabData'
        if strcmp(lineType, 'data'),
          state = 'tabData';
        elseif strcmp(lineType, 'tabScale'),
          state = 'tabScale';  % xxx end of table section encountered?
        else
          state = 'lost';
        end
      case 'cName'
        if strcmp(lineType, 'cType'),
          state = 'cType';
        else
          state = 'lost';
        end
      case 'cType'
        if strcmp(lineType, 'cTUnits'),
          state = 'cTUnits';
        else
          state = 'lost';
        end
      case 'cTUnits'
        if strcmp(lineType, 'cVUnits'),
          state = 'cVUnits';
        else
          state = 'lost';
        end
      case 'cVUnits'
        if strcmp(lineType, 'cRange'),
          state = 'cRange';
        else
          state = 'lost';
        end
      case 'cRange'
        if strcmp(lineType, 'data'),
          state = 'cData';
        else
          state = 'lost';
        end
      case 'cData'
        if strcmp(lineType, 'data'),
          state = 'cData';
        elseif strcmp(lineType, 'cRange'),
          state = 'cRange';
        elseif strcmp(lineType, 'cExponent'),
          state = 'cExponent';
        elseif strcmp(lineType, 'iHead'),
          state = 'iHead';
        else
          state = 'lost';
        end
      case 'cExponent'
        if strcmp(lineType, 'cEData'),
          state = 'cEData';
        else
          state = 'lost';
        end
      case 'cEData'
        if strcmp(lineType, 'cEData'),
          state = 'cEData';
        elseif strcmp(lineType, 'cRange'),
          state = 'cRange';
        elseif strcmp(lineType, 'iHead'),
          state = 'iHead';
        else
          state = 'lost';
        end
      case 'iHead'
        if strcmp(lineType, 'iTemp'),
          state = 'iTemp';
        else
          state = 'lost';
        end
      case 'iTemp'
        if strcmp(lineType, 'iRange'),
          state    = 'iRange';
          substate = 'iTemp';
        else
          state = 'lost';
        end
      case 'iVolts'
        if strcmp(lineType, 'iRange'),
          state    = 'iRange';
          substate = 'iVolts';
        else
          state = 'lost';
        end
      case 'iError'
        if strcmp(lineType, 'iRange'),
          state    = 'iRange';
          substate = 'iError';
        elseif strcmp(lineType, 'EOF'),
          state = 'EOF';
        else
          state = 'lost';
        end
      case 'iRange'
        if strcmp(lineType, 'tabHeader'),
          state    = 'newTabHeader';  % only allowed after error range
          substate = '';
          % --- Adjust storage formats
          tcdata = removeDupZeros(tcdata);
          for k = 1:length(tcdata.coefs),
              tcdata.coefs{k} = flipud(tcdata.coefs{k});
          end
          for k = 1:length(tcdata.invCoefs),
              tcdata.invCoefs{k} = flipud(tcdata.invCoefs{k});
          end          

          % --- Completed a table read - save into structure & reset 
          tc = [ tc; tcdata ];
          tcdata = locInitTCData;
        elseif strcmp(lineType, 'iVolts'),
          state = 'iVolts';
        elseif strcmp(lineType, 'data'),          
          state = 'iData';
        elseif strcmp(lineType, 'EOF'),
          state = 'EOF';
        else
          state = 'lost';
        end
      case 'iData'
        if strcmp(lineType, 'data'),
          state = 'iData';
        elseif strcmp(lineType, 'iError'),
          state = 'iError';
        else
          state = 'lost';
        end
      otherwise
        state = 'lost';
    end

    
    % --- Extract data from the line

    if strcmp(state,'lost'),
      warning('Algorithm error: thermocouple file reader state inconsistent');
    end
    
    switch lineType
      case 'data'
        switch state
          case 'tabData'
            len = length(numbers);
            if len > 1,
              %
              % Only need 10 numbers, skip end number if there are 12 (a
              % repeat!)
              %
              last = min(11,len);
              newT = numbers(1) + currentScale(1:last-1)';
              newV = numbers(2:last)';
              if currentScale(2) < 0,
                newT = flipud(newT);
                newV = flipud(newV);
              end
              tcdata.TData = [tcdata.TData; newT ];
              tcdata.VData = [tcdata.VData; newV ];
            else
              error('invalid table data line encountered, >>%s<<', line);
            end
          case 'cData'
            % --- Handle multi-range case
            k = length(tcdata.numCoefs);
            if k > 0,
              len = length(tcdata.coefs);
              if len == 0,
                tcdata.coefs    = { numbers(1) };
              elseif len == k,
                tcdata.coefs(k) = { [ tcdata.coefs{k}; numbers(1) ] };
              elseif len < k,
                tcdata.coefs(k) = { numbers(1) };
              else
                error('reader is lost in polynomial coefficient section');
              end
            else
              error('cannot be reading coefficients before poly order is read');
            end
          case 'iData'
            if isempty(tcdata.invCoefs),
              for k= 1:length(numbers),
                tcdata.invCoefs(k) = { numbers(k) };
              end
            else
              for k= 1:length(numbers),
                tcdata.invCoefs(k) = { [ tcdata.invCoefs{k}; numbers(k) ] };
              end
            end
          otherwise
            error('unknown data type');
        end
        
      case 'tabHeader'
        pos = strfind(line, 'type');
        if ~isempty(pos),
          type = strtok(line(pos+4:end));
          if isempty(tcdata.Type),
            tcdata.Type = type;
          else
            if ~strcmp(tcdata.Type,type),
              error('Thermocouple type inconsistent, file corrupt?');
            end
          end
        else
          error('Thermocouple type not read from file header correctly');
        end
        
      case 'tabScale'
        currentScale = str2num(line(5:end));
        
      case 'tabUnits'
        % get the units for consistency
        
      case 'cName'
      case 'cType'
        % --- Extract the thermocouple type from the line
        coefType = strtok(line(6:end));
        if ~strcmp(tcdata.Type, coefType),
          error('Thermocouple type inconsistent or unknown, is the file corrupt?');
        end
      case 'cTUnits'
      case 'cVUnits'
      case 'cRange'
        numbers = str2num(line(7:end));
        if length(numbers) ~= 3,
          error('Need 3 numbers on coefficient range line, found %d', length(numbers));
        else
          if isempty( tcdata.coefsRange ),
            tcdata.coefsRange = { numbers(1:2)'  };
            tcdata.numCoefs   = { numbers(3) + 1 };
          else
            tcdata.coefsRange(end+1) = { numbers(1:2)'   };
            tcdata.numCoefs(end+1)   = {  numbers(3) + 1 };
          end
        end
      case 'cExponent',
        % do nothing
        
      case 'cEData',
        % Only Type K range 2 currently uses this for ITS-90
        numbers = str2num(line(7:end));
        k = str2num(line(3));
        m = length(tcdata.numCoefs);
        if isempty( tcdata.expCoefs ),
          tcdata.expCoefs(m) = { numbers };
        else
          tcdata.expCoefs(m) = { [ tcdata.expCoefs{m}; numbers ] };
        end          
      case 'iHead',
      case 'iTemp',
      case 'iRange',
        if strcmp(substate,'iVolts'),
          % Read the second line of voltage range for the inverse coefficients
          numbers = str2num(line(10:end));
          if isempty(tcdata.invRange),
            for k= 1:length(numbers),
              tcdata.invRange(k) = { numbers(k) };
            end
          else
            for k= 1:length(numbers),
              tcdata.invRange(k) = { [ tcdata.invRange{k}; numbers(k) ] };
            end
          end
        end
      case 'iVolts',
        % Read the beginning of the voltage range for the inverse coefficients
        numbers = str2num(line(10:end));
        if isempty(tcdata.invRange),
          for k= 1:length(numbers),
            tcdata.invRange(k) = { numbers(k) };
          end
        else
          for k = 1:length(numbers),
            tcdata.invRange(k) = { [ tcdata.invRange{k}; numbers(k) ] };
          end
        end
      case 'iError',
      case 'EOF',
        % --- adjust storage formats
        tcdata = removeDupZeros(tcdata);
        for k = 1:length(tcdata.coefs),
            tcdata.coefs{k} = flipud(tcdata.coefs{k});
        end
        for k = 1:length(tcdata.invCoefs),
            tcdata.invCoefs{k} = flipud(tcdata.invCoefs{k});
        end

        % --- add struct to array of structs
        tc     = [tc; tcdata];
      otherwise
        error('Thermocouple file read algorithm failure: unhandled line type encountered');
  end
  end

  
end


% --- clean up

fclose(f);

if strcmp(state,'EOF'),
  if isempty(tc),
    error('Algorithm error: exiting readstdtcdata() without setting return value');
  end
else
  error('Algorithm error:  exiting readstdtcdata() before end of file');
end


%endfunction readstdtcdata


% Function: initTCData =======================================================
%
%
function tcdata = locInitTCData()
%INITTCDATA returns an empty thermocouple data structure

tcdata.Type        = '';
tcdata.TData       = [];
tcdata.VData       = [];
tcdata.numCoefs    = {};
tcdata.coefsRange  = {};
tcdata.coefs       = {};
tcdata.expCoefs    = {};
tcdata.invCoefs    = {};
tcdata.invRange    = {};

%endfunction initTCData


% Function: removeDupZeros ===============================================
% Abstract:
%   The ITS-90 tables have 2 types of "duplicate" points:
%
%   1) "repeated" voltages with different temperature data due
%      to the X.XXX numeric format - this is an artifact of the table
%      and not the actual physical behavior, which should be
%      differentiable many, many times (down to quantum levels at least)
%   2) one repeated zero voltage data point when crossing 0 degC
%
%   This function removes duplicates for variety #2 by identifying
%   exact duplicates - this is OK since we are not performing operations
%   on the data so numerics do not come into play.
%
function tcdata = removeDupZeros(indata)
%REMOVEDUPZEROS remove repeated zero entries from table

% --- Find all zero voltage data points

tcdata = indata;
zIdx   = find(tcdata.TData == 0.0);

if length(zIdx) == 2 && tcdata.VData(zIdx(1)) == tcdata.VData(zIdx(2)),
        skip   = zIdx(2);
        numPts = length(tcdata.TData);
        keep   = [1:(skip-1),(skip+1):numPts];
        % --- remove second zero-entry from the arrays
        tcdata.TData = tcdata.TData( keep );
        tcdata.VData = tcdata.VData( keep );
end

%endfunction removeDupZeros



%[EOF] readstdtcdata.m
