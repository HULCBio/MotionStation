% RPBRK   rp�^�̍\���v�f
%
% OUT1 = RPBRK(RP,PART) �́A�ȉ��̕������1��(�̎n�܂�̃L�����N�^)��
% ���镶���� PART �ɂ���Ďw�肳�ꂽ�X�̍\���v�f���o�͂��܂��B:
%      'breaks', 'coefficients', 'pieces' �܂��� 'l', 'order' �܂��� 'k', 
%      'dimension', 'interval'.
%
% RPBRK(PP) �́A�����o�͂��܂��񂪁A���ׂĂ̍\���v�f��\�����܂��B
%
% PJ = RPBRK(RP,J) �́ARP �ɂ���֐���J�Ԗڂ̑������敪��rp-�^���o��
% ���܂��B
%
% PC = RPBRK(RP,[A B]) �́ARP �ɂ���֐������ [A .. B] �ɐ������ďo��
% ���܂��B
%
% RP ��m�ϐ��X�v���C�����܂݁APART ��������łȂ��ꍇ�APART �͒��� m ��
% �Z���z��łȂ���΂Ȃ�܂���B
%
% [OUT1,...,OUTo] = RPBRK(SP, PART1,...,PARTi) �́Ao<=i �ł���Ƃ��A
% j=1:o �Ƃ��āA������ PARTj �ɂ���Ďw�肳�ꂽ�\���v�f�� OUTj �ɏo��
% ���܂��B
%
% �Ⴆ�΁ARP ���ŏ��̕ϐ��ɏ��Ȃ��Ƃ�4�̋敪������2�ϐ��X�v���C����
% �܂ޏꍇ�A
%
%      rpp = rpbrk(rp,{4,[-1 1]});
%
% �́A�����` [rp.breaks{1}(4) .. [rp.breaks{1}(5)] x [-1 1] ��ɗ^��
% ������̂ƈ�v����2�ϐ��X�v���C����^���܂��B
%
% �Q�l : RPMAK, RSBRK, PPBRK, SPBRK, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
