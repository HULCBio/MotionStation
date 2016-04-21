function [answ,status] = chkmdinteg(Tsmod,Tsdata,inters,verb);

if nargin<4,
  verb = 1;
end

Nexp = length(Tsdata);

answ = 0;
status = '';

if Tsmod>0, % DT model
  is = inters{1};
  td = Tsdata{1};
    switch lower(inters{1}),
     case 'bl'
      answ = -1;
      status = ['Estimation of discrete time modeles from band' ...
		' limited data might produce inaccurate models.' ...
		' Estimation of continuos time model might yield' ...
		 ' better results.'];
      
     case {'foh'}
      answ = -1;
      status = ['Estimation of discrete time modeles from first' ...
		' order hold data might produce inaccurate models.' ...
		' Estimation of a continuos time model might yield' ...
		 ' better results.'];
     otherwise
    end
    for kexp=2:Nexp,
      if ~strcmp(is,inters{kexp}),
	answ = 1;
	status = ['When estimating discrete time models all experiments' ...
		  ' in the data set must have same intersample behaviour.'];
	break;
      end    
      if td ~= Tsdata{kexp}
	answ = 1;
	status = ['When estimating discrete time models all experiments' ...
		  ' in the data set must have same sampling' ...
		  ' interval.'];
	break;
      end
    end
else %CT model
end
if verb,
  switch answ,
   case 1,
    error(status);
   case -1,
    warning(status);
   otherwise
  end
end

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:20 $
