## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

##       errors = test_struct
##
## Test whether struct functions behave, and returns the number of errors.
##   
## Sets the global variables test_struct_errors (number of errors)
##                     and   test_struct_cnt    (number of tests) 
##
## If a workspace variable 'verbose' is set to -1 the output is verbose. 
## If it is set to 1, output is minimal (error and test counts).
## Otherwise, each error is reported with a short message and the error and ...
## test counts are displayed at the end of the script (if it is reached).
##

1 ;
global test_struct_errors  ;
global test_struct_cnt  ;
test_struct_verbose = test_struct_errors = test_struct_cnt = 0 ;

if ! exist ("verbose"), verbose = 0; end
if exist ("verbose") && ! isglobal ("verbose")
  tmp = verbose;
  global verbose = tmp;
end

function mytest( val, tag )	# My test function ###################

global test_struct_cnt ;
global test_struct_errors  ;
global verbose ;

% if ! exist("test_struct_verbose"), test_struct_verbose = 0 ; end

if val ,
  if verbose
    printf("OK %i\n",test_struct_cnt) ; 
  end
else
  if verbose 
    printf("NOT OK %-4i : %s\n",test_struct_cnt,tag) ;
  end
  test_struct_errors++ ;
end
test_struct_cnt++ ;
endfunction			# EOF my test function ###############




s.hello = 1 ;
s.world = 2 ;
mytest( isstruct(s)                   , "isstruct" ) ;
mytest( s.hello == getfields(s,"hello"), "getfields 1" ) ;
mytest( s.world == getfields(s,"world"), "getfields 2" ) ; 

t = struct ("hello",1,"world",2) ;
mytest( t.hello == s.hello            , "struct 1" ) ;
mytest( t.world == s.world            , "struct 2" ) ;

s.foo = "bar" ;
s.bye = "ciao" ;
t = setfields (t,"foo","bar","bye","ciao") ;
mytest( t.foo == s.foo                , "setfields 1" ) ;
mytest( t.bye == s.bye                , "setfields 2" ) ;

% s = struct() ;
% t = rmfield (t,"foo","bye","hello") ; % no longer works with octave func
t = rmfield( t, "foo");
t = rmfield( t, "bye");
t = rmfield( t, "hello");
mytest( ! isfield(t,"foo")    , "rmfield 1" ) ;
mytest( ! isfield(t,"bye")    , "rmfield 2" ) ;
mytest( ! isfield(t,"hello")  , "rmfield 3" ) ;
mytest( t.world ==  s.world           , "rmfield 4" ) ;


				# Test tars, getfield
x = 2 ; y = 3 ; z = "foo" ;
s = tars (x,y,z);

mytest( x == s.x                          , "tars 1" );
mytest( y == s.y                          , "tars 2" );
mytest( z == s.z                          , "tars 3" );

a = "x" ; b = "y" ; 
[xx,yy,zz] = getfields (s,a,b,"z") ;

mytest( x == xx                           , "getfields 1" );
mytest( y == yy                           , "getfields 2" );
mytest( z == zz                           , "getfields 3" );

[x3,z3,z4] = getfields (s,"x","z","z") ;
mytest( x == x3                           , "getfields 4" );
mytest( z == z3                           , "getfields 5" );
mytest( z == z4                           , "getfields 6" );

## Broken
##oo(1,1).f0= 1;
##oo= setfield(oo,{1,2},'fd',{3},'b', 6);
##mytest( getfield(oo,{1,2},'fd',{3},'b') == 6, "getfield 6" );

try				# Should not return inexistent fields
  [nothing] = getfields (s,"foo");
  found_nothing = 0;
catch
  found_nothing = 1;
end
mytest( found_nothing                     , "getfields 4" );


ok = test_struct_errors == 0;
if verbose
  if ok
    printf ("All %d tests ok\n", test_struct_cnt);
  else
    printf("There were %d errors in of %d tests\n",...
	   test_struct_errors,test_struct_cnt) ;
  end
end
