function value = is_ert_multi_instance(modelName) 
   
	tlcVar = 'MultiInstanceERTCode';
	rtwoptions = get_param(modelName,'rtwoptions'); 
	
	pattern = ['-a',tlcVar,'=(\d+)']; 
	[first last tokens] = regexp(rtwoptions,pattern);
	if(isempty(tokens))
		value = 0;
		return;
	end
	subStr = rtwoptions(tokens{1}(1):tokens{1}(2));
	value = str2num(subStr);	
