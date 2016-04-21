function ret = getTargetPreferencesList_tic2000
               
% $RCSfile: getTargetPreferencesList_tic2000.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:03 $
%% Copyright 2003-2004 The MathWorks, Inc.

errormsg = [];

% for now, return data for first block found (assume top level)
tgtprefblocks = find_system (gcs,'FollowLinks','on','LookUnderMasks','on', 'MaskType','c2000 Target Preferences');
if ( length(tgtprefblocks)<1 )
    errormsg = 'This model does not contain any target preference blocks.'; 
    return;
end

userdata = get_param(tgtprefblocks{1},'userdata');
tgtprefs = userdata.tic2000TgtPrefs;

ret = [];
ret = getfieldvalues (ret, tgtprefs, '');


%-------------------------------------------------------------------------------
function ret = getfieldvalues (ret, parrentobj, pref)
%pref = [ pref '_'];
fn = fieldnames (parrentobj);
for i=1:length(fn)
    obj = getfield (parrentobj, fn{i});
    if isobject (obj)
        if (length(obj)>1)
           for j=1:length(obj)
               ret = getfieldvalues (ret, obj(j), [pref fn{i} num2str(j)]);            
           end
        else
           ret = getfieldvalues (ret, obj, [pref fn{i}]);
        end
    else
        ret = setfield (ret, [pref fn{i}], obj);
    end    
end 
 
  
%-------------------------------------------------------------------------------
function ret = isobject (obj)
c = class(obj);
switch c
    case {'struct', 'double', 'int8', 'uint8', 'int16', 'uint16', ...
          'int32', 'uint32', 'logical', 'char', 'cell' }
        ret = 0;
    otherwise
        ret = 1;
end

% [EOF]
