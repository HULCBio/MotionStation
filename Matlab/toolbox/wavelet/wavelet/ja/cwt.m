% CWT �@�@�A��1�����E�F�[�u���b�g�W��
% COEFS = CWT(S,SCALES,'wname') �́A���� 'wname' �Őݒ肵���E�F�[�u���b�g���g��
% �āA�����A���� SCALES �ɑ΂�����̓x�N�g�� S �̘A���E�F�[�u���b�g�W�����v�Z��
% �܂��B
%
% COEFS = CWT(S,SCALES,'wname','plot') �́A�A���E�F�[�u���b�g�ϊ��W�����v�Z���A
% ����Ƀv���b�g�\�����܂��B
%
% COEFS = CWT(S,SCALES,'wname',PLOTMODE) �́A�A���E�F�[�u���b�g�ϊ��W�����v�Z���A
% ����Ƀv���b�g�\�����܂��B�W���́APLOTMODE ���g���āA�J���[�\�����s���܂��B
% 
%   PLOTMODE = 'lvl' (�X�P�[����) �܂��́A
%   PLOTMODE = 'glb' (���ׂẴX�P�[��) �܂��́A
%   PLOTMODE = 'abslvl'�A�܂��́A'lvlabs'(��Βl�y�уX�P�[����)
%   PLOTMODE = 'absglb'�A�܂��́A'glbabs'(��Βl�y�т��ׂẴX�P�[��)
%
% CWT(...,'plot') �́ACWT(...,'absglb') �Ɠ��`�ł��B
%
% COEFS = CWT(S,SCALES,'WNAME',PLOTMODE,XLIM) �́A�A���E�F�[�u���b�g�ϊ��W�����v
% �Z���A�v���b�g�\�����܂��B�W���́AXLIM = [L R],1 < = L �y�� R < = length(S) ��
% �͈͂ŁAPLOTMODE �ɂ��F�t������܂��B
%
% a = SCALES(i) �̏ꍇ�Ab = 1 ���� ls = length(S) �͈̔͂ŃE�F�[�u���b�g�W�� 
% C(a,b) ���v�Z����A�^����ꂽ SCALE �x�N�g���̏��Ԃ� COEFS(i,:) �ɋL�������
% ���B�o�͈��� COEFS �́Ala �s ls ��̍s��ŁA�����ŁAla �́ASCALES �̒������w
% ���Ă��܂��B
%
% ���:�K�؂Ȏg�p����ȉ��ɋL�ڂ��Ă����܂��B
%      t = linspace(-1,1,512);
%      s = 1-abs(t);
%      c = CWT(s,1:32,'meyr');
%      c = CWT(s,[64 32 16:-2:2],'morl');
%      c = CWT(s,[3 18 12.9 7 1.5],'db2');
%
% �Q�l�F WAVEDEC, WAVEFUN, WAVEINFO, WCODEMAT.



%   Copyright 1995-2002 The MathWorks, Inc.
