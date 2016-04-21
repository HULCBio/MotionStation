function newVal = convertSampleTimeInfo(val)
% Converting sample time info between structure matrix and string format

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $

  newVal = [];
  errmsg = '';
  
  if isempty(val)
    return;
  end

  try
    if isstruct(val)
      newVal = '';
      for i = 1:length(val)
        newVal = sprintf('%s[%s,%s,%d];', newVal, val(i).SampleTime, ...
                         val(i).Offset, val(i).Priority);
      end
      newVal = ['[' newVal ']'];
      
    elseif isstr(val)

      i = 1;
      
      % remove trailing white spaces
      val = deblank(val);
      
      % Remove all trailing ';'
      while ~isempty(val) && isequal(val(end), ';')
        val(end) = ' ';
        val = deblank(val);
      end
 
      % Remove the last ']'
      if ~isequal(val(end), ']') || length(val) < 2
        errmsg = 'Input is not a valid Matlab array.';
        error(errmsg);
      end
      val = val(1:end-1);
      
      % remove trailing white spaces
      val = deblank(val);
      
      % remove leading white spaces
      val = fliplr(deblank(fliplr(val)));
      
      if ~isequal(val(1), '[') || length(val) < 2
        errmsg = 'Input is not a valid Matlab array.';
        error(errmsg);
      end
      
      val = val(2:end);
      i = 0;
      
      while ~isempty(val)
        i = i + 1;
        [T, R] = strtok(val, ';');
        
        % encounter ';' with no valid value string before it
        if isempty(T)
          errmsg = ['Extra ";" found.'];
          error(errmsg);
        end

        % remove leading white spaces
        T = fliplr(deblank(fliplr(T)));

        % Handle both single rate and multi-rate scenarios
        if isequal(T(1), '[')
          if length(T) < 2
            errmsg = 'Input is not a valid Matlab array.';
            error('Simulink:ConfigSet:SampleTimeProperty', errmsg);
          end
          T = T(2:end);        
        end

        T = strrep(T, ',', ' ');

        errmsg = 'Input matrix must be nx3 array.';
        
        [TT, TR] = strtok(T, ' ');
        if isempty(TT) || isempty(TR)
          error(errmsg);
        end
        newVal(i).SampleTime = TT;
        
        [TT, TR] = strtok(TR, ' ');
        if isempty(TT) || isempty(TR)
          error(errmsg);
        end
        newVal(i).Offset = TT;
        
        TR = strrep(TR, ']', ' ');
        [TT, TR] = strtok(TR, ' ');
        TR = strtok(TR, ' ');
        if isempty(TT) || ~isempty(TR)
          error(errmsg);
        end
        iTT = sscanf(TT, '%d');
        if isempty(iTT) || ~isequal(sprintf('%d',iTT), TT)
          errmsg = 'Priority must be an integer number.';
          error(errmsg);
        end
        newVal(i).Priority = iTT;
        
        if length(R) > 2
          val = R(2:end);
        else
          val = '';
        end
      end
          
    else
      errmsg = ['Unknown input format of sample time property'];
      error(errmsg);
    end
  catch
    prevErr = lasterr;
    [stack prevErr] = strtok(lasterr, sprintf('\n'));
    if isempty(prevErr)
      prevErr = lasterr;
    end    
    errmsg = ['Incorrect input format of sample time property: ', ...
              sprintf('\n'), prevErr];
    error('Simulink:ConfigSet:SampleTimePropertyChecking', errmsg);
  end
  