%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

int tempCount = 1;

struct TAC
{
    char result[50];
    char arg1[50];
    char op[10];
    char arg2[50];
};

struct TAC tac[100];
struct TAC optimizedTAC[100];

int tacCount = 0;
int optimizedCount = 0;


char* newTemp()
{
    char *temp = malloc(20);

    sprintf(temp, "t%d", tempCount++);

    return temp;
}


void generate(char *result, char *arg1, char *op, char *arg2)
{
    strcpy(tac[tacCount].result, result);
    strcpy(tac[tacCount].arg1, arg1);
    strcpy(tac[tacCount].op, op);
    strcpy(tac[tacCount].arg2, arg2);

    tacCount++;
}


void generateAssignment(char *result, char *arg1)
{
    strcpy(tac[tacCount].result, result);
    strcpy(tac[tacCount].arg1, arg1);
    strcpy(tac[tacCount].op, "");
    strcpy(tac[tacCount].arg2, "");

    tacCount++;
}


void printTAC(struct TAC code[], int count)
{
    int i;

    for (i = 0; i < count; i++)
    {
        if (strlen(code[i].op) == 0)
        {
            printf("%s = %s\n",
                   code[i].result,
                   code[i].arg1);
        }
        else
        {
            printf("%s = %s %s %s\n",
                   code[i].result,
                   code[i].arg1,
                   code[i].op,
                   code[i].arg2);
        }
    }
}


int isConstant(char *value)
{
    return value[0] == '#';
}


int isTemporaryUsedLater(int index, char *temp)
{
    int j;

    for (j = index + 1; j < optimizedCount; j++)
    {
        if (strcmp(optimizedTAC[j].arg1, temp) == 0)
            return 1;

        if (strcmp(optimizedTAC[j].arg2, temp) == 0)
            return 1;
    }

    return 0;
}


void optimizeConstants()
{
    int i;
    int j;

    char tempName[50][50];
    char tempValue[50][50];

    int tempValueCount = 0;


    for (i = 0; i < tacCount; i++)
    {
        char arg1[50];
        char arg2[50];

        strcpy(arg1, tac[i].arg1);
        strcpy(arg2, tac[i].arg2);


        /*
           Replace temporary names with
           their known values.
        */

        for (j = 0; j < tempValueCount; j++)
        {
            if (strcmp(arg1, tempName[j]) == 0)
            {
                strcpy(arg1, tempValue[j]);
            }

            if (strcmp(arg2, tempName[j]) == 0)
            {
                strcpy(arg2, tempValue[j]);
            }
        }


        /*
           Copy TAC instruction.
        */

        strcpy(optimizedTAC[optimizedCount].result,
               tac[i].result);

        strcpy(optimizedTAC[optimizedCount].arg1,
               arg1);

        strcpy(optimizedTAC[optimizedCount].op,
               tac[i].op);

        strcpy(optimizedTAC[optimizedCount].arg2,
               arg2);


        /*
           Constant Folding
        */

        if (strlen(tac[i].op) > 0 &&
            isConstant(arg1) &&
            isConstant(arg2))
        {
            double a;
            double b;
            double result;

            a = atof(arg1 + 1);
            b = atof(arg2 + 1);


            if (strcmp(tac[i].op, "+") == 0)
                result = a + b;

            else if (strcmp(tac[i].op, "-") == 0)
                result = a - b;

            else if (strcmp(tac[i].op, "*") == 0)
                result = a * b;

            else if (strcmp(tac[i].op, "/") == 0)
                result = a / b;

            else
                result = 0;


            sprintf(optimizedTAC[optimizedCount].arg1,
                    "#%g",
                    result);

            strcpy(optimizedTAC[optimizedCount].op, "");
            strcpy(optimizedTAC[optimizedCount].arg2, "");
        }


        /*
           Addition
        */

        else if (strcmp(tac[i].op, "+") == 0)
        {
            if (strcmp(arg2, "#0") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg1);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }

            else if (strcmp(arg1, "#0") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg2);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }
        }


        /*
           Subtraction
        */

        else if (strcmp(tac[i].op, "-") == 0)
        {
            if (strcmp(arg2, "#0") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg1);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }
        }


        /*
           Multiplication
        */

        else if (strcmp(tac[i].op, "*") == 0)
        {
            if (strcmp(arg2, "#1") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg1);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }

            else if (strcmp(arg1, "#1") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg2);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }

            else if (strcmp(arg1, "#0") == 0 ||
                     strcmp(arg2, "#0") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1, "#0");

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }
        }


        /*
           Division
        */

        else if (strcmp(tac[i].op, "/") == 0)
        {
            if (strcmp(arg2, "#1") == 0)
            {
                strcpy(optimizedTAC[optimizedCount].arg1,
                       arg1);

                strcpy(optimizedTAC[optimizedCount].op, "");
                strcpy(optimizedTAC[optimizedCount].arg2, "");
            }
        }

	if (tac[i].result[0] == 't' &&
	    strlen(optimizedTAC[optimizedCount].op) == 0)
	{
	    strcpy(tempName[tempValueCount],
	           tac[i].result);
	
	    strcpy(tempValue[tempValueCount],
	           optimizedTAC[optimizedCount].arg1);
	
	    tempValueCount++;
	}

        optimizedCount++;
    }
}


void removeUnusedTemporaries()
{
    int i;
    int newCount = 0;

    for (i = 0; i < optimizedCount; i++)
    {
        if (optimizedTAC[i].result[0] == '\0')
            continue;

        if (optimizedTAC[i].result[0] == 't')
        {
            if (!isTemporaryUsedLater(i,
                                      optimizedTAC[i].result))
            {
                continue;
            }
        }

        optimizedTAC[newCount] = optimizedTAC[i];

        newCount++;
    }

    optimizedCount = newCount;
}


void eliminateCommonSubexpressions()
{
    int i;
    int j;

    for (i = 0; i < optimizedCount; i++)
    {
        if (strlen(optimizedTAC[i].op) == 0)
            continue;

        for (j = 0; j < i; j++)
        {
            if (strlen(optimizedTAC[j].op) == 0)
                continue;

            if (strcmp(optimizedTAC[i].arg1,
                       optimizedTAC[j].arg1) == 0 &&
                strcmp(optimizedTAC[i].op,
                       optimizedTAC[j].op) == 0 &&
                strcmp(optimizedTAC[i].arg2,
                       optimizedTAC[j].arg2) == 0)
            {
                strcpy(optimizedTAC[i].arg1,
                       optimizedTAC[j].result);

                strcpy(optimizedTAC[i].op, "");

                strcpy(optimizedTAC[i].arg2, "");

                break;
            }
        }
    }
}

void eliminateCopyTemporaries()
{
    int i;
    int j;

    for (i = 0; i < optimizedCount; i++)
    {
        if (optimizedTAC[i].result[0] != 't')
            continue;

        if (strlen(optimizedTAC[i].op) != 0)
            continue;

        if (optimizedTAC[i].arg1[0] != 't')
            continue;

        for (j = i + 1; j < optimizedCount; j++)
        {
            if (strcmp(optimizedTAC[j].arg1,
                       optimizedTAC[i].result) == 0)
            {
                strcpy(optimizedTAC[j].arg1,
                       optimizedTAC[i].arg1);
            }

            if (strcmp(optimizedTAC[j].arg2,
                       optimizedTAC[i].result) == 0)
            {
                strcpy(optimizedTAC[j].arg2,
                       optimizedTAC[i].arg1);
            }
        }

        optimizedTAC[i].result[0] = '\0';
    }
}

void removeFinalTemporary()
{
    int i;
    int newCount = 0;

    for (i = 0; i < optimizedCount - 1; i++)
    {
        if (optimizedTAC[i].result[0] == 't' &&
            strlen(optimizedTAC[i].op) > 0 &&
            strcmp(optimizedTAC[i + 1].arg1,
                   optimizedTAC[i].result) == 0 &&
            strlen(optimizedTAC[i + 1].op) == 0)
        {
            strcpy(optimizedTAC[i].result,
                   optimizedTAC[i + 1].result);

            optimizedTAC[i + 1].result[0] = '\0';
        }
    }

    for (i = 0; i < optimizedCount; i++)
    {
        if (optimizedTAC[i].result[0] == '\0')
            continue;

        optimizedTAC[newCount] = optimizedTAC[i];
        newCount++;
    }

    optimizedCount = newCount;
}

%}


%union
{
    double number;
    char *name;
    char *code;
}


%token <number> NUMBER
%token <name> ID

%token PLUS MINUS MULTIPLY DIVIDE
%token ASSIGN
%token LPAREN RPAREN
%token SEMICOLON

%type <code> expression term factor


%%


statement:
      ID ASSIGN expression
      {
          generateAssignment($1, $3);

          printf("\n===== THREE ADDRESS CODE =====\n\n");

          printTAC(tac, tacCount);

          printf("\n==============================\n");

          optimizeConstants();

	  eliminateCommonSubexpressions();

	  eliminateCopyTemporaries();

	  removeUnusedTemporaries();
          
	  printf("\n===== OPTIMIZED THREE ADDRESS CODE =====\n\n");

          printTAC(optimizedTAC, optimizedCount);

          printf("\n========================================\n");
      }

    | ID ASSIGN expression SEMICOLON
      {
          generateAssignment($1, $3);

          printf("\n===== THREE ADDRESS CODE =====\n\n");

          printTAC(tac, tacCount);

          printf("\n==============================\n");

          optimizeConstants();

	  eliminateCommonSubexpressions();

	  eliminateCopyTemporaries();

          removeUnusedTemporaries();

          printf("\n===== OPTIMIZED THREE ADDRESS CODE =====\n\n");

          printTAC(optimizedTAC, optimizedCount);

          printf("\n========================================\n");
      }
    ;


expression:
      expression PLUS term
      {
          $$ = newTemp();

          generate($$, $1, "+", $3);
      }

    | expression MINUS term
      {
          $$ = newTemp();

          generate($$, $1, "-", $3);
      }

    | term
      {
          $$ = $1;
      }
    ;


term:
      term MULTIPLY factor
      {
          $$ = newTemp();

          generate($$, $1, "*", $3);
      }

    | term DIVIDE factor
      {
          $$ = newTemp();

          generate($$, $1, "/", $3);
      }

    | factor
      {
          $$ = $1;
      }
    ;


factor:
      NUMBER
      {
          $$ = malloc(50);

          sprintf($$, "#%g", $1);
      }

    | ID
      {
          $$ = $1;
      }

    | LPAREN expression RPAREN
      {
          $$ = $2;
      }
    ;


%%


void yyerror(const char *s)
{
    printf("\nInvalid expression!\n");
}


int main(void)
{
    if (yyparse() == 0)
    {
        printf("\nCompilation completed.\n");
    }

    return 0;
}
