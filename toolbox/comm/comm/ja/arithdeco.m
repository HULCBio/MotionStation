% ARITHDECO   �Z�p��������p����2�l�����̕���
%
% DSEQ = ARITHDECO(CODE, COUNTS, LEN) �́A�V���{���̗�ɑΉ�����x�N�g�� 
% CODE(ARITHENCO ��p���Đ������ꂽ)��2�l�Z�p�����𕜍����܂��B
% �x�N�g�� COUNTS �́A�V���{���̃J�E���g(�\�[�X�̃A���t�@�x�b�g�̊e�V��
% �{�����e�X�g�̃f�[�^�Z�b�g�Ŕ��������)���܂݁A�\�[�X�̓��v�ʂ�����
% �܂��BLEN �́A���������V���{���̐��ł��B
%   
% ���: 
%   �A���t�@�x�b�g {x, y, z} �ł���\�[�X���l���܂��B�\�[�X�����177��
%   �V���{���e�X�g�f�[�^�Z�b�g�́A29�� x �ƁA48�� y �ƁA100�� z 
%   ���܂�ł��܂��B yzxzz�̗�𕄍������邽�߂ɁA�����̃R�}���h��
%   �g�p���܂��B:
%
%       seq = [2 3 1 3 3];
%       counts = [29 48 100];
%       code = arithenco(seq, counts)   
%            
%   ���̃R�[�h�𕜍�����(����сA���̃R�[�h�������V���{����̍Đ�)�ɂ́A
%   ���̃R�}���h���g�p���܂��B:
%            
%       dseq = arithdeco(code, counts, 5)
%            
% �Q�l:  ARITHENCO.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2003/06/23 04:34:07 $
