% INPUTNAME   ���͈�����
% 
% ���[�U��`�֐��̖{�̓��ŁAINPUTNAME(ARGNO) �́A�����̔ԍ� ARGNO ��
% �΂��郏�[�N�X�y�[�X�ϐ������o�͂��܂��B���͈����ɖ��O���Ȃ��ꍇ
% (���Ƃ��΁Aa(1), varargin{:}, eval(expr) ���̂悤�Ȍv�Z�̌��ʂł���
% �Ƃ�)�́AINPUTNAME �͋󕶎�����o�͂��܂��B
%
% ���: 
% �֐� myfun �����̂悤�ɒ�`����Ă���Ɖ��肵�܂��B
% 
%   function y = myfun(a,b)
%   disp(sprintf('My first input is "%s".',inputname(1)))
%   disp(sprintf('My second input is "%s".',inputname(2)))
% 
% ���̂Ƃ��A
% 
%   x = 5; myfun(x,5)
% 
% �́A���̂悤�ȏo�͂����܂��B
% 
%     My first input is "x".
%     My second input is "".
%
% �Q�l�FNARGIN, NARGOUT, NARGCHK, MFILENAME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:06 $
%   Built-in function.
