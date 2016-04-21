%IHB1DAE  �ۑ�������̃X�e�B�b�t�Ȕ����㐔������ (DAE)
%
% IHB1DAE �́Afully implicit system f(t,y,y') = 0 �Ƃ��ĕ\�킳�ꂽ
% �X�e�B�b�t�Ȕ����㐔������ ( stiff differential-algebraic equation 
% (DAE) system )�̉��̃f�������s���܂��B
%   
% Robertson problem �́AHB1ODE�ɃR�[�h���ꂽ�悤�ɁA�X�e�B�b�t��
% �����������(�n�j�������R�[�h�ɑ΂���ÓT�I�ȃe�X�g���ł��B
% ���́A���̂��̂ł��B
%
%         y(1)' = -0.04*y(1) + 1e4*y(2)*y(3)
%         y(2)' =  0.04*y(1) - 1e4*y(2)*y(3) - 3e7*y(2)^2
%         y(3)' =  3e7*y(2)^2
%
%
% ����Ԃɑ΂���A�������� y(1) = 1, y(2) = 0, y(3) = 0 �����Ƃ���
% ������܂��B
%
% �����̔����������́A����DAE�Ƃ��Ē莮�����邽�߂Ɏg�p
% �ł�����`�̕ۑ����𖞂����܂��B
%
%         0 =  y(1)' + 0.04*y(1) - 1e4*y(2)*y(3)
%         0 =  y(2)' - 0.04*y(1) + 1e4*y(2)*y(3) + 3e7*y(2)^2
%         0 =  y(1)  + y(2) + y(3) - 1
%
% ���̖��́ALSODI [1] �̏����ɂ����ė�Ƃ��ėp�����܂��B
% �����̂Ȃ����������͎����ł����A���� y(3) = 1e-3 ���A�������̃e�X�g��
% �g�p����܂��B�ΐ��X�P�[���́A�����ԊԊu�̉����v���b�g���邽�߂�
% �K���Ă��܂��By(2) �͏������A���̎�ȕω��͔�r�I�Z���ԂŋN����܂��B
% �]���āALSODI �̏����́A���̃R���|�[�l���g�ɂ��āA�͂邩�ɏ�������΋��e
% �덷���w�肵�܂��B�܂��A���̗v�f�ƂƂ��Ƀv���b�g����ꍇ�A1e4 ����Z����܂��B% �R�[�h�̒ʏ�̏o�͂́A���̗v�f�̐U�镑�����͂�����Ƃ͎����܂���B�]���āA
% ���̖ړI�̂��߂ɁA�ǉ��̏o�͂��w�肳��܂��B
%   
%   [1]  A.C. Hindmarsh, LSODE and LSODI, two new initial value ordinary
%        differential equation solvers, SIGNUM Newsletter, 15 (1980), 
%        pp. 10-11.
%   
% �Q�l ODE15I, ODE15S, ODE23T, ODESET, HB1ODE, HB1DAE, @.

%   Mark W. Reichelt and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
