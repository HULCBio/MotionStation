% PPBRK   pp-�^�̍\���v�f
%
% [BREAKS,COEFS,L,K,D] = PPBRK(PP) �́APP �Ɏ����ꂽpp-�^���\���v�f��
% �������A�o�͈����ɂ���Ďw�肳�ꂽ���̂Ɠ������̗v�f���o�͂��܂��B
%
% PPBRK(PP) �́A�����o�͂��܂��񂪁A���ׂĂ̍\���v�f��\�����܂��B
%
% OUT1 = PPBRK(PP,PART) �́A�ȉ��̕������1��(�̎n�܂�̃L�����N�^)��
% ���镶���� PART �ɂ���Ďw�肳�ꂽ�X�̍\���v�f���o�͂��܂��B:
% 'breaks', 'coefs', 'pieces' �܂��� 'l', 'order' �܂��� 'k',
% 'dim'ension, 'interval'
% ���΂炭�̊Ԃ́A
%    'guide'
% ���I�����ɓ����Ă���A���� PPVALU �ɑ΂��āA'A Practical Guide to Splines' 
% �Ŏg�p���ꂽpp-�^�ŕK�v�Ƃ����`���̌W���̔z����o�͂��܂��B����́A
% �x�N�g���l�A�����/�܂��́A�e���\���σX�v���C���ɑ΂��Ă͗��p�\�ł�
% ����܂���B
%
% PJ = PPBRK(PP,J) �́APP �ɂ���֐���J�Ԗڂ̑������敪��pp-�^���o��
% ���܂��B
%
% PC = PPBRK(PP,[A B]) �́APP �̊֐������ [A .. B] �ɐ���/�������ďo��
% ���܂��B[] ��^����ƁAPP �����̂܂܏o�͂���܂��B
%
% PP ��m�ϐ��X�v���C�����܂݁APART ��������łȂ��ꍇ�A����͒��� m ��
% �Z���z��łȂ���΂Ȃ�܂���B
%
% [OUT1,...,OUTo] = PPBRK(PP, PART1,...,PARTi) �́Ao<=i �ł���Ƃ��A
% j=1:o �Ƃ��āA������ PARTj �ɂ���Ďw�肳���v�f�� OUTj �ɏo�͂��܂��B
%
% ���: PP ���ŏ��̕ϐ��ɏ��Ȃ��Ƃ�4�̋敪������2�ϐ��X�v���C����
% �܂ޏꍇ�A
%
%    ppp = ppbrk(pp,{4,[-1 1]});
%
% �́A�����` [pp.breaks{1}(4) .. [pp.breaks{1}(5)] x [-1 1] ��ɗ^������
% ���̂ƈ�v����2�ϐ��X�v���C����^���܂��B
%
% �Q�l : SPBRK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
