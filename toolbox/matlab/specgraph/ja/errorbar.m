% ERRORBAR   �G���[�o�[�̃v���b�g
% 
% ERRORBAR(X,Y,L,U) �́A�x�N�g�� L �� U �Ŏw�肵���G���[�o�[�����x�N�g��
% X �ƃx�N�g�� Y �̃O���t���v���b�g���܂��BL �� U �́AY �̊e�_�ɑ΂���
% �덷�̏���Ɖ������܂�ł��܂��B�e�G���[�o�[�̒����́AL(i) + U(i) �ŁA
% �_ (X,Y) �̏㉺�ɂ��ꂼ�꒷���� U(i) �� L(i) �̐����ɂȂ�܂��B�x�N�g�� 
% X,Y,L,U �́A���ׂē��������łȂ���΂Ȃ�܂���BX,Y,L,U ���s��̏ꍇ�́A
% �e�񖈂ɕʁX�̃��C�����쐬���܂��B
%
% ERRORBAR(X,Y,E) �܂��� ERRORBAR(Y,E) �́A�G���[�o�[ [Y-E Y+E] ������
% Y ���v���b�g���܂��BERRORBAR(...,'LineSpec') �́A������ 'LineSpec' ��
% �w�肵���J���[�ƃ��C���X�^�C�����g���܂��B�g�p�\�Ȓl�ɂ��ẮA
% PLOT ���Q�Ƃ��Ă��������B
%
% ERRORBAR(AX,...) �́AGCA�̑����AX�Ƀv���b�g���܂��B
%
% H = ERRORBAR(...) �́Aerrorbar�V���[�Y�I�u�W�F�N�g�̃n���h���ԍ�����
% �Ȃ�x�N�g����H�ɏo�͂��܂��B
%
% ���ʌ݊���
% ERRORBAR('v6',...) �́AMATLAB 6.5����т���ȑO�̃o�[�W�����Ƃ̌݊���
% �̂��߁Aerrorbar�V���[�Y�I�u�W�F�N�g�̑����line�I�u�W�F�N�g���쐬��
% �܂��B
%  
% ���Ƃ��΁A
% 
%    x = 1:10;
%    y = sin(x);
%    e = std(y)*ones(size(x));
%    errorbar(x,y,e)
% 
% �́A�P�ʕW���΍��̑Ώ̂ȃG���[�o�[��`�悵�܂��B


%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2002 The MathWorks, Inc. 
