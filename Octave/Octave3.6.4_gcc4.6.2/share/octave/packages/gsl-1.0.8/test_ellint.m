## Copyright (C) 2008   Raymond E. Rogers   
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
##  any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see .

#
#
#
# R. Rogers v1, testing gsl_sf_ellint_Kcomp_e, gsl_sf_ellint_Ecomp_e
# 	implementation in octave as ellint_Kcomp, ellint_Ecomp
#	against the gsl tests 
#	Some array verification is done; since I messed it up once.


global GSL_DBL_EPSILON=        2.2204460492503131e-16
global GSL_SQRT_DBL_EPSILON=   1.4901161193847656e-08
global TEST_TOL0= (2.0*GSL_DBL_EPSILON)
global TEST_TOL1=  (16.0*GSL_DBL_EPSILON)
global TEST_TOL2=  (256.0*GSL_DBL_EPSILON)
global TEST_TOL3=  (2048.0*GSL_DBL_EPSILON)
global TEST_TOL4=  (16384.0*GSL_DBL_EPSILON)
global TEST_TOL5=  (131072.0*GSL_DBL_EPSILON)
global TEST_TOL6=  (1048576.0*GSL_DBL_EPSILON)
global TEST_SQRT_TOL0= (2.0*GSL_SQRT_DBL_EPSILON)
global TEST_SNGL=  (1.0e-06)

global TEST_SF_INCONS=  1
global TEST_SF_ERRNEG=  2
global TEST_SF_TOLBAD=  4
global TEST_SF_RETBAD=  8
global TEST_SF_ERRBAD=  16
global TEST_SF_ERRBIG=  32
global TEST_SF_EXPBAD=  64
global TEST_FACTOR=	100


function res=READ_TEST_SF_ellint(input_name)
global GSL_DBL_EPSILON     
global GSL_SQRT_DBL_EPSILON
global TEST_TOL0
global TEST_TOL1
global TEST_TOL2
global TEST_TOL3
global TEST_TOL4
global TEST_TOL5
global TEST_TOL6
global TEST_SQRT_TOL0
global TEST_SNGL

global TEST_SF_INCONS
global TEST_SF_ERRNEG
global TEST_SF_TOLBAD
global TEST_SF_RETBAD
global TEST_SF_ERRBAD
global TEST_SF_ERRBIG
global TEST_SF_EXPBAD

global TEST_FACTOR
	[source_id,source_msg]=fopen(input_name,"r","native")
	

		while (! feof(source_id))
			do			
				input_line=fgetl(source_id);
			until( index(input_line,"//") == 0);
			
			str_p=index(input_line,"gsl_sf_ellint_Kcomp_e");
			if (str_p != 0)
				# Take it apart
				string_split=split(input_line,",");
				arg1=str2double(substr(string_split(3,:),3));
				arg2=str2double(string_split(4,:));
				arg3=(string_split(5,:));
				val=str2double(string_split(6,:));
				tol=eval(string_split(7,:));
				[ret,err]=ellint_Kcomp(arg1,arg2);
				# This is to prevent extanious stops on some errors
				if ret==NaN 
					ret=Inf
				endif 
				if (abs((ret-val)/val)<tol*TEST_FACTOR)
					printf("\n Passed ellint_Kcomp: %e  ",arg1)
				else
					printf("\n Failed ellint_Kcomp: %s\n value=%e, computed=%e, tol=%e, returned error=%e ",input_line,val,ret,tol,err)
					printf("\n error %e", abs((ret-val)/val))
				endif 				
			endif
			str_p=index(input_line,"gsl_sf_ellint_Ecomp_e");
			if (str_p != 0)
				# Take it apart
				string_split=split(input_line,",");
				arg1=str2double(substr(string_split(3,:),3));
				arg2=str2double(string_split(4,:));
				arg3=(string_split(5,:));
				val=str2double(string_split(6,:));
				tol=eval(string_split(7,:));
				[ret,err]=ellint_Ecomp(arg1,arg2);
				# This is to prevent extanious stops on some errors
				if ret==NaN 
					ret=Inf
				endif 
				if (abs((ret-val)/val)<tol*TEST_FACTOR)
					printf("\n Passed ellint_Ecomp: %e  ",arg1)
				else
					printf("\n Failed ellint_Ecomp: %s\n value=%e, computed=%e, tol=%e, returned error=%e ",input_line,val,ret,tol,err)
					printf("\n error %e", abs((ret-val)/val))
				endif 				
			endif
		endwhile
	fclose(source_id);
	#lets do some array tests
	disp("\n array tests")
	disp("\n Argument array")
	mat1=[.1,.2; .3,.5]
	disp("\n ellint_Kcomp(mat1)")
	ellint_Kcomp(mat1,0)
	disp("\n ellint_Ecomp(mat1)")
	ellint_Ecomp(mat1,0)

	res="";
end
#file_name=input("file name: ","s")
file_name="test_sf.c"
READ_TEST_SF_ellint(file_name);


