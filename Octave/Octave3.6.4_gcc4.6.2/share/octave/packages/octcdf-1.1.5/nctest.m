## Copyright (C) 2005 Alexander Barth <barth.alexander@gmail.com>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Loadable Function} nctest
## Tests the octcdf toolbox. Tests results are written to nctest.log. All tests
## should pass.
## @end deftypefn

## Author: Alexander Barth <barth.alexander@gmail.com>



function [passes,tests] = nctest
   disp('writing test output to nctest.log');
   test('nctest','normal','nctest.log');
endfunction


%!shared fname, nc
%! fname = [tmpnam '-octcdf.nc'];
%! nc = netcdf(fname,'c');

%!# Test reading/writing dimension
%!test
%! nc('time') = 5;
%! nc('space') = 3;
%! nc('record') = 0;
%! assert(length(nc('time')),5);
%! assert(length(nc('space')),3);

%!# Test reading/writing global attributes
%!test
%! nc.byte_att = ncbyte(123);
%! nc.short_att = ncshort(123);
%! nc.int_att = ncint(123);
%! nc.long_att = nclong(123);
%! nc.float_att = ncfloat(123);
%! nc.double_att = ncdouble(123.4);
%! nc.string_att = "test string";
%! assert(nc.byte_att,123)
%! assert(nc.short_att,123)
%! assert(nc.int_att,123)
%! assert(nc.long_att,123)
%! assert(nc.float_att,single(123))
%! assert(nc.double_att,123.4)
%! assert(nc.string_att,"test string")

%!# Test reading/writing varaible of type byte
%!test
%! byte_var =  reshape(1:15,5,3);
%! nc{'byte_var'} =  ncbyte('time','space');
%! nc{'byte_var'}(:) = byte_var;
%! assert(nc{'byte_var'}(:),byte_var);

%!# Test reading/writing varaible of type short
%!test
%! short_var =  reshape(1:15,5,3);
%! nc{'short_var'} =  ncshort('time','space');
%! nc{'short_var'}(:) = short_var;
%! assert(nc{'short_var'}(:),short_var);

%!# Test reading/writing varaible of type int
%!test
%! int_var =  reshape(1:15,5,3);
%! nc{'int_var'} =  ncint('time','space');
%! nc{'int_var'}(:) = int_var;
%! assert(nc{'int_var'}(:),int_var);

%!# Test reading/writing varaible of type long
%!test
%! long_var =  reshape(1:15,5,3);
%! nc{'long_var'} =  nclong('time','space');
%! nc{'long_var'}(:) = long_var;
%! assert(nc{'long_var'}(:),long_var);

%!# Test reading/writing varaible of type float
%!test
%! float_var =  reshape(1:15,5,3)/10;
%! nc{'float_var'} =  ncfloat('time','space');
%! nc{'float_var'}(:) = float_var;
%! assert(nc{'float_var'}(:),float_var,1e-5);

%!# Test reading/writing varaible of type double
%!test
%! double_var =  reshape(1:15,5,3)/10;
%! nc{'double_var'} =  ncdouble('time','space');
%! nc{'double_var'}(:) = double_var;
%! assert(nc{'double_var'}(:),double_var);

%!# Test reading/writing varaible of type char
%!test
%! char_var = reshape('ajhkjhgkjhfdgkh',5,3);
%! nc{'char_var'} =  ncchar('time','space');
%! nc{'char_var'}(:) = char_var;
%! assert(nc{'char_var'}(:),char_var);

%!# Test reading/writing variable attributes
%!test
%! nv = nc{'int_var'};
%! nv.byte_att = ncbyte(123);
%! nv.short_att = ncshort(123);
%! nv.int_att = ncint(123);
%! nv.long_att = nclong(123);
%! nv.float_att = ncfloat(123);
%! nv.double_att = ncdouble(123.4);
%! nv.string_att = "test string";
%! assert(nv.byte_att,123)
%! assert(nv.short_att,123)
%! assert(nv.int_att,123)
%! assert(nv.long_att,123)
%! assert(nv.float_att,single(123))
%! assert(nv.double_att,123.4)
%! assert(nv.string_att,"test string")

%!# Test ncdim
%!test
%! dimlist = dim(nc);
%! assert(length(dimlist),3);
%! assert(dimlist{1}(:),5);
%! assert(dimlist{2}(:),3);

%!# Test isrecord
%!test
%! assert(isrecord(nc('record')) == 1);

%!# Test name on file
%!test
%! assert(name(nc),fname);

%!# Test ncatt
%!test
%! attlist = att(nc);
%! assert(length(attlist),7);
%! assert(name(attlist{1}),'byte_att');
%! assert(datatype(attlist{1}),'byte');
%! assert(attlist{1}(:),123);

%!# Test ncvar
%!test
%! varlist = var(nc);
%! assert(length(varlist),7);
%! assert(name(varlist{1}),'byte_var');
%! assert(datatype(varlist{1}),'byte');

%!# Test to write a variable by slices
%!test
%! imax = 10;
%! jmax = 11;
%! kmax = 12;
%! nc('imax') = imax;
%! nc('jmax') = jmax;
%! nc('kmax') = kmax;
%! sliced_var =  reshape(1:imax*jmax*kmax,imax,jmax,kmax);
%! nc{'sliced_var'} =  ncdouble('imax','jmax','kmax');
%! 
%! for i=1:imax
%!   nc{'sliced_var'}(i,:,:) = squeeze(sliced_var(i,:,:));
%! end
%! 
%! sliced_var2 = nc{'sliced_var'}(:);
%! 
%! assert(sliced_var2 == sliced_var)

%!# Test autoscale
%!test
%! var = rand(5,3);
%! add_offset = 1; 
%! scale_factor = .1;
%!
%! nc{'autoscale_var'} =  ncdouble('time','space'); 
%! nc{'autoscale_var'}.add_offset = add_offset;
%! nc{'autoscale_var'}.scale_factor = scale_factor;
%! nc{'autoscale_var',1}(:) = var;     
%!
%! unscaled = nc{'autoscale_var'}(:);
%! assert(var,scale_factor*unscaled+add_offset,1e-6);
%!
%! scaled = nc{'autoscale_var',1}(:);                          
%! assert(var,scaled,1e-6);
%!
%! nf = autoscale(nc{'autoscale_var'},1);
%! assert(nf(:),scaled,1e-6);

%!# Test autonan
%!test
%! nc{'variable_with_gaps'}=ncdouble('time'); 
%! nv = nc{'variable_with_gaps'}; 
%! nv = autonan(nv,1);
%! nv.FillValue_ = 99; 
%! nv(:) = NaN;
%! 
%! nv = autonan(nv,0);
%! assert(all(nv(:) == 99))
%! 
%! nv = autonan(nv,1);
%! assert(all(isnan(nv(:))))

%!# Test size of vector
%!test
%! nc{'vector'} = ncfloat('time'); 
%! nc{'vector'}(:) = 0;  
%! v = nc{'vector'}(:); 
%! assert(size(v),[5 1])

%!# Test scalar
%!test
%! nc{'scalar'} = ncint();
%! nc{'scalar'}(:) = 10;
%! v = nc{'scalar'}(:);
%! assert(v,10)
 
%!# Close file
%!test
%! close(nc);
%! delete(fname);


%!# Test rename function
%!test
%! filename = [tmpnam '-octcdf.nc'];
%! nf = netcdf(filename,'c');
%! 
%! nf('longitude') = 5;
%! nf('latitude') = 5;
%! 
%! nf.old_name = 'example attribute';
%! 
%! d = dim(nf){1};
%! name(d,'new_name');
%! assert(name(d),'new_name')
%! 
%! a = att(nf){1};
%! name(a,'new_name');
%! assert(name(a),'new_name');
%! 
%! nf{'old_name'} = ncdouble('new_name','latitude');
%! v = nf{'old_name'};
%! name(v,'new_name')
%! assert(name(v),'new_name');
%! close(nf);
%! delete(filename);

%!# Test 64bit-offset function
%!test
%! filename = [tmpnam '-octcdf.nc'];
%! nf = netcdf(filename,'c','64bit-offset');
%! close(nf);
%! delete(filename);

