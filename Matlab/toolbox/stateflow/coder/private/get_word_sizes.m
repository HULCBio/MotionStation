function [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo] = get_word_sizes(relevantMachineName,targetName)

    codingSFunction = strcmp(targetName,'sfun');
    codingRTW = strcmp(targetName,'rtw');

    algWordLengthStr = get_param(relevantMachineName,'ProdHWWordLengths');

    if strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')

      algorithmHwInfo.hwDeviceType = 0;
      algorithmHwInfo.signedDivRounding = 0;
      algorithmHwInfo.divByZeroProtectionNotWanted = 0;

      targetHwInfo.hwDeviceType = 0;
      targetHwInfo.signedDivRounding = 0;
      targetHwInfo.divByZeroProtectionNotWanted = 0;

    else
      cs = getActiveConfigSet(relevantMachineName);
      hardware = cs.getComponent('Hardware Implementation');

      optimizationCS = cs.getComponent('Optimization');    
      divByZeroProtectionNotWanted = get_param(optimizationCS,'NoFixptDivByZeroProtection');

      % algorithm target aka final production deployment target
      %
      % Currenly 0 means Microprocessor and 
      %          1 means ASIC/FPGA/Unconstrained Integer Sizes
      devType = get_param(hardware,'ProdHWDeviceType');
      algorithmHwInfo.hwDeviceType = strncmp(devType,'ASIC',4);

      divRndStr = get_param(hardware,'ProdIntDivRoundTo');
      if strcmp(upper(divRndStr),'ZERO')
        algorithmHwInfo.signedDivRounding = 1;
      elseif strcmp(upper(divRndStr),'FLOOR')
        algorithmHwInfo.signedDivRounding = 2;
      else
        algorithmHwInfo.signedDivRounding = 0;  % unknown
      end

      algorithmHwInfo.divByZeroProtectionNotWanted = divByZeroProtectionNotWanted;
    
      % target HW aka current code generation target
      %
      devType = get_param(hardware,'TargetHWDeviceType');
      targetHwInfo.hwDeviceType = strncmp(devType,'ASIC',4);

      divRndStr = get_param(hardware,'TargetIntDivRoundTo');
      if strcmp(upper(divRndStr),'ZERO')
        targetHwInfo.signedDivRounding = 1;
      elseif strcmp(upper(divRndStr),'FLOOR')
        targetHwInfo.signedDivRounding = 2;
      else
        targetHwInfo.signedDivRounding = 0;  % unknown
      end

      targetHwInfo.divByZeroProtectionNotWanted = divByZeroProtectionNotWanted;
    end

    [s,e] = regexp(algWordLengthStr,'\d+');
    if(length(s)<4)
        error('why');
    end
    for i=1:4
        nBitsStr = algWordLengthStr(s(i):e(i));
        nBits = sscanf(nBitsStr,'%d');
        if(isempty(nBits))
            error('why');
        end
        algorithmWordsizes(i) = nBits;
    end
    if(codingSFunction)
        targetWordsizes = [8 16 32 32];
    elseif(codingRTW)
        targetWordsizesStruct = rtwwordlengths(relevantMachineName);
        targetWordsizes(1) = double(targetWordsizesStruct.CharNumBits);
        targetWordsizes(2) = double(targetWordsizesStruct.ShortNumBits);
        targetWordsizes(3) = double(targetWordsizesStruct.IntNumBits);
        targetWordsizes(4) = double(targetWordsizesStruct.LongNumBits);
    else
        targetWordsizes = coder_options('targetWordsizes');
    end

    % Sort them to be on the safe side
    algorithmWordsizes = sort(algorithmWordsizes);
    targetWordsizes = sort(targetWordsizes);

    % for now we must make long type 32 bits long
    % as IR needs to sort out long issues
    if(algorithmWordsizes(4)>32)
        algorithmWordsizes(4) = 32;
    end
    if(targetWordsizes(4)>32)
        targetWordsizes(4) = 32;
    end

    % Ensure that algorithm word sizes are <= target word sizes
    for i=1:4
        if algorithmWordsizes(i) > targetWordsizes(i)
            typeNames = {'char','short','int','long'};
            str = sprintf('The word size for "%s" is specified as (%d) in the "Hardware Implementation" section of Configuration Parameters. This is greater than the size (%d) supported on the current machine. Results may be incorrect for signals of this type due to rounding/saturation effects.',...
            typeNames{i},algorithmWordsizes(i),targetWordsizes(i));
            sf('Private','construct_warning',[],'Coder',str);
            algorithmWordsizes(i) = targetWordsizes(i);
        end
    end

