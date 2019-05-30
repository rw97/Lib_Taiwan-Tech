%{


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int  yylex  (void);
void  yyerror  (const char *str);


int isShouldAdd = 0;
int keyId = 1;
int itemDepth = 0;

#define SIZE 1024
#define MAX_LINE_LENG 1024

struct DataItem {
   char idName[100];
   char type[100];
   char value[100];
   int key;
   int depth;
};

struct DataItem* *hashArray;

//Creates a symbol table.
struct DataItem* * create(){
  static struct DataItem* newHashArray[SIZE] ;
  return newHashArray;
};
//Returns index of the entry for int key
int lookup(char *idName , int depth) {
   int hashIndex = 1;
   int isFind = 0;

   while(hashArray[hashIndex] != NULL) {
      if(strcmp(hashArray[hashIndex]->idName, idName) == 0 && hashArray[hashIndex]->depth == depth)
      {
        isFind = 1;
        break;
      }
      else
      {
        ++hashIndex;
      }
   }
   if(isFind == 1){
     return hashIndex;
   }
   else{
     return -1;
   }
}
//Inserts s into  the symbol table
void insert(char *idName , char *type, char *value) {

	   struct DataItem *item = (struct DataItem*) malloc(sizeof(struct DataItem));
	   strcpy(item->idName, idName);
	   strcpy(item->type, type);
		strcpy(item->value, value);
		item->depth = itemDepth;
	   	item->key = keyId;

		hashArray[keyId] = item;
		keyId ++;
}

void clear(){
   for(int i = 1;i < SIZE;i++)
   {
 		if(hashArray[i] != NULL)
	    {
	      	hashArray[i] = NULL;
	    }
 	}
}

//Dumps all entries of the symbol table. returns index of the entry.
void dump() {
   for(int i = 1;i < SIZE;i++)
   {
 		if(hashArray[i] != NULL)
	    {
	      printf("%-*d:%-*s%-*s%-*s%-*d\n", 5, i, 20, hashArray[i]->idName, 15, hashArray[i]->type, 30, hashArray[i]->value, 5, hashArray[i]->depth);
	    }
 	}
 	clear();
}


%}

%union{
  char typeOF[200];
  char val[200];
  double double_type;
  int int_type;
  int int_val;
}

%token <val> STR TRUE FALSE IDENTIFIER BOOL STRINGKEYWORD REAL INT VOID
%token <double_type> REALCONSTANTS
%token <int_type> INTEGER
%token BOOL  CONST  ELSE THEN FOR FUNC  IF BEG MODULE END PROCEDURE
%token  INT  PRINT PRINTLN REAL RETURN STRINGKEYWORD
%token  VAR  WHILE DO READ

%token LE_OP GE_OP EQ_OP NE_OP
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%start program

%type  <val> value_declaration program primary_expression type_specifier declarator_list declarator


%%



type_specifier
	: BOOL
	| STRINGKEYWORD
	| REAL
	| INT
	| VOID
	;

value_declaration
	: STR  {
		strcpy($$, $1);
	}
	| TRUE  {
		strcpy($$, $1);
	}
	| FALSE {
		strcpy($$, $1);
	}
	| INTEGER
	{
		char tempStr[50];
		sprintf( tempStr, "%d", $1 );
		strcpy($$, tempStr);
	}
	| REALCONSTANTS
	{
		char tempStr[50];
		sprintf( tempStr, "%g", $1 );
		strcpy($$, tempStr);
	}
	;

// when function be called
declarator_list
	: declarator
	| declarator_list '(' declarator_list ')'
	| declarator_list ','
	;

declarator
	: IDENTIFIER
	| value_declaration
	;

// when funtion be defined
parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;
parameter_declaration
	: IDENTIFIER type_specifier
	{
		insert($1, $2 , "");
	}
        | IDENTIFIER
        | value_declaration
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

declaration
	: CONST IDENTIFIER '=' value_declaration ';' {
		insert($2, "const" , $4);
	}
	| VAR ':' IDENTIFIER type_specifier {
		insert($3, $4, "");
	}
	| VAR ':' '=' IDENTIFIER type_specifier ';' {
		insert($4, $5, "");
	}
	| VAR IDENTIFIER ',' IDENTIFIER ':' type_specifier ';' {
		insert($2, $6, "");
		insert($4, $6, "");
	}
	| VAR IDENTIFIER ',' IDENTIFIER ',' IDENTIFIER ',' IDENTIFIER ':' type_specifier ';' {
		insert($2, $10, "");
		insert($4, $10, "");
		insert($6, $10, "");
		insert($8, $10, "");
	}
	| IDENTIFIER ':' '=' value_declaration ';'
	| IDENTIFIER ':' '=' expression ';'
	| VAR ':' IDENTIFIER '[' INTEGER ']' type_specifier {
		insert($3, "array" , $7);
	}
        | VAR IDENTIFIER ':' type_specifier ';' {
                insert($2,$4,"");
        }

        | MODULE IDENTIFIER BEG simple_statment END  IDENTIFIER '.'
        | MODULE IDENTIFIER declaration_list PROCEDURE declaration_list
        | IDENTIFIER '(' IDENTIFIER ':' type_specifier ',' IDENTIFIER ':' type_specifier ')' ':' type_specifier BEG simple_statment
          END IDENTIFIER ';' BEG external_declaration statement END ';'  statement  END  IDENTIFIER '.'
        {
            insert($3,$5,"");
            insert($7,$9,"");
        }
	| MODULE IDENTIFIER BEG declaration_list END  statement ';'  END IDENTIFIER '.'
	| MODULE IDENTIFIER declaration_list BEG declaration_list  statement END ';' statement statement END IDENTIFIER '.'
	| MODULE IDENTIFIER declaration_list BEG declaration_list statement declaration_list END ';' statement statement END IDENTIFIER '.'
	;
simple_statment
	: IDENTIFIER '[' INTEGER ']' '=' expression
	| PRINT '(' expression  ')' ';'
	| PRINT '(' '"' expression '"' ')' ';'
	| PRINT  '"' expression '"' ';'
	| PRINT expression ';'
	| PRINT	expression  ':'	';'
	| PRINT expression ';'
	| PRINT expression
	| PRINTLN expression
	| PRINTLN expression ';'
	| READ IDENTIFIER
	| RETURN
	| RETURN expression ';'
	;



expression_statement
	:  expression
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| IF '(' expression ')' THEN statement ';' ELSE statement ';'
	| IF '(' expression ')' THEN expression ';' ELSE expression ';'
	| IF '(' expression ')' THEN statement ELSE statement
	| IF '(' expression ')'	THEN simple_statment ELSE simple_statment
	| IF '(' expression ')'	THEN  ELSE
	| WHILE	'(' expression ')' DO
	;






statement_list
	: statement
	| statement_list statement
	;

statement
	: simple_statment
	| expression_statement
	| selection_statement
	;

func_expression:
	FUNC {
		isShouldAdd = 0;
		itemDepth++;
	};

function_definition
	: func_expression  type_specifier IDENTIFIER '(' parameter_list ')'
	{
		insert($3, $2, "");
	}
	| func_expression IDENTIFIER '(' parameter_list ')'
	{
		insert($2, "", "");
	}
	| func_expression type_specifier IDENTIFIER '('  ')'
	{
		insert($3, $2, "");
	}
	| func_expression IDENTIFIER '('  ')'
	{
		insert($2, "", "");
	}
        | IDENTIFIER '(' parameter_list ')' ';'
        {
                insert($1,"","");
        }

	;


primary_expression
	: value_declaration
	| declarator_list
	| primary_expression value_declaration
	| primary_expression declarator_list
	;

unary_expression
	: primary_expression
	| '-' primary_expression
	;

multiplicative_expression
	: unary_expression
	| multiplicative_expression '*' unary_expression
	| multiplicative_expression '/' unary_expression
	| multiplicative_expression '%' unary_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;


relational_expression
	: additive_expression
	| relational_expression '<' primary_expression
	| relational_expression '>' primary_expression
	| relational_expression LE_OP primary_expression
	| relational_expression GE_OP primary_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

assignment_expression
	: inclusive_or_expression
	| inclusive_or_expression '=' assignment_expression
	;

expression
	: assignment_expression
	| expression assignment_expression
	;

external_declaration
	: function_definition
	| declaration_list
	| IDENTIFIER '(' declarator_list ')'
        | IDENTIFIER ':' '=' function_definition
	;

program
	: external_declaration
	| program external_declaration
	;

%%

void yyerror(const char *str){
    printf("error:%s\n",str);
}

int yywrap(){
    return 1;
}

int main()
{
	isShouldAdd = 0;
	itemDepth = 0;
	hashArray = create();

    yyparse();
    ;

    printf("%s\n", "------SYMBOLE TABLE LOOKUP:------");
    printf("%-*s%-*s\n", 20 ,"Name" ,10 , "Depth");
    if (lookup("a" , 0) >= 0 && lookup("a" , 1) >= 0)
    {
    	printf("%-*s%-*d\n", 20 ,hashArray[lookup("a" , 0)]->idName ,5 , hashArray[lookup("a" , 0)]->depth);
    	printf("%-*s%-*d\n", 20 ,hashArray[lookup("a" , 1)]->idName ,5 , hashArray[lookup("a" , 1)]->depth);
    }

    printf("\n\n%s\n", "------Symbol Table DUMP:------");
    printf("%-*s%-*s\n", 20 ,"Name" ,10 , "Depth");
    printf("%-*s:%-*s%-*s%-*s%-*d\n", 5, "Index:", 20, "Name", 15, "Type", 30, "Value", 5, "Depth");
  	dump();
  	return 0;
}
