function out1 = wimgcode(option,in2,in3,in4,in5,in6)
%WIMGCODE Image coding mode.
%   OUT1 = WIMGCODE(OPTION,IN2,IN3,IN4,IN5,IN6)
              
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 07-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

switch option
    case 'get' , 
		if nargin==1
			out1 = 1;
		else
			out1 = wfigmngr('get_CCM_Menu',in2);
		end
		
    case 'cod'
      % in2 = flag for coding
      % in3 = matrix to encode
      % in4 = number of class
      % in5 = flag absolute value
      % in6 = optional (trunc parameters)
      %   in6(1)   = lev;
      %   in6(2:3) = size init
      %----------------------------------
      if in2==0
          out1 = in3;
      else
          nb      = in4;
          [t1,t2] = size(in3);
          out1    = ones(t1,t2);
          if in5==1 , in3 = abs(in3); end
          in3  = in3-min(min(in3));
          maxx = max(max(in3));
          if maxx>=sqrt(eps)
              mul  = nb/maxx;
              out1 = reshape(fix(1 + mul*in3),t1,t2);
              out1(out1>nb) = nb;
          end
      end
      if nargin==6
          lev = in6(1);
          if lev==0 , return; end
          sx = in6(2:3);
          for k = 1:lev , sx = floor((sx+1)/2); end
          out1 = wkeep2(out1,sx);
      end
end
