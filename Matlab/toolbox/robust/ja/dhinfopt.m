% DHINFOPT �́A���C�^���[�V�����ɂ�闣�U H ���R���g���[���V���Z�V�X���s
% ���܂��B
%
% [GAM_OPT,SS_CP,SS_CL] = DHINFOPT(TSS_,GAMIND,AUX)�A�܂��́A
% [GAM_OPT,ACP,BCP,CCP,DCP,ACL,BCL,CCL,DCL] = HINFOPT(A,B1,..,GAMIND,AUX)
% 
% �́A�^����ꂽ�V�X�e�� Tcl:(TSS_) �ɑ΂��āAH �� ���C�^���[�V�������g
% ���āA���ǂ��ꂽ���[�v�V�t�g2 Riccati ���������g���āA�œK H �����䑥
% ���v�Z���܂��B"Gam_opt" �́A
%
%                   || gamma * Tcl(gamind,:)   ||
%                   ||                         ||     <= 1
%                   ||         Tcl(otherind,:) || inf
% 
%  �ɑ΂���œK"��"�ł��B�����ŁA
%       Tcl(gamind,:) �́A"��"�ŏd�ݕt�����ꂽ�s���܂݂܂��B
%       Tcl(otherind,:) �́ATcl �̑��̍s���܂݂܂��B
%  ���́F  Tcl: TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22);
%       �I�v�V�������́F
%           gamind: ���ŃX�P�[�����O�����o�͂̃C���f�b�N�X
%                   (�f�t�H���g�F���ׂĂ̏o�̓`�����l��)
%           aux   : [tol, maxgam, mingam] (�f�t�H���g�F[0.01 1 0])
%                   tol   : �C�^���[�V�������~�����ɂȂ�g�������X
% 
%                   maxgam: �ő� "gam_opt" �p�̏�������
%                   mingam: �ŏ� "gam_opt" �p�̏�������
%  �o�́F gam_opt (�œK��)
%        H-���œK�R���g���[���F  ss_cp = mksys(acp,bcp,ccp,dcp)
%        ���d�ݕt�����[�v  �F ss_cl = mksys(acl,bcl,ccl,dcl)

% Copyright 1988-2002 The MathWorks, Inc. 
