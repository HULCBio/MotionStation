function  targetProps = rtw_target_props(relevantMachineName)

    targetProps.codingStateBitsets = 0;
    targetProps.codingDataBitsets = 0;
    targetProps.codingEmitObjectDescriptions = 0;
    targetProps.codingComments = 0;
    targetProps.codingAutoComments = 0;
    targetProps.codingRedundantElim = 0;
    targetProps.codingEmitObjectRequirements = 0;
    targetProps.algorithmWordsizes =[];
    targetProps.targetWordsizes=[];
    targetProps.algorithmHwInfo=[];
    targetProps.targetHwInfo=[];

    if ~strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')
        cs = getActiveConfigSet(relevantMachineName);

        targetProps.codingStateBitsets = get_bool_prop(cs,'StateBitsets');
        targetProps.codingDataBitsets = get_bool_prop(cs,'DataBitsets');
        targetProps.codingEmitObjectDescriptions = get_bool_prop(cs,'SFDataObjDesc');
        targetProps.codingComments = get_bool_prop(cs,'GenerateComments');
        targetProps.codingAutoComments = targetProps.codingComments &&...
            get_bool_prop(cs,'IncAutoGenComments');
        targetProps.codingRedundantElim = get_bool_prop(cs,'UseTempVars');
        [targetProps.algorithmWordsizes,...
        targetProps.targetWordsizes,...
        targetProps.algorithmHwInfo,...
        targetProps.targetHwInfo] = ...
            get_word_sizes(relevantMachineName,'rtw');
        
        targetProps.sharedUtilsEnabled = rtw_gen_shared_utils(relevantMachineName);
        targetProps.usedTargetFunctionLib = get_param(cs,'GenFloatMathFcnCalls');
        targetProps.codingEmitObjectRequirements = get_bool_prop(cs,'ReqsInCode');
    end

function boolVal = get_bool_prop(cs,propName)
    boolVal = strcmp(get_param(cs,propName),'on');

    
