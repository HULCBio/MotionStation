function onoffdemocontrol(block,val)

if nargin < 1,
    block = gcb;
end

cblk=find_system(block,'LookUnderMasks','on','BlockType','Constant');
cblk=cblk{1};                

if nargin < 2,
    val=get_param(cblk,'value');
    if strcmp(val,'true')                                             
        val = 'false';                                                   
        onOffVal = 'OFF';                                                 
    else                                                              
        val = 'true';                                                    
        onOffVal = 'ON';                                              
    end
else
    if strcmp(val,'true') 
        onOffVal = 'ON'; 
    else
        onOffVal = 'OFF';
    end
end

set_param(cblk,'value',val); 
dispstr=['disp(''',onOffVal,''')'];                                   
set_param(block,'MaskDisplay',dispstr);

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 00:39:04 $
