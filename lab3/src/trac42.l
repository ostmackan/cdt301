/* $Id: trac42.l 88 2007-12-19 10:14:01Z csg $
   FILE:       trac42.lex
   CONTENTS:   trac42.lex - This is the lexical analysator for the
               trac42 language
   REVISION:   1.0, 960917, Christer Eriksson & Jukka M�ki-Turja
               1.1, 000824, Christer Sandberg Changes:bool-const now defines value of intVal
               1.2, 001206, Christer Sandberg Changes:bool-const rule must set lineNr in yyInt not int yylval
               1.3, 040105, Bj�rn Thor Changes:
                                       - Comments now also counts line numbers
                                       - Automatic generation of wrapper function
               1.4, 041216, Christer Sandberg Changes: \c removed from the delim definition.
               1.5, 041229, Christer Sandberg Changes: Fixed warning for unused function.
               1.6, 070105, Christer Sandberg Changes: Fixed duplicate declarations of yylineno.
   DESCRIPTION:Compiler skeleton used in a compiler theory course. To be translated by Flex
               and compiled to a scanner. Contains the basics for scanning of the trac42 language.
               To be plugged into trac42.y as the scanner.
*/
%option  noyywrap
%option nounput
%x comment
%{
#include <stdio.h>     /* Standard I/O                */
#include <string.h>    /* Standard string-routines    */
#include "ast.h"       /* Declaration of AST-nodes    */
#include "utils.h"
#include "trac42.h"    /* Declaration of yylval types */
#include "trac42.y.h"   /* Declaration of tokens       */

/*int yylineno=1;*/ /* Uncomment this if your flex version complains ... */

%}

STR     "\""([^\"])*"\""
delim   [ \t]
WS      {delim}+
DIGIT   [0-9]
LETTER  [A-Za-z]
ID      {LETTER}({LETTER}|{DIGIT})*
%%
"/*"         BEGIN(comment);
<comment>[^*\n]*
<comment>"*"+[^*/\n]*
<comment>\n            { ++yylineno; }
<comment>"*"+"/"       { BEGIN(INITIAL);}
{WS}      ;

int           {yylval.yyType.lineNr = yylineno;
               yylval.yyType.type = INT;
               return (BASIC_TYPE);}
bool          {yylval.yyType.lineNr = yylineno;
               yylval.yyType.type = BOOL;
               return (BASIC_TYPE);}
string        {yylval.yyType.lineNr = yylineno;
               yylval.yyType.type = STRING;
               return (BASIC_TYPE);}
void          {yylval.yyType.lineNr = yylineno;
               yylval.yyType.type = VOID;
               return (BASIC_TYPE);}

if            {yylval.yyLineNr = yylineno; return (IF);}
else          {yylval.yyLineNr = yylineno; return (ELSE);}
while         {yylval.yyLineNr = yylineno; return (WHILE);}
return        {yylval.yyLineNr = yylineno; return (RETURN);}
read          {yylval.yyLineNr = yylineno; return (READ);}
write         {yylval.yyLineNr = yylineno; return (WRITE);}

"\n"          {yylineno++;}
"!"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = NOT;
               return (NOTOP);}
"||"          {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = OR;
               return (OROP);}
"&&"          {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = AND;
               return (ANDOP);}

"=="          {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = EQ;
               return (RELOP);}
"<="          {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = LE;
               return (RELOP);}
"<"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = LT;
               return (RELOP);}

"+"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = PLUS;
               return (PLUSOP);}
"-"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = MINUS;
               return (MINUSOP);}
"*"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = MULT;
               return (MULOP);}
"/"           {yylval.yyOperator.lineNr = yylineno;
               yylval.yyOperator.opType = DIV;
               return (MULOP);}

true          {yylval.yyInt.intVal = 1; yylval.yyInt.lineNr = yylineno;
               return (BOOL_CONST);}
false         {yylval.yyInt.intVal = 0; yylval.yyInt.lineNr = yylineno;
               return (BOOL_CONST);}

{STR}         {yytext[yyleng-1] = 0;
               yylval.yyString.strVal = dstrcpy(yytext+1);
               if (strlen(yylval.yyString.strVal) >= STRING_SIZE) {
                  yylval.yyString.strVal[STRING_SIZE] = 0;
               }
               yylval.yyString.lineNr = yylineno;
               return (STRING_CONST);}

{DIGIT}+      {yylval.yyInt.intVal = atoi(yytext);
               yylval.yyInt.lineNr = yylineno;
               return (INT_CONST);}

{ID}          {yylval.yyString.strVal = dstrcpy(yytext);
               yylval.yyString.lineNr = yylineno;
               return (ID);}

.             {return (yytext[0]); }  /* . matches all other characters */

%%

