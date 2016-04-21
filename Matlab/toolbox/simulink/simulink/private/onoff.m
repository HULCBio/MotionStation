function outbool = onoff(input)
%ONOFF Convert a boolean to an appropriate 'on/off' value.
%   ONOFF converts its input from one boolean format to another.
%
%     onoff('on')  returns 1
%     onoff('off') returns 0
%     onoff(1)     returns 'on'
%     onoff(0)     returns 'off'
%     onoff('yes') returns 'on'
%     onoff('no')  returns 'off'

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

if isstr(input),

  switch(input),

    case 'on',
      outbool = 1;
   
    case 'off',
      outbool = 0;

    case 'yes',
      outbool = 'on';

    case 'no',
      outbool = 'off';

    otherwise,
      error('Allowable string inputs: ''on'', ''off'', ''yes'', ''no''');
  end

else,

  onoffs  = {'off','on'};
  outbool = onoffs{input+1};

end



