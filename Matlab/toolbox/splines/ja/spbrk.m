% SPBRK   B-�^�܂���BB-�^�̍\���v�f
%
% [KNOTS,COEFS,N,K,D] = SPBRK(SP) �́ASP ����B-�^���\���v�f�ɕ������A
% �o�͈����ɂ���Ďw�肳�ꂽ���̂Ɠ��������o�͂��܂��B
%
% OUT1 = SPBRK(SP,PART) �́A�ȉ��̕������1��(�̎n�܂�̃L�����N�^)�ł���
% ������ PART �ɂ���Ďw�肳�ꂽ�\���v�f���o�͂��܂��B: 
% 'knots' �܂��� 't', 'coefs', 'number', 'order', 'dimension', 'interval',
% 'breaks'
%
% PART ���A1�s2��̍s�� [A,B] �̏ꍇ�A�[�_ A �� B ������Ԃւ� SP ����
% �X�v���C���̐���/�g�����A�����^�Ƃ��ďo�͂���܂��B
%
% [OUT1,...,OUTo] = SPBRK(SP, PART1,...,PARTi) �́Ao<=i �̂Ƃ��ɁAj=1:o 
% �ł̕����� PARTj �ɂ���Ďw�肳�ꂽ�v�f�� OUTj �ɏo�͂��܂��B
%
% SPBRK(SP) �́A�����o�͂��܂��񂪁A���ׂĂ̍\���v�f��\�����܂��B
%
% �Q�l : PPBRK, FNBRK, RSBRK, RPBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
