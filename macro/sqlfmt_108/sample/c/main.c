/*
 * �v���O�����t�@�C����
 * main.c
 *
 * ����
 * sqlfmt.dll ���̃G�N�X�|�[�g�֐����b���ꂩ�痘�p�����
 * sqlfmt.lib ��ÓI�����N���邱�Ƃɂ��֐����C���|�[�g���܂��B
 * sqlfmt.dll �̗L���̓v���O�����̋N�����Ƀ`�F�b�N����܂��B
 * ���s���ɂ� sqlfmt.dll �����ϐ� PATH �̒ʂ��ꏊ�֔z�u����Ă���
 * �K�v������܂��B
 * �R�}���h�� set path=%path%;..\..\
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tStmtStyle.h>
#include <psExpFuncs.h>
#define BUFF_SIZ_1                150  /* �s�����Ă���o�b�t�@�T�C�Y */
#define BUFF_SIZ_2                512  /* �\���ȃo�b�t�@�T�C�Y */

/*
 * �C���|�[�g�֐����s��̃X�e�[�^�X�����|�[�g
 */
	void
vReport(
	const char *szFmtStmt
	, const tStmtStyle *rStmtStyle
	, const int iRet
){
	if (iRet == 0){
		printf("���`��̕��F\n%s\n", szFmtStmt);
		printf("�o�C�g���F%u\n", rStmtStyle->iStrLen);
	} else {
		printf("���̐��`�Ɏ��s���܂����B�G���[�ԍ�:%d\n", iRet);
	}
}

/*
 * ���S����
 */
int main(void){
	int iRet; /* �֐��̖߂�l���i�[���� */
	static char szOrgStmt[] = /* ���`�O�̕����w������ */
		"set serveroutput on; "
		"declare cursor c1 is select empno, ename from emp; "
		"begin for r1 in c1 loop dbms_output.put(r1.empno); "
		"dbms_output.put('='); dbms_output.put_line(r1.ename); "
		"end loop; end;/"
	;
	char *szFmtStmt; /* ���`��̕����w������ */
	char szFmtStmtFew[BUFF_SIZ_1 + 1];
	char szFmtStmtMtc[BUFF_SIZ_2 + 1];
	/*
	 * ���L�̍\���̂ƃ}�N���� tStmtStyle.h ���C���N���[�h���鎖�ɂ��g�p�ł��܂��B
	 */
	tStmtStyle rStmtStyle;
	/*
	 * ���`�X�^�C���̎w��
	 * �i�K���Ăяo�����ŏ��������Ă���g�p���ĉ������B�j
	 */
	strcpy(rStmtStyle.szIdtStr, "\t");
	rStmtStyle.iMinNumComma = 14;
	rStmtStyle.iMinPartSize = 50;
	/********
	 * ���`�ςݕ����C���|�[�g�֐����œ��I�Ɋm�ۂ��ꂽ
	 * �o�b�t�@�֊i�[����A���̃|�C���^���߂�����
	 ********/
	printf("\n\n======= Case 1. =======\n\n");
	iRet = iFmtStmt(szOrgStmt, &szFmtStmt, &rStmtStyle);
	vReport(szFmtStmt, &rStmtStyle, iRet);
	if (iRet == 0){
		/*
		 * ���`���������Ă��鎞�͕K�� free ����
		 */
		free(szFmtStmt);
	}
	/********
	 * ���`�ςݕ���ÓI�Ɋm�ۂ����o�b�t�@�֊i�[�����
	 * �i�i�[��o�b�t�@��e���ꑤ�ŏ�������j
	 ********/
	/* �s�\���ȃT�C�Y�̃o�b�t�@������ */
	printf("\n\n======= Case 2. =======\n\n");
	iRet = iCopyToPreparedStr(
		szOrgStmt
		, rStmtStyle.szIdtStr
		, rStmtStyle.iMinNumComma
		, rStmtStyle.iMinPartSize
		, szFmtStmtFew
		, &rStmtStyle.iStrLen
		, sizeof(szFmtStmtFew)
	);
	vReport(szFmtStmt, &rStmtStyle, iRet);
	printf("\n\n======= Case 3. =======\n\n");
	/* �\���ȃT�C�Y�̃o�b�t�@������ */
	iRet = iCopyToPreparedStr(
		szOrgStmt
		, rStmtStyle.szIdtStr
		, rStmtStyle.iMinNumComma
		, rStmtStyle.iMinPartSize
		, szFmtStmtMtc
		, &rStmtStyle.iStrLen
		, sizeof(szFmtStmtMtc)
	);
	vReport(szFmtStmt, &rStmtStyle, iRet);
	return iRet;
}
