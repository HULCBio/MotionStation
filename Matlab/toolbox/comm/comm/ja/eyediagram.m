% EYEDIAGRAM �A�C�p�^�[���̐���
% 
% EYEDIAGRAM(X, N) �́A�e�g���[�X�ɂ� N �T���v���ŁAX �̃A�C�p�^�[����
% �������܂��BN ��1���傫�������łȂ���΂Ȃ�܂���BX �ɂ́A�����܂���
% ���f���̃x�N�g�����A���邢��2��̍s��i1��ڂ������M���A2��ڂ�����
% �M���j���Ƃ邱�Ƃ��ł��܂��BX �������x�N�g���̏ꍇ�́AEYEDIAGRAM ��
% ��̃A�C�p�^�[���𐶐����܂��BX ��2�s�̍s�񂩕��f���x�N�g���̏ꍇ�́A
% EYEDIAGRAM ��2�̃A�C�p�^�[���𐶐����܂��B1�͎����i�����j�M���ŁA
% ����1�͋����i�����j�M���ɂ��ẴA�C�p�^�[���ł��BEYEDIAGRAM �́A
% 1�Ԗڂ̓_�Ƃ���ȍ~�̖� N �Ԗڂ̓_���A�����̒��S�ɒu���悤�Ƀv���b�g
% ���܂��B
% 
% EYEDIAGRAM(X, N, PERIOD) �́A�w�肵���g���[�X������ X �̃A�C�p�^�[����
% �������܂��BPERIOD �͉����͈̔͂����肷�邽�߂Ɏg���܂��BPERIOD ��
% ���̐��łȂ���΂Ȃ�܂���B�����͈̔͂� -PERIOD/2 ���� +PERIOD/2 ��
% �Ȃ�܂��BPERIOD �̃f�t�H���g�l��1�ł��B
%
% EYEDIAGRAM(X, N, PERIOD, OFFSET) �́A�I�t�Z�b�g������ X �̃A�C�p�^�[��
% �𐶐����܂��BOFFSET�́A�����̒��S�_���A�J�n�_�Ƃ���ȍ~�̖� N�Ԗڂ̓_��
% (OFFSET+1) �ԖڂƂȂ�悤�Ɍ���Â��܂��BOFFSET�� 0 <= OFFSET < N ��
% �͈͂́A�񕉂̐����łȂ���΂Ȃ�܂���BOFFSET �̃f�t�H���g�l�� 0 �ł��B
% 
% EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING) �́APLOTSTRING �ŋL�q���ꂽ
% ���C���^�C�v�A�v���b�g�V���{���A�F�� X �̃A�C�p�^�[���𐶐����܂��B
% PLOTSTRING �� PLOT �֐��Ŏg���镶������w�肷�邱�Ƃ��ł��܂��B
% PLOTSTRING �̃f�t�H���g�l�� 'b-' �ł��B
%
% H = EYEDIAGRAM(...) �́A�A�C�p�^�[���𐶐����A�A�C�p�^�[�����v���b�g
% ���邽�߂Ɏg�p�����t�B�M���A�̃n���h����Ԃ��܂��B
%
% H = EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING, H) ��
% EYEDIAGRAM(X, N, PERIOD, OFFSET, PLOTSTRING, H) �́A�t�B�M���A�n���h��
% ���g���ăA�C�p�^�[���𐶐����܂��BH �́AEYEDIAGRAM �ɂ���đO�ɐ�����
% �ꂽ�t�B�M���A�́A�L���ȃn���h���łȂ���΂Ȃ�܂���BH �̃f�t�H���g�l
% �� [] �ŁA���̏ꍇ EYEDIAGRAM �͐V�K�̃t�B�M���A���쐬���܂��BHOLD ��
% ���� EYEDIAGRAM �t�B�M���A�ɑ΂��Ă͋@�\���܂���B
%
% �Q�l�F SCATTERPLOT, PLOT, SCATTEREYEDEMO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2003/06/23 04:34:28 $

