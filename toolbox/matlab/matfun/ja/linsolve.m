%LINSOLVE ���`�V�X�e�� A*X=B �������܂�
% X = LINSOLVE(A,B) �́AA �� �����s��̏ꍇ�A�����s�{�b�g��p���� 
% LU �������g�p���A�����łȂ��ꍇ�A��s�{�b�g��p���� QR �������g�p
% ���āA���`�V�X�e�� A*X=B �������܂��BA ���A�����s��ɑ΂��� ill 
% conditioned�ł���A��`�s��ɑ΂��ă����N�����̏ꍇ�A���[�j���O��
% �\������܂��B
%
% [X, R] = LINSOLVE(A,B) �́A�����̃��[�j���O��\�������A�����s���
% �΂��� A �̏������̋t�� R�A����сAA �� ��`�s��̏ꍇ�AA �̃����N��
% �o�͂��܂��B
%   
% X = LINSOLVE(A,B,OPTS) �́A�\���� OPTS �ɂ��L�q�����A�s�� A �̓���
% �ɂ�茈�肳���K���ȃ\���o��p���Đ��`�V�X�e�� A*X=B �������܂��B
% OPTS �̃t�B�[���h�́A�_���l���܂ޕK�v������܂��B
% ���ׂẴt�B�[���h�̒l�́A�f�t�H���g�� false �ł��B
% A �����̂悤�ȓ����������ǂ������m���߂�e�X�g�͍s���܂���B
%
% �ȉ��́A�g�p�\�ȃt�B�[���h���Ƃ���ɑΉ�����s��̓�����
% ���X�g�ł��B
%
% �t�B�[���h�� : �s�����
% ------------------------------------------------
%  LT         : ���O�p
%  UT         : ��O�p
%  UHESS      : �� Hessenberg
%  SYM        : ���Ώ� �܂��� ���f Hermitian
%  POSDEF     : ����
%  RECT       : ��ʍs��
%  TRANSA     : (����) A �̓]�u
%   
% ���̕\�́A�I�v�V�����̉\�ȑg���������ׂċ����Ă��܂��B
%
%  LT  UT  UHESS  SYM  POSDEF  RECT  TRANSA
%  ----------------------------------------
%  T   F   F      F    F       T/F   T/F
%  F   T   F      F    F       T/F   T/F
%  F   F   T      F    F       F     T/F
%  F   F   F      T    T       F     T/F
%  F   F   F      F    F       T/F   T/F
%
% ���: 
%  A = triu(rand(5,3)); x = [1 1 1 0 0]'; b = A'*x;
%  y1 = (A')\b         
%  opts.UT = true; opts.TRANSA = true;
%  y2 = linsolve(A,b,opts)
%  
% �Q�l MLDIVIDE, SLASH.

%   Copyright 1984-2003 The MathWorks, Inc. 
