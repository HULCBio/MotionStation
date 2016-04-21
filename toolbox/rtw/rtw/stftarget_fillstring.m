function ret = stftarget_fillstring(str, hObj)

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $
  
  sep = findstr(str, '/');
  index = 0;
  tokens = [];
  values = [];
  
  for i = 1:length(sep)-1
    
    token = str(sep(i)+1 : sep(i+1)-1);
    val = '';
    
    % check if there exist such a property
    prop = findprop(hObj, token);
    
    if ~isempty(prop)
      
      % get the property value
      try
        val = getProp(hObj, token);
      end
      
      if isnumeric(val) | islogical(val)
        val = num2str(val);
      end
      
      type = findtype(prop.DataType);
      
      if strcmp(type.Name, 'on/off') || strcmp(type.Name, 'slbool')
        if strcmp(val, 'on')
          val = '1';
        else
          val = '0';
        end
      end
      
      % check if the property is of enum type
      isEnum = false;
      if ~isempty(type) & ~isempty(findprop(type, 'Strings'))  ...
            & ~isempty(findprop(type, 'Values'))
        isEnum = true;
      end
      
      % check whether a enum type value should be in string format or value 
      % format
      if isEnum & (sep(i)-1 <= 0 | str(sep(i)-1) ~= '"')
        for j = 1 : length(type.Strings)
          if ischar(type.Strings{j}) & strcmp(type.Strings{j}, val)
            val = num2str(type.Values(j));
            break;
          end
        end
      end
    end
    
    % strip val of its outer quote if any
    if ~isempty(val) && ischar(val) && length(val) > 1 && ...
          strcmp(val(1), '''') && strcmp(val(end), '''')
      val = val(2:end-1);
    end      
       
    % keep a record of this token and value
    index = index + 1;
    tokens{index} = ['/' token '/'];
    values{index} = val;
    
    % increment i
    i = i + 1;
  end
  
  for i = 1 : index
    str = strrep(str, tokens{i}, values{i});
  end

  % Trying to put single quote around string with empty space
  % i.e. xxx="aaa bbb" will become 'xxx="aaa bbb"'
  sep1 = findstr(str, '"');
  sep2 = findstr(str, ' ');
  
  for i = 1:2:length(sep1)
    prespace = max(find(sep2 < sep1(i+1)));
    if ~isempty(prespace) & sep2(prespace) > sep1(i)
      % in this case there is a spaced quoted string
      prespace = max(find(sep2 < sep1(i)));
      if isempty(prespace)
        part1 = '';
        part2 = str(1:sep1(i+1));
      else
        part1 = str(1:sep2(prespace));
        part2 = str(sep2(prespace)+1:sep1(i+1));
      end
      
      if length(str) > sep1(i+1)
        part3 = str(sep1(i+1)+1:end);
      else
          part3 = '';
      end
      
      str = [part1 '''' part2 '''' part3];
      sep1 = findstr(str, '"');
      sep2 = findstr(str, ' ');
    end
  end
  
  ret = str;
