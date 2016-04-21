## Copyright (C) 2008 simone pernice
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

## __intSingleFormInt__ return an interval from the given engineer format string

## Author: simone pernice
## Created: 2008-12-31

function ret = __intSingleFormInt__ (engnotation)
	if (! ischar (engnotation)) 
		error ("It is required a string as input");
	endif
  if (nargin() != 1)
     error ("Wrong number of argument passed to the function.");
  endif

	l = length (engnotation);

	#skip the initial sign
	s = i = 1;
  if ((c = engnotation(1)) == "+" || c == "-") 
		i = 2;
	endif

	#count for the value
	while (i <= l && (isdigit(c = engnotation(i)) || c == "." || c == "e"))      
		++i;
		if ( c == "e" && (engnotation(i) == "+" || engnotation(i) == "-"))
			++i;
		endif  
	endwhile
	
	#convert the value
	val = str2double(substr(engnotation,s,i-s));	

	#look if a engineer coefficient is present and get the power
  power = strfind ("yzafpnum KMGTPEZY", engnotation(i));
  if (length (power) == 0) 	
  	power = 9;
	else
		power = power (1);
		++i;	
	endif
	#apply the power
	val *= 10^(3*(power-9));

	#look for the positive and negative tolerance (fpt is foundPositiveTolerance, fnt is foundNegativeTolerance)
	fpt = fnt = 0;
	while (i <= l)

		#skip positive and negative signs storing what was found
		while (i <= l && ((c = engnotation(i)) == "+" || c == "-")) 
			++i;
			if (c == "+") fpt = 1;
			elseif (c == "-") fnt = 1;
			endif
		endwhile
		s = i;
		
		#skip the digits untile the % is found
		while (i <= l && engnotation(i) != "%")
			++i;
		endwhile
			
		#convert the positive tolerance
		if (fpt) 
			ptol = str2double(substr(engnotation,s,i-s));
		endif
		
		#convert the negative tolerance
		if (fnt) 
			ntol = -str2double(substr(engnotation,s,i-s));
		endif
		
		fpt = fnt = 0;
		++i;
	endwhile

	
	#build the interval
  ret = valtol100ToInt(val, ptol, ntol);
  
endfunction
