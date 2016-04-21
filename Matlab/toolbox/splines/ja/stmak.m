% STMAK   st-�^�̊֐��̑g����
%
% ST = STMAK(CENTERS, COEFS) �́A���̊֐���st-�^�� ST �Ɋi�[���܂��B
%
%         x |--> sum_j COEFS(:,j)*psi(x - CENTERS(:,j))
% ������ psi �́A
%          psi(x) := |x|^2 log(|x|^2) 
%
% �ł���A|x| �́A�x�N�g�� x �̃��[�N���b�h�̒����ł��B
% CENTERS �� COEFS �́A�����񐔂����s��łȂ���΂Ȃ�܂���B
%
% ST = STMAK(CENTERS, COEFS, TYPE) �́A���̊֐���st-�^�� ST �Ɋi�[
% ���܂��B
%
%         x |--> sum_j COEFS(:,j)*psi_j(x)
%
% �����ŁApsi_j �́A������ TYPE �Ɏ������悤�ɁA'tp00', 'tp10', 'tp01'��
% �����ꂩ�ł��B'tp' ���f�t�H���g�ł��B
% �����̗l�X�ȃ^�C�v�ɂ��Ă̈ȉ��̋L�q�ɂ����āAc_j �́ACENTERS(:,j) 
% �ŁAn �́A���̐��A���Ȃ킿�Asize(COEFS,2) �ɓ������Ȃ�܂��B
%
% 'tp00': 2�ϐ�thin-plate�X�v���C��
% psi_j(x) := phi(|x - c_j|^2), j=1:n-3, �����ŁAphi(t) := t log(t) �ł��B
% psi_{n-2}(x) := x(1); psi_{n-1}(x) := x(2); psi_n(x) := 1 �ł��B
%
% 'tp10': 1�Ԗڂ̈����Ɋւ���thin-plate�X�v���C���̕Δ���
% psi_j(x) := phi(|x - c_j|^2) , j=1:n-1, �����ŁA  
% phi(t) := (D_1 t)(log(t)+1)  �ł���A D_1 t �́Ax(1) �ɂ��Ă�
% t := t(x) := |x - c|^2 �̔����ł��Bpsi_n(x) := 1 �ł��B
%
% 'tp01': 2�Ԗڂ̈����Ɋւ���thin-plate�X�v���C���̕Δ���
% psi_j(x) := phi(|x - c_j|^2) , j=1:n-1, �����ŁA
% phi(t) := (D_2 t)(log(t)+1)  �ł���A D_2 t �́Ax(2) �ɂ��Ă�
% t := t(x) := |x - c|^2 �̔����ł��Bpsi_n(x) := 1 �ł��B
%
% 'tp': ������2�ϐ�thin-plate �X�v���C�� (�f�t�H���g) 
% psi_j(x) := phi(|x - c_j|^2), j=1:n, �����ŁAphi(t) := t log(t)�ł��B
%  
% ST = STMAK(CENTERS, COEFS, TYPE, INTERV) �́Ast-�^�̊�{��Ԃ��A�`�� 
% {[a1,b1],...} �����^����ꂽ INTERV �ɐݒ肵�܂��B
% INTERV �̃f�t�H���g�̒l�́A���ׂĂ̒��S���܂ލŏ��̎����s�ȃ{�b�N�X
% �ł��B���Ȃ킿�A[ai,bi] �� [min(CENTERS(i,:)),max(CENTERS(i,:))] �ł��B
% �������A���̗�O������܂��B1�������S������ꍇ�A��{��Ԃ́A������
% �p�Ƃ��Ă��̗B��̒��S�����ӂ̒�����1�̃{�b�N�X�ł��B 
%
% �Q�l : STBRK, STCOL, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
