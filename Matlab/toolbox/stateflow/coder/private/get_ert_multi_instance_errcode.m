function value = get_ert_multi_instance_errcode(modelName) 
   
	tlcVar = 'MultiInstanceErrorCode';
	rtwoptions = get_param(modelName,'rtwoptions'); 
	
	pattern = ['-a',tlcVar,'=\"(\w+)\"'];
	[first last tokens] = regexp(rtwoptions,pattern);
	if(isempty(tokens))
		value = 'Error';
		return;
	end
	value = rtwoptions(tokens{1}(1):tokens{1}(2));
