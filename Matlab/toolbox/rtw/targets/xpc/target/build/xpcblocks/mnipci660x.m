function mnipci660x(phase, ctr, slot, boardType)

% Copyright 2003-2004 The MathWorks, Inc.
  
  if phase == 1  % InitFcn call, only phase is defined
    ctr = get_param(gcb, 'channel');
    masktype = get_param( gcb, 'MaskType' );
    ctrtype = ['ctr', masktype(4:end)];
    pwmtype = ['pwm', masktype(4:end)];
    enctype = ['enc', masktype(4:end)];
    ctrs = find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', ctrtype );
    pwms = find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', pwmtype );
    encs = find_system(bdroot, ...
                       'FollowLinks', 'on', ...
                       'LookUnderMasks', 'all', ...
                       'MaskType', enctype );

    slot = evalin( 'caller', get_param(gcb, 'slot') );

    matching = {};                          % will contain all blocks for the
                                            % same board.
    for i = 1 : length(ctrs)
      tmp = evalin( 'caller', get_param(ctrs{i}, 'slot'));
      if isequal(tmp, slot)
        tmp = get_param(ctrs{i}, 'MaskValues');
        matching{end + 1} = tmp{1};
      end
    end
    for i = 1 : length(pwms)
      tmp = evalin( 'caller', get_param(pwms{i}, 'slot'));
      if isequal(tmp, slot)
        tmp = get_param(pwms{i}, 'MaskValues');
        matching{end + 1} = tmp{1};
      end
    end
    for i = 1 : length(encs)
      tmp = evalin( 'caller', get_param(encs{i}, 'slot'));
      if isequal(tmp, slot)
        tmp = get_param(encs{i}, 'MaskValues');
        matching{end + 1} = tmp{1};
      end
    end

    if length(strmatch(ctr, matching)) ~= 1
      error('Only one block can use a given counter');
    end
  end
  
  if phase == 2
    if prod(length(slot)) > 2
      error(['Slot must be either -1 for auto-detection or a vector [bus, ' ...
             'slot]']);
    end
    sprintf('phase2: ctr = %d\n', ctr );
  end