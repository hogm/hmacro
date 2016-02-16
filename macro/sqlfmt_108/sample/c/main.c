/*
 * プログラムファイル名
 * main.c
 *
 * 説明
 * sqlfmt.dll 内のエクスポート関数をＣ言語から利用する例
 * sqlfmt.lib を静的リンクすることにより関数をインポートします。
 * sqlfmt.dll の有無はプログラムの起動時にチェックされます。
 * 実行時には sqlfmt.dll が環境変数 PATH の通う場所へ配置されている
 * 必要があります。
 * コマンド例 set path=%path%;..\..\
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tStmtStyle.h>
#include <psExpFuncs.h>
#define BUFF_SIZ_1                150  /* 不足しているバッファサイズ */
#define BUFF_SIZ_2                512  /* 十分なバッファサイズ */

/*
 * インポート関数実行後のステータスをレポート
 */
	void
vReport(
	const char *szFmtStmt
	, const tStmtStyle *rStmtStyle
	, const int iRet
){
	if (iRet == 0){
		printf("整形後の文：\n%s\n", szFmtStmt);
		printf("バイト数：%u\n", rStmtStyle->iStrLen);
	} else {
		printf("文の整形に失敗しました。エラー番号:%d\n", iRet);
	}
}

/*
 * 中心処理
 */
int main(void){
	int iRet; /* 関数の戻り値を格納する */
	static char szOrgStmt[] = /* 整形前の文を指し示す */
		"set serveroutput on; "
		"declare cursor c1 is select empno, ename from emp; "
		"begin for r1 in c1 loop dbms_output.put(r1.empno); "
		"dbms_output.put('='); dbms_output.put_line(r1.ename); "
		"end loop; end;/"
	;
	char *szFmtStmt; /* 整形後の文を指し示す */
	char szFmtStmtFew[BUFF_SIZ_1 + 1];
	char szFmtStmtMtc[BUFF_SIZ_2 + 1];
	/*
	 * 下記の構造体とマクロは tStmtStyle.h をインクルードする事により使用できます。
	 */
	tStmtStyle rStmtStyle;
	/*
	 * 整形スタイルの指定
	 * （必ず呼び出し側で初期化してから使用して下さい。）
	 */
	strcpy(rStmtStyle.szIdtStr, "\t");
	rStmtStyle.iMinNumComma = 14;
	rStmtStyle.iMinPartSize = 50;
	/********
	 * 整形済み文がインポート関数内で動的に確保された
	 * バッファへ格納され、そのポインタが戻される例
	 ********/
	printf("\n\n======= Case 1. =======\n\n");
	iRet = iFmtStmt(szOrgStmt, &szFmtStmt, &rStmtStyle);
	vReport(szFmtStmt, &rStmtStyle, iRet);
	if (iRet == 0){
		/*
		 * 整形が成功している時は必ず free する
		 */
		free(szFmtStmt);
	}
	/********
	 * 整形済み文を静的に確保したバッファへ格納する例
	 * （格納先バッファを親言語側で準備する）
	 ********/
	/* 不十分なサイズのバッファを準備 */
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
	/* 十分なサイズのバッファを準備 */
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
