% GETFF  (�������g�̃v���b�g�̂��߂�)���g���֐��𒊏o
% 
%   [W,AMP,PHAS] = GETFF(G,NU,NY)
%
% W    : ���W�A��/�b�̎��g���X�P�[��
% AMP  : �U���֐�
% PHAS : �ʑ��֐�(�x)
% G    : FREQFUNC �t�H�[�}�b�g�̎��g���֐��BFREQFUNC ���Q�Ƃ��Ă��������B
% NU   : ���͔ԍ�(�G�����͂́A���͔ԍ�0�Ƃ��Ē�`)
%       (�f�t�H���g�͂P�BG �����ׂẴX�y�N�g�����܂ޏꍇ�A�f�t�H���g��0)
% NY   : �o�͔ԍ� (�f�t�H���g��1)
%
% G �̂������̗v�f���������o�͊֌W�ɑΉ�����ꍇ�AW, AMP, PHAS �͑Ή�
% ����񐔂������܂��B
%
% ���̏����ŁA�U���̕W���΍��ƈʑ��̕W���΍����o�͂���܂��B
%
%    [W,AMP,PHAS,SD_AMP,SD_PHAS] = GETFF(G,NU,NY)

%   Copyright 1986-2001 The MathWorks, Inc.
