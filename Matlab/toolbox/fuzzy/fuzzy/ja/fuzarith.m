% FUZARITH �t�@�W�B�㐔
% 
% C = FUZARITH(X,A,B,OPERATOR) �́A�̈� X �̃t�@�W�B�W�� A �� B �ɁAOP-
% ERATOR ��K�p�������ʂƂ��ăt�@�W�B�W�� C ���o�͂��܂��BA�AB ����� 
% X �́A�������̃x�N�g���łȂ���΂Ȃ�܂���BOPERATOR �́A������ 'sum'
% 'sub'�A'prod'�A'div' �̒���1�łȂ���΂Ȃ�܂���B�o�͂����t�@�W�B
% �W�� C �́AA �� B �ƒ����������ł����x�N�g���ł��B���̊֐��ł́A���
% �ł̉��Z���g�p���邱�ƂƁA���̂��Ƃ�z�肵�Ă��邱�Ƃɒ��ӂ��Ă�����
% ���B
% 
% 1.A �� B �́A�ʃt�@�W�B�W���ł��B
% 
% 2.X �͈̔͂̊O�ŁAA �� B �̃����o�V�b�v�K����0�ł��B
%
% �t�@�W�B���Z�́A"divide by zero"���b�Z�[�W���쐬���܂��B�������Ȃ���A
% ���̊֐��̐��x�ɉe���͂���܂���(�������AVAX �� Cray �Ȃǂ� IEEE ���Z
% ���g���Ă��Ȃ��}�V���ł͖�肪������ꍇ������܂�)�B
%
% ���
%    point_n = 101;                      MF�̉𑜓x������
%    min_x = -20; max_x = 20;            �̈� [min_x,max_x]
%    x = linspace(min_x,max_x,point_n)';
%    A = trapmf(x,[-10 -2 1 3]);        A�͑�`�t�@�W�B�W��
%    B = gaussmf(x,[2 5]);              B�̓K�E�X�t�@�W�B�W��
%    C1 = fuzarith(x,A,B,'sum');
%    subplot(2,2,1);
%    plot(x,A,'y--',x,B,'m:',x,C1,'c');
%    title('fuzzy addition A+B');
%    C2 = fuzarith(x,A,B,'sub');
%    subplot(2,2,2);
%    plot(x,A,'y--',x,B,'m:',x,C2,'c');
%    title('fuzzy subtraction A-B');
%    C3 = fuzarith(x,A,B,'prod');
%    subplot(2,2,3);
%    plot(x,A,'y--',x,B,'m:',x,C3,'c');
%    title('fuzzy multiplication A*B');
%    C4 = fuzarith(x,A�AB,'div');
%    subplot(2,2,4);
%    plot(x,A,'y--'.x.B.'m:'.x�AC4,'c');
%    title('fuzzy division A/B');



%	Copyright 1994-2002 The MathWorks, Inc. 
