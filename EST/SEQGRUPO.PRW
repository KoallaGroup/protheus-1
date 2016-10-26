#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01
#include "topconn.ch"        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

User Function SEQGRUPO()        // incluido pelo assistente de conversao do AP5 IDE em 25/06/01

//���������������������������������������������������������������������Ŀ
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//�����������������������������������������������������������������������

//SetPrvt("CINIGRUPO,NCONTADOR,CCONTADOR,")

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    �SEQGRUPO  � Autor � Luiz Carlos da Cruz   � Data � 05-10-98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Montar um contador de c�digo de produto do SB1, para cada   ���
���          �grupo de material. Esses contadores, nesse rdmake, est�o na ���
���          �tabela 98, do SX5.                                          ���
�������������������������������������������������������������������������Ĵ��
���Uso       �Fun��o disparada pelo gatilho 001 do B1_GRUPO.              ���
�������������������������������������������������������������������������Ĵ��
���1) Criar uma tabela no SX5: na chave p�r o nome dos grupos e no conte�-���
���   do o sequencial de cada um. Nesse rdmake a tabela � 98;             ���
���2) Tornar o B1_GRUPO obrigat�rio e anterior do B1_COD. Colocar o B1_COD���
���   inibido para digita��o;                                             ���
���3) Criar um gatilho do B1_GRUPO para o B1_COD, chamando esse rdmake;   ���
���4) Este rdmake posiciona o SX5  na tabela 90, no grupo digitado e re-  ���
���   torna o conte�do acrescido de um.                                   ���
���5) Colocar no diret�rio \SIGAADV o programa MATA010 que quando da con- ���
���   firma��o da entrada do registro grava o sequencial na tabela 98.    ���
���6) Notas: 6.1: as inclus�es no SB1, via F3, devem ser inibidas.        ���
���          6.2: n�o poder�o ser digitados produtos de um mesmo grupo,   ���
���               por mais de um usu�rio, simultaneamente.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*cInigrupo := Posicione("SBM",1,xFilial("SBM")+M->B1_GRUPO,"SBM->BM_GRUPO")                                
nContador:= val(cInigrupo)+1  
cContador:=" " 
cContador:=strzero(nContador,4)
cInigrupo:= alltrim(M->B1_GRUPO) + cContador*/

Local cGrupo := M->B1_GRUPO
Local cQuery := "" 
Local cIniGrupo := ""
Local cGrupoA := AllTrim(cGrupo)

If !Empty(cGrupo)
   cQuery := "SELECT MAX(CAST(SUBSTRING(B1_COD,"+Alltrim(Str(Len(cGrupoA)+1))+",LEN(B1_COD)) AS INTEGER))+1  AS MAXIMO FROM "+RetSqlName("SB1")+ " WHERE B1_GRUPO = '"+cGrupo+"' AND D_E_L_E_T_ <> '*'"

   TCQUERY cQuery ALIAS "QSB1" NEW

   cIniGrupo := QSB1->MAXIMO

   dbCloseArea("QSB1")

   cIniGrupo := StrZero(cIniGrupo,6)
   cIniGrupo := Alltrim(cGrupoA) + Alltrim(cIniGrupo)
EndIf

Return(cInigrupo)