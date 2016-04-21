% D2CM   ���U LTI �V�X�e����A�����Ԃɕϊ�
%
% [Ac,Bc,Cc,Dc] = D2CM(A,B,C,D,Ts,'method') �́A'method'�Őݒ肵�����@��
% �g���āA���U���ԏ�ԋ�ԃV�X�e����A�����ԃV�X�e���ɕϊ����܂��B
% 
%  'zoh'         ���͂Ƀ[�����z�[���h�����肵�ĘA�����Ԃɕϊ����܂��B
%  'tustin'      ���W���ւ̑o�ꎟ(Tustin)�ϊ����g���āA�A�����Ԃɕϊ����܂��B
%  'prewarp'     �������̎��g���ŁA�ϊ��O�ƕϊ������v�����鐧��̂��ƂŁA
%                �o�ꎟ(Tustin)�ߎ����g���āA�A�����Ԃɕϊ����܂��B�t���I��
%                �����Ƃ��ėՊE���g����ݒ肵�܂��B���Ƃ��΁A
%                D2CM(A,B,C,D,Ts,'prewarp',Wc) �Ƃ��Ďg���܂��B
%  'matched'     matched pole-zero �@���g���āASISO �V�X�e����A�����Ԃ�
%                �ϊ����܂��B
% 
% [NUMc,DENc] = D2CM(NUM,DEN,Ts,'method') �́A���U���ԑ������`�B�֐� 
% G(z) = NUM(z)/DEN(z) ��'method' �Őݒ肵�����@���g���āA�A������ 
% G(s) = NUMc(s)/DENc(s) �ɕϊ����܂��B
%
% ���ӁF 'foh' �́A�g�p�ł��܂���B
%
% �Q�l : D2C, C2DM.


%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:33 $
