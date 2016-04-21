% %QHULL  Qhull に対するコピーライト情報
%
%%%%% Qhull Copyright information copied from: %%%
%%%%% http://www.geom.umn.edu/software/download/COPYING.html %%%%
%
%   		       Copyright (c) 1993
%   
%       The National Science and Technology Research Center for
%        Computation and Visualization of Geometric Structures
%   		     (The Geometry Center)
%   		    University of Minnesota
%   		         400 Lind Hall
%                          207 Church St. SE
%   		  Minneapolis, MN  55454  USA
%   
%   		  email: software@geom.umn.edu
%
% ここで、配布されているソフトウエアは、上に示すコピーライトをもっていま
% す。これは、フリーのソフトウエアで、ftp.geom.umn.edu のサイトから入手
% できます。つぎの条件で、フリーにコピーしたり、変更したり、再配布するこ
% とができます。
%
%   1. All copyright notices must remain intact in all files. 
%   
%   2. A copy of this file (COPYING) must be distributed along with 
%      any copies that you redistribute; this includes copies that you 
%      have modified, or copies of programs or other software products 
%      that include this software. 
%   
%   3. If you modify this software, you must include a notice giving the 
%      name of the person performing the modification, the date of modi-
%      fication, and the reason for such modification. 
%
%   4. When distributing modified versions of this software, or other 
%      software products that include this software, you must provide 
%      notice that the original source code may be obtained as noted 
%      above. 
%   
%   5. There is no warranty or other guarantee of fitness for this soft-
%      ware, it is provided solely "as is". Bug reports or fixes may be 
%      sent to the email address above; the authors may or may not act on
%       them as they desire.
%
%   If you use an image produced by this software in a publication or
%   presentation, we request that you credit the Geometry Center with a
%   notice such as the following:
%
%     Figures 1, 2, and 5-300 were generated with software written at 
%    the Geometry Center, University of Minnesota.
%
%%%%% End of Qhull Copyright notice %%%%
%
%%%%% Qhull modification notice %%%%
%
%   Zhiping You of The MathWorks, Inc. changed Qhull as follows:
%
%   unix.c:   replaced by qhullmx.c (replacing main() by mexFunction())
%   global.c: a line that frees the original data is changed since 
%             MATLAB doesn't change input data.
%   io.c:     readpoints() is dropped, since we already have input data.
%
%%%%% End of Qhull modification notice %%%%
%
% 参考：QHULLMX, DELAUNAYN, VORONOIN.



%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/28 02:01:48 $
