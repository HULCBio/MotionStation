% FNCHG   �^�̍\���v�f�̕ύX
%
% FNCHG(FN,PART,VALUE) �́AFN �̎w�肳�ꂽ PART ��^����ꂽ VALUE ��
% �ύX���܂��B
% PART �́A�ȉ���(�擪�̃L�����N�^)�̂����ꂩ�ɂȂ�܂��B
%      'dimension'     �֐��̃^�[�Q�b�g�̎���
%      'interval'      �֐��̊�{���
%
% ������ PART �̍Ō�ɕ��� z ������ƁAPART �ɑ΂��Ďw�肳�ꂽ VALUE ��
% �ǂ̃`�F�b�N���ȗ����AFN �ƈ�v�����܂��B
%
% ���: FNDIR �́AN�����̒l�����֐��ɓK�p���ꂽ�Ƃ��ł��A�x�N�g���l��
% �֐����o�͂��܂��B����́A�ȉ��̂悤�ɏC�����邱�Ƃ��ł��܂��B
%
%      fdir = fnchg( fndir(f,direction), ...
%                    'dim',[fnbrk(f,'dim'),size(direction,2)] );
%
% �Q�l : FNBRK


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
