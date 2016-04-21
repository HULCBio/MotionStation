% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% function benchmark_intmath (n, ratio)
% description:
% Test speed of integer math & conversions.
%
% arguments:
% n = array size
% ratio = ratio of intmath for generating integers
%
% results:
% time_uint8_conv = time to convert real vector to uint8
% time_uint8_add = time to add two uint8 vectors
% time_uint8_sub = time to subtract two uint8 vectors
% time_uint8_mul = time to multiply two uint8 vectors
% time_uint8_div = time to divide two uint8 vectors
% time_int8_conv = time to convert real vector to int8
% time_int8_add = time to add two int8 vectors
% time_int8_sub = time to subtract two int8 vectors
% time_int8_mul = time to multiply two int8 vectors
% time_int8_div = time to divide two int8 vectors
% time_uint16_conv = time to convert real vector to uint16
% time_uint16_add = time to add two uint16 vectors
% time_uint16_sub = time to subtract two uint16 vectors
% time_uint16_mul = time to multiply two uint16 vectors
% time_uint16_div = time to divide two uint16 vectors
% time_int16_conv = time to convert real vector to int16
% time_int16_add = time to add two int16 vectors
% time_int16_sub = time to subtract two int16 vectors
% time_int16_mul = time to multiply two int16 vectors
% time_int16_div = time to divide two int16 vectors
% time_uint32_conv = time to convert real vector to uint32
% time_uint32_add = time to add two uint32 vectors
% time_uint32_sub = time to subtract two uint32 vectors
% time_uint32_mul = time to multiply two uint32 vectors
% time_uint32_div = time to divide two uint32 vectors
% time_int32_conv = time to convert real vector to int32
% time_int32_add = time to add two int32 vectors
% time_int32_sub = time to subtract two int32 vectors
% time_int32_mul = time to multiply two int32 vectors
% time_int32_div = time to divide two int32 vectors
%

function results = benchmark_intmath (n, ratio)

  benchutil_default_arg ('n', 1e7);
  benchutil_default_arg ('ratio', 0.6);

  benchutil_initialize (mfilename)

  x = ratio * double (intmax ('uint8')) * rand(n, 1);
  y = ratio * double (intmax ('uint8')) * rand(n, 1);

  x = uint8 (x);
  tic; y = uint8 (y); time_uint8_conv = toc;
  benchutil_set_result ('time_uint8_conv')

  tic; xy = x + y; time_uint8_add = toc;
  benchutil_set_result ('time_uint8_add')

  tic; xy = x - y; time_uint8_sub = toc;
  benchutil_set_result ('time_uint8_sub')

  tic; xy = x .* y; time_uint8_mul = toc;
  benchutil_set_result ('time_uint8_mul')

  tic; xy = x ./ y; time_uint8_div = toc;
  benchutil_set_result ('time_uint8_div')

  x = ratio * double (intmax ('int8')) * (2 * rand(n, 1) - 1);
  y = ratio * double (intmax ('int8')) * (2 * rand(n, 1) - 1);

  x = int8 (x);
  tic; y = int8 (y); time_int8_conv = toc;
  benchutil_set_result ('time_int8_conv')

  tic; xy = x + y; time_int8_add = toc;
  benchutil_set_result ('time_int8_add')

  tic; xy = x - y; time_int8_sub = toc;
  benchutil_set_result ('time_int8_sub')

  tic; xy = x .* y; time_int8_mul = toc;
  benchutil_set_result ('time_int8_mul')

  tic; xy = x ./ y; time_int8_div = toc;
  benchutil_set_result ('time_int8_div')

  x = ratio * double (intmax ('uint16')) * rand(n, 1);
  y = ratio * double (intmax ('uint16')) * rand(n, 1);

  x = uint16 (x);
  tic; y = uint16 (y); time_uint16_conv = toc;
  benchutil_set_result ('time_uint16_conv')

  tic; xy = x + y; time_uint16_add = toc;
  benchutil_set_result ('time_uint16_add')

  tic; xy = x - y; time_uint16_sub = toc;
  benchutil_set_result ('time_uint16_sub')

  tic; xy = x .* y; time_uint16_mul = toc;
  benchutil_set_result ('time_uint16_mul')

  tic; xy = x ./ y; time_uint16_div = toc;
  benchutil_set_result ('time_uint16_div')

  x = ratio * double (intmax ('int16')) * (2 * rand(n, 1) - 1);
  y = ratio * double (intmax ('int16')) * (2 * rand(n, 1) - 1);

  x = int16 (x);
  tic; y = int16 (y); time_int16_conv = toc;
  benchutil_set_result ('time_int16_conv')

  tic; xy = x + y; time_int16_add = toc;
  benchutil_set_result ('time_int16_add')

  tic; xy = x - y; time_int16_sub = toc;
  benchutil_set_result ('time_int16_sub')

  tic; xy = x .* y; time_int16_mul = toc;
  benchutil_set_result ('time_int16_mul')

  tic; xy = x ./ y; time_int16_div = toc;
  benchutil_set_result ('time_int16_div')

  x = ratio * double (intmax ('uint32')) * rand(n, 1);
  y = ratio * double (intmax ('uint32')) * rand(n, 1);

  x = uint32 (x);
  tic; y = uint32 (y); time_uint32_conv = toc;
  benchutil_set_result ('time_uint32_conv')

  tic; xy = x + y; time_uint32_add = toc;
  benchutil_set_result ('time_uint32_add')

  tic; xy = x - y; time_uint32_sub = toc;
  benchutil_set_result ('time_uint32_sub')

  tic; xy = x .* y; time_uint32_mul = toc;
  benchutil_set_result ('time_uint32_mul')

  tic; xy = x ./ y; time_uint32_div = toc;
  benchutil_set_result ('time_uint32_div')

  x = ratio * double (intmax ('int32')) * (2 * rand(n, 1) - 1);
  y = ratio * double (intmax ('int32')) * (2 * rand(n, 1) - 1);

  x = int32 (x);
  tic; y = int32 (y); time_int32_conv = toc;
  benchutil_set_result ('time_int32_conv')

  tic; xy = x + y; time_int32_add = toc;
  benchutil_set_result ('time_int32_add')

  tic; xy = x - y; time_int32_sub = toc;
  benchutil_set_result ('time_int32_sub')

  tic; xy = x .* y; time_int32_mul = toc;
  benchutil_set_result ('time_int32_mul')

  tic; xy = x ./ y; time_int32_div = toc;
  benchutil_set_result ('time_int32_div')


