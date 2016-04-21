% C2DM   �A�� LTI �V�X�e���𗣎U���� LTI �ɕϊ�
%
% [Ad,Bd,Cd,Dd] = C2DM(A,B,C,D,Ts,'method') �́A�A�����ԏ�ԋ�ԃV�X�e��
% (A, B, C, D)��'method'�Œ�`�������@���g���āA���U���Ԃɕϊ����܂��B
% 'method'�ɂ́A���̂����ꂩ���`���邱�Ƃ��ł��܂��B
% 
%  'zoh'         ���͂Ƀ[�����z�[���h�����肵�ė��U���Ԃɕϊ����܂��B
%  'foh'         ���͂Ɉꎟ�z�[���h�����肵�ė��U���Ԃɕϊ����܂��B
%  'tustin'      ���W���ւ̑o�ꎟ(Tustin)�ϊ����g���āA���U���Ԃɕϊ����܂��B
%  'prewarp'     �������̎��g���ŁA�ϊ��O�ƕϊ������v�����鐧��̂��ƂŁA�o
%                �ꎟ(Tustin)�ߎ����g���āA���U���Ԃɕϊ����܂��B�t���I
%                �Ȉ����Ƃ��ėՊE���g����ݒ肵�܂��B���Ƃ��΁A
%                C2DM(A,B,C,D,Ts,'prewarp', Wc) �Ƃ��Ďg���܂��B
%  'matched'     matched pole-zero �@���g���āASISO �V�X�e���𗣎U���Ԃ�
%                �ϊ����܂��B
%
% [NUMd,DENd] = C2DM(NUM,DEN,Ts,'method') �́A�A�����ԑ������`�B�֐� 
% G(s) = NUM(s)/DEN(s) ��,'method'�ɐݒ肵�����@���g���āA���U���ԑ�����
% �`�B�֐� G(z) = NUMd(z)/DENd(z) �ɕϊ����܂��B
%
% �Q�l : C2D, D2CM.


%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:29 $
