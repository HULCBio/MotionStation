function [maskdisplay, OutputDataTypes, format] = masciidecode(flag, format, nvars, vartypes, direction)

% masciidecode -- Prepare variables for the call to the decode S function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2003/01/22 20:19:03 $

dtypeout = [];

OutputDataTypes = [];

%Setup and check output ports data types
  
if isempty(OutputDataTypes)
  OutputDataTypes = 0;
end

if ~(length( vartypes ) == 0 || length( vartypes ) == 1 || length( vartypes ) == nvars )
  error('The number of output data types must be empty (default type double assumed), a scalar (scalar expension applies) or a row vector with the same number of element as the output ports');
end

if length( vartypes ) == 0
  vartypes = { 'double' };
end

if direction == 1  % decode
  maskdisplay= 'disp( ''ASCII\nDecode'');port_label(''input'',1,''D'');';

  for i=1:nvars
    maskdisplay=[maskdisplay,'port_label(''output'',',num2str(i),',''',num2str(i),''');'];
  end 

else  % encode
  maskdisplay= 'disp( ''ASCII\nEncode'');port_label(''output'',1,''D'');';

  for i=1:nvars
    maskdisplay=[maskdisplay,'port_label(''input'',',num2str(i),',''',num2str(i),''');'];
  end 
end

format = replace_escapes(format);

%Setup data types
dtypeout = zeros(1,nvars);
dtypee = vartypes{1};  % first type, use this one if there is only 1.
for j = 1:nvars
  if length( vartypes ) == nvars
    dtypee = vartypes{j};  % use the j'th type if present
  end
  if ~isa(dtypee,'char')
    error('the elements of the data type argument must be strings');
  end
  % NOTE: these values need to match the BuiltInDTypeId enum in simstruc_types.h
  if strcmp(dtypee,'double')
    dtypeout(j) = 0;  % SS_DOUBLE
  elseif strcmp(dtypee,'int8')
    dtypeout(j) = 2;  % SS_INT8
  elseif strcmp(dtypee,'uint8')
    dtypeout(j) = 3;  % SS_UINT8
  elseif strcmp(dtypee,'int16')
    dtypeout(j) = 4;  % SS_INT16
  elseif strcmp(dtypee,'uint16')
    dtypeout(j) = 5;  % SS_UINT16
  elseif strcmp(dtypee,'int32')
    dtypeout(j) = 6;  % SS_INT32
  elseif strcmp(dtypee,'uint32')
    dtypeout(j) = 7;  % SS_UINT32
  else
    error('the supported data types are: double, int8, uint8, int16, uint16, int32 and uint32');
  end
end

OutputDataTypes = dtypeout;

return;

  
function output=replace_escapes(input)

tokens={'\\','\a','\b','\f','\r','\t','\v','\''','\"','\n'};
output=input;

for i=1:length(tokens)
  if strcmp(tokens{i},'\\')
    j = 1;
    m = length(input);
    while j < m
      if output(j) == char(92) & output(j+1) == char(92)
        output(j) = char(200);
        if (j+2) <= m 
          output(j+1:m-1) = output(j+2:m);
        end
        output(m) = char(0);
        m = m - 1;
      end
      j = j + 1;
    end
  else
    output=strrep(output,tokens{i},sprintf(tokens{i}));
  end
end

for i = 1:length(output)
  if output(i) == char(200)
    output(i) = abs(sprintf('\\'));
  end
end

