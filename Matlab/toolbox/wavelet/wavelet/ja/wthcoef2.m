% WTHCOEF2   2�����ŃE�F�[�u���b�g�W���̃X���b�V���z�[���h����
% 'type' = 'h' ('v' �܂��� 'd') �ɑ΂��āANC = WTHCOEF2('type',C,S,N,T,SORH) �́A
% �\�t�g�X���b�V���z�[���h(SORH = 's')�A�܂��́A�n�[�h�X���b�V���z�[���h(SORH = 
% 'h') �̂����ꂩ���g���āA�x�N�g�� N �� T �Œ�`�������̂ɑ΂��āA�E�F�[�u��
% �b�g�����\�� [C,S] (WAVEDEC2 �Q��)���瓾���鐅��(�����A�Ίp)�����̌W�����o��
% ���܂��BN �͈��k����� Detail ���x���ŁAT �͑Ή�����X���b�V���z�[���h�ł��BN 
% �� T �́A���������ł��B�x�N�g�� N �́A1 < =  N(i) < =  size(S,1)-2�𖞂�������
% �ł��B 
%
% 'type' = 'h' ('v' �܂��� 'd' ) �ɑ΂��āANC = WTHCOEF2('type',C,S,N) �́AN ��
% ���Œ�`���ꂽ Detail ���x���̌W�������ׂă[���ɐݒ肷�邱�Ƃɂ���āA[C,S] ��
% �瓾��ꂽ 'type' �ɒ�߂�ꂽ�����̌W�����o�͂��܂��B
%
% NC = WTHCOEF2('a',C,S) �́AApproximation �W�����[���ɐݒ肷�邱�Ƃɂ���ē���
% ���W�����o�͂��܂��B
%
% NC = WTHCOEF2('t',C,S,N,T,SORH) �́A�\�t�g�X���b�V���z�[���h(SORH = 's')�A�܂�
% �́A�n�[�h�X���b�V���z�[���h(SORH = 'h')�̂����ꂩ���g����(WTHRESH �Q��)�A�x�N
% �g�� T �Œ�`�������̂ɑ΂��āA�E�F�[�u���b�g�����\�� [C,S] ���瓾���� D-
% etail �W�����o�͂��܂��BN �́A�X���b�V���z�[���h���K�p����� Detail ���x���ŁA
% T �́A3�� Detail �����ɓK�p�����Ή�����X���b�V���z�[���h�l�ł��BN �� T �́A
% ���������ł��B
%
% [NC,S] �́A�v�Z�̌��ʂƂ��ċ��܂�E�F�[�u���b�g�����\���ł��B
%
% �Q�l�F WAVEDEC2, WTHRESH.



%   Copyright 1995-2002 The MathWorks, Inc.
