function value = get_boolean_rtw_option(optionName)
    
    modelName = sf('get',get_relevant_machine,'machine.name');
    
    rtwoptions = get_param(modelName,'rtwoptions');
    
    pattern = ['-a',optionName,'=(\d+)'];
    tokens = regexp(rtwoptions,pattern,'tokens','once');
    if(isempty(tokens))
        value = 0;
        return;
    end
    value = str2num(tokens{1})~=0;
    
   