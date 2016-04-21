% MVNRND   ���ϗʐ��K���z�̃����_���s��
%
% R = MVNRND(MU,SIGMA) �́A���σx�N�g�� MU �Ƌ����U�s�� SIGMA ���g����
% ���ϗʐ��K���z���璊�o���ꂽ�����_���x�N�g����n�sd��̍s�� R ���o��
% ���܂��BMU �́An�sd��̍s��ŁAMVNRND �́AMU �̑Ή�����s���g���� R ��
% �e�s�𐶐����܂��BSIGMA �́Ad�sd��̑Ώ̔�����s�񂩁Ad-d-n�z��ł��B
% SIGMA ���z��̏ꍇ�AMVNRND �́ASIGMA �̑Ή�����y�[�W���g���āA�Ⴆ��
% MVNRND �� MU(I,:) �� SIGMA(:,:,I) ���g���� R(I,:) ���v�Z����悤�ɁAR ��
% �e�s�𐶐����܂��BMU ��1�sd��̃x�N�g���̏ꍇ�AMVNRND �́ASIGMA �� 
% trailing dimension �Ɉ�v����悤�ɕ������s���܂��B
%
% R = MVNRND(MU,SIGMA,CASES) �́A���ʂ�1�sd��̕��σx�N�g���ƁA���ʂ�
% d�sd��̋����U�s�� SIGMA ���g���đ��ϗʐ��K���z���璊�o���ꂽ�����_��
% �x�N�g���� CASES�sd��̍s�� R ���o�͂��܂��B
%
% R = MVNRND(MU,SIGMA,CASES,T) �́ASIGMA == T'*T �ƂȂ� SIGMA �� 
% Cholesky���q T ��^���܂��BT �́A�G���[�`�F�b�N�͍s���܂���B
%
% [R,T] = MVNRND(...) �́A��ł����ʓI�ɃR�[�����čė��p���邱�Ƃ�
% �ł��� Cholesky���q T ���o�͂��܂��B
%
% SIGMA ��3�����z��̏ꍇ�AMVNRND �́A���� T �𖳎����A�o�� T ���쐬
% ���܂���B


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:13:15 $
