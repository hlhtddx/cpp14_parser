%{

#include <string>

#define YYDEBUG 1        /* get the pretty debugging code to compile*/
//#include "cpp14_lexer.hpp"

extern int cpp14lex (void);

void yyerror(const char* string);

%}

/*
%glr-parser
*/

%union{
    const char* text;
}

%token ALIGNAS ALIGNOF ASM AUTO
%token BOOL BREAK
%token CASE CATCH CHAR CHAR16_T CHAR32_T CLASS CONST CONSTEXPR CONST_CAST CONTINUE
%token DECLTYPE DEFAULT DELETE DO DOUBLE DYNAMIC_CAST
%token ELSE ENUM EXPLICIT EXPORT EXTERN
%token FALSE FINAL FLOAT FOR FRIEND
%token GOTO
%token IF INLINE INT
%token LONG
%token MUTABLE
%token NAMESPACE NEW NOEXCEPT NULLPTR
%token OPERATOR OVERRIDE
%token PRIVATE PROTECTED PUBLIC REGISTER
%token REINTERPRET_CAST RETURN
%token SHORT SIGNED SIZEOF STATIC STATIC_ASSERT STATIC_CAST STRUCT SWITCH
%token TEMPLATE THIS THREAD_LOCAL THROW TRUE TRY TYPEDEF TYPEID TYPENAME
%token UNION UNSIGNED USING
%token VIRTUAL VOID VOLATILE
%token WCHAR_T WHILE

%token IDENTIFIER
%token integer_literal
%token character_literal
%token floating_literal
%token string_literal

/* Multi_Character operators */
%token  ARROW                                   /*    ->                              */
%token  INCR DECR                               /*    ++      --                      */
%token  L_SHIFT R_SHIFT                         /*    <<      >>                      */
%token  LE GE EQ NE                             /*    <=      >=      ==      !=      */
%token  ANDAND OROR                             /*    &&      ||                      */
%token  ELLIPSIS                                /*    ELLIPSIS                        */

%token  CLCL                                    /*    ::                              */
%token  DOT_STAR ARROW_STAR                     /*    .*       ->*                    */

/* modifying assignment operators */
%token MUL_ASSIGN  DIV_ASSIGN    MOD_ASSIGN     /*    *=      /=      %=      */
%token PLUS_ASSIGN  MINUS_ASSIGN                /*    +=      -=              */
%token LS_ASSIGN    RS_ASSIGN                   /*    <<=     >>=             */
%token AND_ASSIGN   ER_ASSIGN     OR_ASSIGN     /*    &=      ^=      |=      */

/*************************************************************************/

%start translation_unit

/*************************************************************************/

%%

/*********************** CONSTANTS *********************************/

CLCL_opt:
                                | CLCL
                                ;

COMMA_opt:
                                | ','
                                ;

ELLIPSIS_opt:
                                | ELLIPSIS
                                ;

EXTERN_opt:
                                | EXTERN
                                ;

IDENTIFIER_opt:
                                | IDENTIFIER
                                ;

INLINE_opt:
                                | INLINE
                                ;

MUTABLE_opt:
                                | MUTABLE
                                ;

TEMPLATE_opt:
                                | TEMPLATE
                                ;

TYPENAME_opt:
                                | TYPENAME
                                ;

VIRTUAL_opt:
                                | VIRTUAL
                                ;

literal:                        integer_literal
                                | character_literal
                                | floating_literal
                                | string_literal_list
                                | boolean_literal
                                | pointer_literal
                                | user_defined_literal
                                ;

string_literal_list:            string_literal
                                | string_literal_list string_literal
                                ;


boolean_literal:                TRUE
                                | FALSE
                                ;

pointer_literal:                NULLPTR
                                ;

user_defined_literal:           user_defined_integer_literal
                                | user_defined_floating_literal
                                | user_defined_string_literal
                                | user_defined_character_literal
                                ;

user_defined_integer_literal:   integer_literal ud_suffix
                                ;

user_defined_floating_literal:  floating_literal ud_suffix
                                ;

user_defined_string_literal:    string_literal ud_suffix
                                ;

user_defined_character_literal: character_literal ud_suffix
                                ;

ud_suffix:                      IDENTIFIER
                                ;


/* Basic concepts       [gram.basic] */
translation_unit:               declaration_seq_opt
                                ;

/* Expressions          [gram.expr] */
primary_expression:             literal
                                | THIS
                                | '(' expression ')'
                                | id_expression
                                | lambda_expression
                                ;

id_expression:                  unqualified_id
                                | qualified_id
                                ;

unqualified_id:                 IDENTIFIER
                                | operator_function_id
                                | conversion_function_id
                                | literal_operator_id
                                | '~' class_name
                                | '~' decltype_specifier
                                | template_id
                                ;

qualified_id:                   nested_name_specifier TEMPLATE_opt unqualified_id
                                ;

nested_name_specifier:          CLCL
                                | type_name CLCL
                                | namespace_name CLCL
                                | decltype_specifier CLCL
                                | nested_name_specifier IDENTIFIER CLCL
                                | nested_name_specifier TEMPLATE_opt simple_template_id CLCL
                                ;

nested_name_specifier_opt:
                                | nested_name_specifier
                                ;

lambda_expression:              lambda_introducer lambda_declarator_opt compound_statement
                                ;

lambda_introducer:              '[' lambda_capture_opt ']'
                                ;

lambda_capture_opt:
                                | lambda_capture
                                ;

lambda_capture:                 capture_default
                                | capture_list
                                | capture_default ',' capture_list
                                ;

capture_default:                '&'
                                | '='
                                ;

capture_list:                   capture ELLIPSIS_opt
                                | capture_list ',' ELLIPSIS_opt
                                ;

capture:                        simple_capture
                                | init_capture
                                ;

simple_capture:                 IDENTIFIER
                                | '&' IDENTIFIER
                                | THIS
                                ;

init_capture:                   IDENTIFIER initializer
                                | '&' IDENTIFIER initializer
                                ;

lambda_declarator:              '(' parameter_declaration_clause ')' MUTABLE_opt exception_specification_opt attribute_specifier_seq_opt trailing_return_type_opt

lambda_declarator_opt:
                                | lambda_declarator
                                ;

postfix_expression:             primary_expression
                                | postfix_expression '[' expression ']'
                                | postfix_expression '[' braced_init_list ']'
                                | postfix_expression '(' expression_list_opt ')'
                                | simple_type_specifier '(' expression_list_opt ')'
                                | typename_specifier '(' expression_list_opt ')'
                                | simple_type_specifier braced_init_list
                                | typename_specifier braced_init_list
                                | postfix_expression '.' TEMPLATE_opt id_expression
                                | postfix_expression ARROW TEMPLATE_opt id_expression
                                | postfix_expression '.' pseudo_destructor_name
                                | postfix_expression ARROW pseudo_destructor_name
                                | postfix_expression INCR
                                | postfix_expression DECR
                                | DYNAMIC_CAST '<' type_id '>' '(' expression ')'
                                | STATIC_CAST '<' type_id '>' '(' expression ')'
                                | REINTERPRET_CAST '<' type_id '>' '(' expression ')'
                                | CONST_CAST '<' type_id '>' '(' expression ')'
                                | TYPEID '(' expression ')'
                                | TYPEID '(' type_id ')'
                                ;

expression_list:                initializer_list
                                ;

expression_list_opt:
                                | expression_list
                                ;

pseudo_destructor_name:         nested_name_specifier_opt type_name CLCL '~' type_name
                                | nested_name_specifier TEMPLATE simple_template_id CLCL '~' type_name
                                | nested_name_specifier_opt '~' type_name
                                | '~' decltype_specifier
                                ;

unary_expression:               postfix_expression
                                | INCR cast_expression
                                | DECR cast_expression
                                | unary_operator cast_expression
                                | SIZEOF unary_expression
                                | SIZEOF '(' type_id ')'
                                | SIZEOF '(' IDENTIFIER ')'
                                | ALIGNOF '(' type_id ')'
                                | noexcept_expression
                                | new_expression
                                | delete_expression
                                ;

unary_operator:                 '*'
                                | '&'
                                | '+'
                                | '-'
                                | '!'
                                | '~'
                                ;

new_expression:                 CLCL_opt NEW new_placement_opt new_type_id new_initializer_opt
                                | CLCL_opt NEW new_placement_opt '(' type_id ')' new_initializer_opt
                                ;

new_placement:                  '(' expression_list ')'
                                ;

new_placement_opt:
                                | new_placement
                                ;

new_type_id:                    type_specifier_seq new_declarator_opt
                                ;

new_declarator:                 ptr_operator new_declarator_opt noptr_new_declarator
                                ;

new_declarator_opt:
                                | new_declarator
                                ;

noptr_new_declarator:           '[' expression ']' attribute_specifier_seq_opt
                                | noptr_new_declarator '[' constant_expression ']' attribute_specifier_seq_opt
                                ;

new_initializer:                '(' expression_list_opt ')'
                                | braced_init_list
                                ;

new_initializer_opt:
                                | new_initializer
                                ;

delete_expression:              CLCL_opt DELETE cast_expression
                                | CLCL_opt DELETE '[' ']' cast_expression
                                ;

noexcept_expression:            NOEXCEPT '(' expression ')'
                                ;

cast_expression:                unary_expression
                                | '(' type_id ')' cast_expression
                                ;

pm_expression:                  cast_expression
                                | pm_expression DOT_STAR cast_expression
                                | pm_expression ARROW_STAR cast_expression
;

multiplicative_expression:      pm_expression
                                | multiplicative_expression '*' pm_expression
                                | multiplicative_expression '/' pm_expression
                                | multiplicative_expression '%' pm_expression
                                ;

additive_expression:            multiplicative_expression
                                | additive_expression '+' multiplicative_expression
                                | additive_expression '-' multiplicative_expression
                                ;

shift_expression:               additive_expression
                                | shift_expression L_SHIFT additive_expression
                                | shift_expression R_SHIFT additive_expression
                                ;

relational_expression:          shift_expression
                                | relational_expression '<' shift_expression
                                | relational_expression '>' shift_expression
                                | relational_expression LE shift_expression
                                | relational_expression GE shift_expression
                                ;

equality_expression:            relational_expression
                                | equality_expression EQ relational_expression
                                | equality_expression NE relational_expression
                                ;

and_expression:                 equality_expression
                                | and_expression '&' equality_expression
                                ;

exclusive_or_expression:        and_expression
                                | exclusive_or_expression '^' and_expression
                                ;

inclusive_or_expression:        exclusive_or_expression
                                | inclusive_or_expression '|' exclusive_or_expression
                                ;

logical_and_expression:         inclusive_or_expression
                                | logical_and_expression ANDAND inclusive_or_expression
                                ;

logical_or_expression:          logical_and_expression
                                | logical_or_expression OROR logical_and_expression
                                ;

conditional_expression:         logical_or_expression
                                | logical_or_expression '?' expression ':' assignment_expression
                                ;

assignment_expression:          conditional_expression
                                | logical_or_expression assignment_operator initializer_clause
                                | throw_expression
                                ;

assignment_expression_opt:
                                | assignment_expression
                                ;
    
assignment_operator:            '='
                                | MUL_ASSIGN
                                | DIV_ASSIGN
                                | MOD_ASSIGN
                                | PLUS_ASSIGN
                                | MINUS_ASSIGN
                                | LS_ASSIGN
                                | RS_ASSIGN
                                | AND_ASSIGN
                                | ER_ASSIGN
                                | OR_ASSIGN
                                ;

expression:                     assignment_expression
                                | expression ',' assignment_expression
                                ;

expression_opt:
                                | expression
                                ;

constant_expression:            conditional_expression
                                ;

constant_expression_opt:
                                | constant_expression
                                ;

statement:                      labeled_statement
                                | attribute_specifier_seq_opt expression_statement
                                | attribute_specifier_seq_opt compound_statement
                                | attribute_specifier_seq_opt selection_statement
                                | attribute_specifier_seq_opt iteration_statement
                                | attribute_specifier_seq_opt jump_statement
                                | declaration_statement
                                | attribute_specifier_seq_opt try_block
                                ;

labeled_statement:              attribute_specifier_seq_opt IDENTIFIER ':' statement
                                | attribute_specifier_seq_opt CASE constant_expression ':' statement
                                | attribute_specifier_seq_opt DEFAULT ':' statement
                                ;

expression_statement:           expression_opt ';'
                                ;

compound_statement:             '{' statement_seq_opt '}'
                                ;

statement_seq:                  statement
                                | statement_seq statement
                                ;

statement_seq_opt:
                                | statement_seq
                                ;

selection_statement:            IF '(' condition ')' statement
                                | IF '(' condition ')' statement ELSE statement
                                | SWITCH '(' condition ')' statement
                                ;

condition:                      expression
                                | attribute_specifier_seq_opt decl_specifier_seq declarator '=' initializer_clause
                                | attribute_specifier_seq_opt decl_specifier_seq declarator braced_init_list
                                ;

condition_opt:
                                | condition
                                ;

iteration_statement:            WHILE '(' condition ')' statement
                                | DO statement WHILE '(' expression ')' ';'
                                | FOR '(' for_init_statement condition_opt ';' expression_opt ')' statement
                                | FOR '(' for_range_declaration ':' for_range_initializer ')' statement
                                ;

for_init_statement:             expression_statement
                                | simple_declaration
                                ;

for_range_declaration:          attribute_specifier_seq_opt decl_specifier_seq declarator
                                ;

for_range_initializer:          expression
                                | braced_init_list
                                ;

jump_statement:                 BREAK ';'
                                | CONTINUE ';'
                                | RETURN expression_opt ';'
                                | RETURN braced_init_list ';'
                                | GOTO IDENTIFIER ';'
                                ;

declaration_statement:          block_declaration
                                ;

declaration_seq:                declaration
                                | declaration_seq declaration
                                ;

declaration_seq_opt:
                                | declaration_seq
                                ;

declaration:                    block_declaration
                                | function_definition
                                | template_declaration
                                | explicit_instantiation
                                | explicit_specialization
                                | linkage_specification
                                | namespace_definition
                                | empty_declaration
                                | attribute_declaration
                                ;

block_declaration:              simple_declaration
                                | asm_definition
                                | namespace_alias_definition
                                | using_declaration
                                | using_directive
                                | static_assert_declaration
                                | alias_declaration
                                | opaque_enum_declaration
                                ;

alias_declaration:              USING IDENTIFIER attribute_specifier_seq_opt '=' type_id ';'
                                ;

simple_declaration:             decl_specifier_seq_opt init_declarator_list_opt';'
                                | attribute_specifier_seq decl_specifier_seq_opt init_declarator_list ';'
                                ;

static_assert_declaration:      STATIC_ASSERT '(' constant_expression ',' string_literal  ')' ';'
                                ;

empty_declaration:              ';'
                                ;

attribute_declaration:          attribute_specifier_seq ';'
                                ;

decl_specifier:                 storage_class_specifier
                                | type_specifier
                                | function_specifier
                                | FRIEND
                                | TYPEDEF
                                | CONSTEXPR
                                ;

decl_specifier_seq:             decl_specifier attribute_specifier_seq_opt
                                | decl_specifier decl_specifier_seq
                                ;

decl_specifier_seq_opt:
                                | decl_specifier_seq
                                ;

storage_class_specifier:        REGISTER
                                | STATIC
                                | THREAD_LOCAL
                                | EXTERN
                                | MUTABLE
                                ;

function_specifier:             INLINE
                                | VIRTUAL
                                | EXPLICIT
                                ;

typedef_name:                   IDENTIFIER
                                ;

type_specifier:                 trailing_type_specifier
                                | class_specifier
                                | enum_specifier
                                ;

trailing_type_specifier:        simple_type_specifier
                                | elaborated_type_specifier
                                | typename_specifier
                                | cv_qualifier
                                ;

type_specifier_seq:             type_specifier attribute_specifier_seq_opt
                                | type_specifier type_specifier_seq
                                ;

trailing_type_specifier_seq:    trailing_type_specifier attribute_specifier_seq_opt
                                | trailing_type_specifier trailing_type_specifier_seq
                                ;

simple_type_specifier:          nested_name_specifier_opt
                                | type_name
                                | nested_name_specifier TEMPLATE simple_template_id
                                | CHAR
                                | CHAR16_T
                                | CHAR32_T
                                | WCHAR_T
                                | BOOL
                                | SHORT
                                | INT
                                | LONG
                                | SIGNED
                                | UNSIGNED
                                | FLOAT
                                | DOUBLE
                                | VOID
                                | AUTO
                                | decltype_specifier
                                ;

type_name:                      class_name
                                | enum_name
                                | typedef_name
                                | simple_template_id
                                ;

decltype_specifier:             DECLTYPE '(' expression ')'
                                | DECLTYPE '(' AUTO ')'
                                ;

elaborated_type_specifier:      class_key attribute_specifier_seq_opt nested_name_specifier_opt IDENTIFIER
                                | class_key simple_template_id
                                | class_key nested_name_specifier TEMPLATE_opt simple_template_id
                                | ENUM nested_name_specifier_opt IDENTIFIER
                                ;

enum_name:                      IDENTIFIER
                                ;

enum_specifier:                 enum_head '{' enumerator_list_opt '}'
                                | enum_head '{' enumerator_list ',' '}'
                                ;

enum_head:                      enum_key attribute_specifier_seq_opt IDENTIFIER_opt enum_base_opt
                                | enum_key attribute_specifier_seq_opt nested_name_specifier IDENTIFIER
                                | enum_base_opt
                                ;

opaque_enum_declaration:        enum_key attribute_specifier_seq_opt IDENTIFIER enum_base_opt ';'
                                ;

enum_key:                       ENUM
                                | ENUM CLASS
                                | ENUM STRUCT
                                ;

enum_base:                      ':' type_specifier_seq
                                ;

enum_base_opt:
                                | enum_base
                                ;

enumerator_list:                enumerator_definition
                                | enumerator_list ',' enumerator_definition
                                ;

enumerator_list_opt:
                                | enumerator_list
                                ;

enumerator_definition:          enumerator
                                | enumerator '=' constant_expression
                                ;

enumerator:                     IDENTIFIER
                                ;

namespace_name:                 original_namespace_name
                                | namespace_alias
                                ;

original_namespace_name:        IDENTIFIER
                                ;

namespace_definition:           named_namespace_definition
                                | unnamed_namespace_definition
                                ;

named_namespace_definition:     original_namespace_definition
                                | extension_namespace_definition
                                ;

original_namespace_definition:  INLINE_opt NAMESPACE IDENTIFIER '{' namespace_body '}'
                                ;

extension_namespace_definition: INLINE_opt NAMESPACE original_namespace_name '{' namespace_body '}'
                                ;

unnamed_namespace_definition:   INLINE_opt NAMESPACE '{' namespace_body '}'
                                ;

namespace_body:                 declaration_seq_opt
                                ;

namespace_alias:                IDENTIFIER
                                ;

namespace_alias_definition:     NAMESPACE IDENTIFIER '=' qualified_namespace_specifier ';'
                                ;

qualified_namespace_specifier:  nested_name_specifier_opt namespace_name
                                ;

using_declaration:              USING TYPENAME_opt nested_name_specifier unqualified_id ';'
                                | USING CLCL unqualified_id ';'
                                ;

using_directive:                attribute_specifier_seq_opt USING NAMESPACE nested_name_specifier_opt namespace_name ';'
                                ;

asm_definition:                 ASM '(' string_literal_list ')' ';'
                                ;

linkage_specification:          EXTERN string_literal '{' declaration_seq_opt '}'
                                | EXTERN string_literal declaration
                                ;

attribute_specifier_seq:        attribute_specifier_seq_opt attribute_specifier
                                ;

attribute_specifier_seq_opt:
                                | attribute_specifier_seq
                                ;

attribute_specifier:            '[' '[' attribute_list ']' ']'
                                | alignment_specifier
                                ;

alignment_specifier:            ALIGNAS '(' type_id ELLIPSIS_opt')'
                                | ALIGNAS '(' constant_expression ELLIPSIS_opt')'
                                ;

attribute_list:                 attribute_opt
                                | attribute_list ',' attribute_opt
                                | attribute ELLIPSIS
                                | attribute_list ',' attribute ELLIPSIS
                                ;

attribute:                      attribute_token attribute_argument_clause_opt
                                ;

attribute_opt:
                                | attribute
                                ;

attribute_token:                IDENTIFIER
                                | attribute_scoped_token
                                ;

attribute_scoped_token:         attribute_namespace CLCL IDENTIFIER
                                ;

attribute_namespace:            IDENTIFIER
                                ;

attribute_argument_clause:      '(' balanced_token_seq ')'
                                ;

attribute_argument_clause_opt:
                                | attribute_argument_clause
                                ;

balanced_token_seq:             balanced_token_opt
                                | balanced_token_seq balanced_token
                                ;

balanced_token:                 '(' balanced_token_seq ')'
                                | '[' balanced_token_seq ']'
                                | '{' balanced_token_seq '}'
                                ;

balanced_token_opt:
                                | balanced_token
                                ;

init_declarator_list:           init_declarator
                                | init_declarator_list ',' init_declarator
                                ;

init_declarator_list_opt:
                                | init_declarator_list
                                ;

init_declarator:                declarator initializer_opt
                                ;

declarator:                     ptr_declarator
                                | noptr_declarator parameters_and_qualifiers trailing_return_type
                                ;

ptr_declarator:                 noptr_declarator
                                | ptr_operator ptr_declarator
                                ;

noptr_declarator:               declarator_id attribute_specifier_seq_opt
                                | noptr_declarator parameters_and_qualifiers
                                | noptr_declarator '[' constant_expression_opt ']' attribute_specifier_seq_opt '(' ptr_declarator ')'
                                ;

parameters_and_qualifiers:      '(' parameter_declaration_clause ')' cv_qualifier_seq_opt ref_qualifier_opt exception_specification_opt attribute_specifier_seq_opt
                                ;

trailing_return_type:           ARROW trailing_type_specifier_seq abstract_declarator_opt
                                ;

trailing_return_type_opt:
                                | trailing_return_type
                                ;

ptr_operator:                   '*' attribute_specifier_seq_opt cv_qualifier_seq_opt
                                | '&' attribute_specifier_seq_opt
                                | ANDAND attribute_specifier_seq_opt
                                | nested_name_specifier '*' attribute_specifier_seq_opt cv_qualifier_seq_opt
                                ;

cv_qualifier_seq:               cv_qualifier cv_qualifier_seq_opt
                                ;

cv_qualifier_seq_opt:
                                | cv_qualifier_seq
                                ;

cv_qualifier:    CONST
                                | VOLATILE
                                ;

ref_qualifier:    '&'
                                | ANDAND
                                ;

ref_qualifier_opt:
                                | ref_qualifier
                                ;

declarator_id:                  ELLIPSIS_opt id_expression
                                ;

type_id:                        type_specifier_seq abstract_declarator_opt
                                ;

abstract_declarator:            ptr_abstract_declarator
                                | noptr_abstract_declarator_opt parameters_and_qualifiers trailing_return_type
                                | abstract_pack_declarator
                                ;

abstract_declarator_opt:
                                | abstract_declarator
                                ;

ptr_abstract_declarator:        noptr_abstract_declarator
                                | ptr_operator ptr_abstract_declarator_opt
                                ;

ptr_abstract_declarator_opt:
                                | ptr_abstract_declarator
                                ;

noptr_abstract_declarator:      noptr_abstract_declarator_opt parameters_and_qualifiers
                                | noptr_abstract_declarator_opt '[' constant_expression_opt ']' attribute_specifier_seq_opt
                                | '(' ptr_abstract_declarator ')'
                                ;

noptr_abstract_declarator_opt:
                                | noptr_abstract_declarator
                                ;

noptr_abstract_pack_declarator: noptr_abstract_pack_declarator parameters_and_qualifiers
                                | noptr_abstract_pack_declarator '[' constant_expression_opt ']' attribute_specifier_seq_opt
                                ;

parameter_declaration_clause:   parameter_declaration_list_opt ELLIPSIS_opt
                                | parameter_declaration_list ',' ELLIPSIS
                                ;

parameter_declaration_list:     parameter_declaration
                                | parameter_declaration_list ',' parameter_declaration
                                ;

parameter_declaration_list_opt:
                                | parameter_declaration_list
                                ;

parameter_declaration:          attribute_specifier_seq_opt decl_specifier_seq declarator
                                | attribute_specifier_seq_opt decl_specifier_seq declarator '=' initializer_clause
                                | attribute_specifier_seq_opt decl_specifier_seq abstract_declarator_opt
                                | attribute_specifier_seq_opt decl_specifier_seq abstract_declarator_opt '=' initializer_clause
                                ;

function_definition:            attribute_specifier_seq_opt decl_specifier_seq_opt declarator virt_specifier_seq_opt function_body
                                ;

function_body:                  ctor_initializer_opt compound_statement
                                | function_try_block
                                | '=' DEFAULT ';'
                                | '=' DELETE ';'
                                ;

initializer:                    brace_or_equal_initializer
                                | '(' expression_list ')'
                                ;

initializer_opt:
                                | initializer
                                ;

brace_or_equal_initializer:    '=' initializer_clause
                                | braced_init_list
                                ;

brace_or_equal_initializer_opt:
                                | brace_or_equal_initializer
                                ;

initializer_clause:             assignment_expression
                                | braced_init_list
                                ;

initializer_list:               initializer_clause ELLIPSIS_opt
                                | initializer_list ',' initializer_clause ELLIPSIS_opt
                                ;

braced_init_list:               '{' initializer_list COMMA_opt '}'
                                | '{' '}'
                                ;

abstract_pack_declarator:       noptr_abstract_pack_declarator
                                | ptr_operator abstract_pack_declarator
                                ;

class_name:                     IDENTIFIER
                                | simple_template_id
                                ;

class_specifier:                class_head '{' member_specification_opt '}'
                                ;

class_head:                     class_key attribute_specifier_seq_opt class_head_name class_virt_specifier_opt base_clause_opt
                                | class_key attribute_specifier_seq_opt base_clause_opt
                                ;

class_head_name:                nested_name_specifier_opt class_name
                                ;

class_virt_specifier:           FINAL
                                ;

class_virt_specifier_opt:
                                | class_virt_specifier
                                ;

class_key:    CLASS
                                | STRUCT
                                | UNION
                                ;

member_specification:           member_declaration member_specification_opt
                                | access_specifier ':' member_specification_opt
                                ;

member_specification_opt:
                                | member_specification
                                ;

member_declaration:             attribute_specifier_seq_opt decl_specifier_seq_opt member_declarator_list_opt ';'
                                | function_definition
                                | using_declaration
                                | static_assert_declaration
                                | template_declaration
                                | alias_declaration
                                | empty_declaration
                                ;

member_declarator_list:         member_declarator
                                | member_declarator_list ',' member_declarator
                                ;

member_declarator_list_opt:
                                | member_declarator_list
                                ;

member_declarator:              declarator virt_specifier_seq_opt pure_specifier_opt
                                | declarator brace_or_equal_initializer_opt
                                | IDENTIFIER_opt attribute_specifier_seq_opt ':' constant_expression
                                ;

virt_specifier_seq:             virt_specifier
                                | virt_specifier_seq virt_specifier
                                ;

virt_specifier_seq_opt:
                                | virt_specifier_seq
                                ;

virt_specifier:                 OVERRIDE
                                | FINAL
                                ;

pure_specifier:                 '=' integer_literal
                                ;

pure_specifier_opt:
                                | pure_specifier
                                ;

/* Derived classes          [gram.derived] */
base_clause:                    ':' base_specifier_list
                                ;

base_clause_opt:
                                | base_clause
                                ;

base_specifier_list:            base_specifier ELLIPSIS_opt
                                | base_specifier_list ',' base_specifier ELLIPSIS_opt
                                ;

base_specifier:                 attribute_specifier_seq_opt base_type_specifier
                                | attribute_specifier_seq_opt VIRTUAL access_specifier_opt base_type_specifier
                                | attribute_specifier_seq_opt access_specifier VIRTUAL_opt base_type_specifier
                                ;

class_or_decltype:              nested_name_specifier_opt class_name
                                | decltype_specifier
                                ;

base_type_specifier:            class_or_decltype
                                ;

access_specifier:               PRIVATE
                                | PROTECTED
                                | PUBLIC
                                ;

access_specifier_opt:
                                | access_specifier
                                ;

/* Special member functions     [gram.special] */
conversion_function_id:         OPERATOR conversion_type_id
                                ;

conversion_type_id:             type_specifier_seq conversion_declarator_opt
                                ;

conversion_declarator:          ptr_operator conversion_declarator_opt
                                ;

conversion_declarator_opt:
                                | conversion_declarator
                                ;

ctor_initializer:               ':' mem_initializer_list
                                ;

ctor_initializer_opt:
                                | ctor_initializer
                                ;

mem_initializer_list:           mem_initializer ELLIPSIS_opt
                                | mem_initializer ELLIPSIS_opt ',' mem_initializer_list
                                ;

mem_initializer:                mem_initializer_id '(' expression_list_opt ')'
                                | mem_initializer_id braced_init_list
                                ;

mem_initializer_id:             class_or_decltype
                                | IDENTIFIER
                                ;

/* Overloading              [gram.over] */
operator_function_id:           OPERATOR operator
                                ;

operator:                       alloc_operator
                                | arithmetic_operator
                                | bit_operator
                                | relation_operator
                                | assign_operator
                                | other_operator
                                ;

alloc_operator:                 NEW
                                | DELETE
                                | NEW '[' ']'
                                | DELETE '[' ']'
                                ;

arithmetic_operator:            '+'
                                | '-'
                                | '*'
                                | '/'
                                | '%'
                                | L_SHIFT
                                | R_SHIFT
                                | INCR
                                | DECR
                                ;

bit_operator:                   '^'
                                | '&'
                                | '|'
                                | '~'
                                | '!'
                                ;

relation_operator:              '<'
                                | '>'
                                | EQ
                                | NE
                                | LE
                                | GE
                                | ANDAND
                                | OROR
                                ;

assign_operator:                '='
                                | PLUS_ASSIGN
                                | MINUS_ASSIGN
                                | MUL_ASSIGN
                                | DIV_ASSIGN
                                | MOD_ASSIGN
                                | AND_ASSIGN
                                | ER_ASSIGN
                                | OR_ASSIGN
                                | LS_ASSIGN
                                | RS_ASSIGN
                                ;

other_operator:                 ','
                                | ARROW_STAR
                                | ARROW
                                | '(' ')'
                                | '[' ']'
                                ;

literal_operator_id:            operator string_literal IDENTIFIER operator user_defined_string_literal
                                ;


/* Templates                [gram.temp] */
template_declaration:           TEMPLATE '<' template_parameter_list '>' declaration
                                ;

template_parameter_list:        template_parameter
                                | template_parameter_list ',' template_parameter
                                ;

template_parameter:             type_parameter
                                | parameter_declaration
                                ;

type_parameter:                 CLASS ELLIPSIS_opt IDENTIFIER_opt
                                | CLASS IDENTIFIER_opt '=' type_id
                                | TYPENAME ELLIPSIS_opt IDENTIFIER_opt
                                | TYPENAME IDENTIFIER_opt '=' type_id
                                | TEMPLATE '<' template_parameter_list '>' CLASS ELLIPSIS_opt IDENTIFIER_opt
                                | TEMPLATE '<' template_parameter_list '>' CLASS IDENTIFIER_opt '=' id_expression
                                ;
    
simple_template_id:             template_name '<' template_argument_list_opt '>'
                                ;

template_id:                    simple_template_id
                                | operator_function_id '<' template_argument_list_opt '>'
                                | literal_operator_id '<' template_argument_list_opt '>'
                                ;
    
template_name:                  IDENTIFIER
                                ;

template_argument_list:         template_argument ELLIPSIS_opt
                                | template_argument_list ',' template_argument ELLIPSIS_opt
                                ;

template_argument_list_opt:
                                | template_argument_list
                                ;

template_argument:              constant_expression
                                | type_id
                                | id_expression
                                ;

typename_specifier:             TYPENAME nested_name_specifier IDENTIFIER
                                | TYPENAME nested_name_specifier TEMPLATE_opt simple_template_id
                                ;

explicit_instantiation:         EXTERN_opt TEMPLATE declaration
                                ;
    
explicit_specialization:        TEMPLATE '<' '>' declaration
                                ;

try_block:                      TRY compound_statement handler_seq
                                ;

function_try_block:             TRY ctor_initializer_opt compound_statement handler_seq
                                ;
    
handler_seq:                    handler handler_seq_opt
                                ;

handler_seq_opt:
                                | handler_seq
                                ;

handler:                        CATCH '(' exception_declaration ')' compound_statement
                                ;
    
exception_declaration:          attribute_specifier_seq_opt type_specifier_seq declarator
                                | attribute_specifier_seq_opt type_specifier_seq abstract_declarator_opt ELLIPSIS
                                ;

throw_expression:               THROW assignment_expression_opt
                                ;

exception_specification:        dynamic_exception_specification
                                | noexcept_specification
                                ;

exception_specification_opt:
                                | exception_specification
                                ;

dynamic_exception_specification:    THROW '(' type_id_list_opt ')'
                                    ;

type_id_list:                   type_id ELLIPSIS_opt
                                | type_id_list ',' type_id ELLIPSIS_opt
                                ;

type_id_list_opt:
                                | type_id_list
                                ;

noexcept_specification:         NOEXCEPT '(' constant_expression ')'
                                | NOEXCEPT
                                ;

%%

const char* get_token_name(int token) {
    static char temp_str[2] = {0};
    if (token <= 0xff) {
        temp_str[0] = (char)token;
        return temp_str;
    }
    token -= 0xff;
    if (token <= sizeof(yytname)/sizeof(yytname[0])) {
        return yytname[token];
    }
    return "Out of bound";
}

void yyerror(const char* string)
{
    printf("parser error: %s\n", string);
}
