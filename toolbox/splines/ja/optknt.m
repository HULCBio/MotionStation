% OPTKNT   ��Ԃɑ΂���œK�Ȑߓ_�̋敪
%
% OPTKNT(TAU,K) �́A���� K �̃X�v���C���ɂ��f�[�^�T�C�g 
% TAU(1), ..., TAU(n) �ł̕�Ԃɑ΂��āA'�œK��' �ߓ_����o�͂��܂��B
% TAU �͑�����łȂ���΂Ȃ�܂��񂪁A����̓`�F�b�N����܂���B
%
% OPTKNT(TAU,K,MAXITER) �́A���s�����J��Ԃ��̐� MAXITER ���w�肵�܂��B
% �f�t�H���g�́A10�ł��B
%
% ���̐ߓ_��̓����ߓ_�́A�ߓ_�� TAU �����AK���̂��ׂẴX�v���C��
% f �ɑ΂��āA
%
%          integral{ f(x)h(x) : TAU(1) < x < TAU(n) } = 0
%
% �𖞑�����A��Βl�����̊֐� h(~= 0) �ɂ�����n-K�̕����ω��ł��B
%
% ���:
% Micchelli/Rivlin/Winograd��Gaffney/Powell�́A�^����ꂽ�f�[�^ x, y 
% �̎��� K �̃X�v���C����Ԃ��쐬������̕��@���ؖ����Ă��܂��B
%
%      x = sort([0, rand(1,11)*(2*pi),2*pi]); y = sin(x); k = 5;
%      sp = spapi(optknt(x,k),x,y);
%      fnplt(sp), hold on, plot(x,y,'o'), hold off
%
% �Q�l : APTKNT, NEWKNT, AVEKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
