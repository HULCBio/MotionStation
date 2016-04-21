% QUANTIZ   �ʎq���C���f�b�N�X�Ɨʎq�������o�͒l���쐬
%
% INDX = QUANTIZ(SIG, PARTITION) �́A����|�C���g PARTITION �Ɋ�Â��āA
% ���͐M�� SIG �̗ʎq���C���f�b�N�X INDEX ���쐬���܂��BINDX �̊e�v�f�́A
% �͈�[0 : N-1]�ɂ��� N �̐�����1�ł��BPARTITION �́A���E���w�肷��
% �����ɏ����� N-1�x�N�g���ł��BINDX = 0, 1, 2, ..., N-1�̗v�f�́A�͈�
% (-Inf, PARTITION(1)], (PARTITION(1), PARTITION(2)], (PARTITION(2), 
% PARTITION(3)], ..., (PARTITION(N-1), Inf) �� SIG ��\���܂��B
% 
% [INDX, QUANT] = QUANTIZ(SIG, PARTITION, CODEBOOK) �́AQUANT �̗ʎq����
% �o�͒l���쐬���܂��BCODEBOOK �́A�o�͏W�����܂ޒ��� N �̃x�N�g���ł��B
% 
% [INDX, QUANT, DISTOR] = QUANTIZ(SIG, PARTITION, CODEBOOK) �́A�ʎq����
% ����c�ݒl DISTOR ���o�͂��܂��B
% 
% ���̃c�[���{�b�N�X�ɂ́A�����ʎq���֐�������܂���B���̂悤�ɊȒP��
% �����v�Z���s�����Ƃ��ł��邩��ł��B
% 
%       Y = CODEBOOK(INDX+1)
%
% �Q�l�F LLOYDS, DPCMENCO, DPCMDECO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $
