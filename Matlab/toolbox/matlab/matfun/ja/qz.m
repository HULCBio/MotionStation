% QZ   ��ʉ��ŗL�l�ɑ΂���QZ����
% 
% [AA, BB, Q, Z, V] = QZ(A,B) �́A�����s�� A �� B �ɑ΂��āAQ*A*Z = AA ����
% Q*B*Z = BB �ł���悤�ȏ�O�p�s�� AA �� BB�A����Z�ƉE��Z�ɂ��ϊ�
% �s����܂ރ��j�^���s�� Q �� Z�A��ʌŗL�x�N�g���s�� V ���o�͂��܂��B
% 
% [AA, BB, Q, Z, V, W] = QZ(A,B) �́A�񂪈�ʉ��ŗL�x�N�g���ł���s�� V �� 
% W ���o�͂��܂��B
%
% ���f�s��ɑ΂��āAAA �� BB �͎O�p�s��ɂȂ�܂��B�����s��ɑ΂��āAQZ
% (A,B,'real') �́A1�s1�񂨂��2�s2��̑Ίp�u���b�N���܂ޏ��O�p�s�� AA ����
% ���������s���A����AQZ(A,B,'complex') �́A�O�p�s�� AA �����\�ȕ��f
% �������s���܂��B���o�[�W�����Ƃ̌݊����̂��߁A'complex' ���f�t�H���g�ł��B
% 
% AA���O�p�s��̏ꍇ�́AAA �� BB �̑Ίp�v�f
%       alpha = diag(AA), beta = diag(BB),
% �́A
%       A*V*diag(beta) = B*V*diag(alpha)
%       diag(beta)*W'*A = diag(alpha)*W'*B
% �𖞂�����ʉ��ŗL�l�ł��B
%
%       lambda = eig(A,B)
% �ɂ��o�͂����ŗL�l�́Aalpha��beta�̔䗦�ł��B
%       lambda = alpha./beta
% AA �����O�p�s��łȂ��ꍇ�́A�t���V�X�e���̌ŗL�l�𓾂邽�߂ɁA2�s2��
% �̃u���b�N���폜����K�v������܂��B
% 
% �Q�l ORDQZ, SCHUR, EIG.

%   Copyright 1984-2002 The MathWorks, Inc. 

