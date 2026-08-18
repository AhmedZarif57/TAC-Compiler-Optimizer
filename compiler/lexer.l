%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%

[0-9]+(\.[0-9]+)? {
    yylval.number = atof(yytext);
    return NUMBER;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.name = strdup(yytext);
    return ID;
}

"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MULTIPLY; }
"/"     { return DIVIDE; }
"="     { return ASSIGN; }
"("     { return LPAREN; }
")"     { return RPAREN; }
";"     { return SEMICOLON; }

[ \t\n]+    { /* ignore whitespace */ }

.           { return yytext[0]; }

%%

int yywrap(void)
{
    return 1;
}
