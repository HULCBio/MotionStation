% MAT2STR   �s���eval�ŉ\�ȕ�����ɕϊ�
% 
% STR = MAT2STR(MAT) �́A�s�� MAT ���AEVAL(STR) ���I���W�i���̍s���
% �o�͂���悤��MATLAB������ɕϊ����܂�(���x�͖�15���ł�)�B�X�J���łȂ�
% �s��́A������ [] ���܂ޕ�����ɕϊ�����܂��B
%
% STR = MAT2STR(MAT,N) �́AN ���̐��x�ŕϊ����܂��B
%
% STR = MAT2STR(MAT, 'class') �́AMAT���܂܂��N���X���ŕ�������쐬
% ���܂��B���̃I�v�V�����́ASTR�̎��s���ʂ��N���X�����܂ނ��Ƃ�ۏ؂��܂��B
%
% STR = MAT2STR(MAT, N, 'class') �́AN���̐��x�𗘗p���A�N���X�����܂�
% �܂��B
%
% ���
% 
%     mat2str(magic(3)) �́A������ '[8 1 6; 3 5 7; 4 9 2]' ���o�͂��܂��B
%     a = int8(magic(3))
%     mat2str(a,'class') �́A������'int8([8 1 6; 3 5 7; 4 9 2])'�𐶐�
%     ���܂��B
%
% �Q�l�FNUM2STR, INT2STR, SPRINTF, CLASS, EVAL.


%   Copyright 1984-2002 The MathWorks, Inc. 
