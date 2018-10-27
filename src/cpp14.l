%option noyywrap

%{

#include "cpp14_parser.hpp"

#define WHITE_RETURN(x) /* do nothing */

#define NEW_LINE_RETURN()       WHITE_RETURN('\n')
#define COMMENT_RETURN()        NEW_LINE_RETURN()        /* a commention literal */

#define KEYWORD_RETURN(x)       RETURN_VAL(x)  /* standard C PArser Keyword */
#define PPPA_KEYWORD_RETURN(x)  RETURN_VAL(x)  /* both PreProcessor and PArser keyword */
#define PP_KEYWORD_RETURN(x)    IDENTIFIER_RETURN()

#define IDENTIFIER_RETURN()     RETURN_VAL(IDENTIFIER)

#define PPOP_RETURN(x)          RETURN_VAL((int)*yytext) /* PreProcess and Parser operator */
#define NAMED_PPOP_RETURN(x)    /* error: PreProcessor ONLY operator;  Do nothing */
#define ASCIIOP_RETURN(x)       RETURN_VAL((int)*yytext) /* a single character operator */
#define NAMEDOP_RETURN(x)       RETURN_VAL(x)            /* a multichar operator, with a name */

#define NUMERICAL_RETURN(x)     RETURN_VAL(x)            /* some sort of constant */
#define LITERAL_RETURN(x)       RETURN_VAL(x)            /* a string literal */

#define RETURN_VAL(x) cpp14lval.text = cpp14text; return(x);


%}

/*
 * Preprocessing literals will not be applied
h_char              [^\n>]
q_char              [^\n\"]
h_char_sequence     {h_char}+
q_char_sequence     {q_char}+
*/

identifier          [a-zA-Z_][0-9a-zA-Z_]*

exponent_part       [eE][-+]?[0-9]+
fractional_constant ([0-9]*"."[0-9]+)|([0-9]+".")
floating_constant   (({fractional_constant}{exponent_part}?)|([0-9]+{exponent_part}))[FfLl]?

longint_suffix      l|L|ll|LL
integer_suffix_opt  ([uU]?{longint_suffix}?)|({longint_suffix}[uU])
decimal_constant    [1-9][0-9]*{integer_suffix_opt}
octal_constant      "0"[0-7]*{integer_suffix_opt}
hex_constant        "0"[xX][0-9a-fA-F]+{integer_suffix_opt}
binary_constant     "0"[bB][0-1]+{integer_suffix_opt}

simple_escape       [abfnrtv'"?\\]
octal_escape        [0-7]{1,3}
hex_escape          "x"[0-9a-fA-F]+

escape_sequence     [\\]({simple_escape}|{octal_escape}|{hex_escape})
c_char              [^'\\\n]|{escape_sequence}
s_char              [^"\\\n]|{escape_sequence}
/* TODO: raw string support */

h_tab               [\011]
form_feed           [\014]
v_tab               [\013]
c_return            [\015]

horizontal_white    [ ]|{h_tab}

sline_comment_char  [^\n]
mline_comment_char  [^\n]

%%

{horizontal_white}+     {
			WHITE_RETURN(' ');
			}

({v_tab}|{c_return}|{form_feed})+   {
			WHITE_RETURN(' ');
			}


({horizontal_white}|{v_tab}|{c_return}|{form_feed})*"\n"   {
			NEW_LINE_RETURN();
			}

alignas             {KEYWORD_RETURN(ALIGNAS);}
alignof             {KEYWORD_RETURN(ALIGNOF);}
asm                 {KEYWORD_RETURN(ASM);}
auto                {KEYWORD_RETURN(AUTO);}
bool                {KEYWORD_RETURN(BOOL);}
break               {KEYWORD_RETURN(BREAK);}
case                {KEYWORD_RETURN(CASE);}
catch               {KEYWORD_RETURN(CATCH);}
char                {KEYWORD_RETURN(CHAR);}
char16_t            {KEYWORD_RETURN(CHAR16_T);}
char32_t            {KEYWORD_RETURN(CHAR32_T);}
class               {KEYWORD_RETURN(CLASS);}
const               {KEYWORD_RETURN(CONST);}
constexpr           {KEYWORD_RETURN(CONSTEXPR);}
const_cast          {KEYWORD_RETURN(CONST_CAST);}
continue            {KEYWORD_RETURN(CONTINUE);}
decltype            {KEYWORD_RETURN(DECLTYPE);}
default             {KEYWORD_RETURN(DEFAULT);}
delete              {KEYWORD_RETURN(DELETE);}
do                  {KEYWORD_RETURN(DO);}
double              {KEYWORD_RETURN(DOUBLE);}
dynamic_cast        {KEYWORD_RETURN(DYNAMIC_CAST);}
else                {KEYWORD_RETURN(ELSE);}
enum                {KEYWORD_RETURN(ENUM);}
explicit            {KEYWORD_RETURN(EXPLICIT);}
export              {KEYWORD_RETURN(EXPORT);}
extern              {KEYWORD_RETURN(EXTERN);}
false               {KEYWORD_RETURN(FALSE);}
final               {KEYWORD_RETURN(FINAL);}
float               {KEYWORD_RETURN(FLOAT);}
for                 {KEYWORD_RETURN(FOR);}
friend              {KEYWORD_RETURN(FRIEND);}
goto                {KEYWORD_RETURN(GOTO);}
if                  {KEYWORD_RETURN(IF);}
inline              {KEYWORD_RETURN(INLINE);}
int                 {KEYWORD_RETURN(INT);}
long                {KEYWORD_RETURN(LONG);}
mutable             {KEYWORD_RETURN(MUTABLE);}
namespace           {KEYWORD_RETURN(NAMESPACE);}
new                 {KEYWORD_RETURN(NEW);}
noexcept            {KEYWORD_RETURN(NOEXCEPT);}
nullptr             {KEYWORD_RETURN(NULLPTR);}
operator            {KEYWORD_RETURN(OPERATOR);}
override            {KEYWORD_RETURN(OVERRIDE);}
private             {KEYWORD_RETURN(PRIVATE);}
protected           {KEYWORD_RETURN(PROTECTED);}
public              {KEYWORD_RETURN(PUBLIC);}
register            {KEYWORD_RETURN(REGISTER);}
reinterpret_cast    {KEYWORD_RETURN(REINTERPRET_CAST);}
return              {KEYWORD_RETURN(RETURN);}
short               {KEYWORD_RETURN(SHORT);}
signed              {KEYWORD_RETURN(SIGNED);}
sizeof              {KEYWORD_RETURN(SIZEOF);}
static              {KEYWORD_RETURN(STATIC);}
static_assert       {KEYWORD_RETURN(STATIC_ASSERT);}
static_cast         {KEYWORD_RETURN(STATIC_CAST);}
struct              {KEYWORD_RETURN(STRUCT);}
switch              {KEYWORD_RETURN(SWITCH);}
template            {KEYWORD_RETURN(TEMPLATE);}
this                {KEYWORD_RETURN(THIS);}
thread_local        {KEYWORD_RETURN(THREAD_LOCAL);}
throw               {KEYWORD_RETURN(THROW);}
true                {KEYWORD_RETURN(TRUE);}
try                 {KEYWORD_RETURN(TRY);}
typedef             {KEYWORD_RETURN(TYPEDEF);}
typeid              {KEYWORD_RETURN(TYPEID);}
typename            {KEYWORD_RETURN(TYPENAME);}
union               {KEYWORD_RETURN(UNION);}
unsigned            {KEYWORD_RETURN(UNSIGNED);}
using               {KEYWORD_RETURN(USING);}
virtual             {KEYWORD_RETURN(VIRTUAL);}
void                {KEYWORD_RETURN(VOID);}
volatile            {KEYWORD_RETURN(VOLATILE);}
wchar_t             {KEYWORD_RETURN(WCHAR_T);}
while               {KEYWORD_RETURN(WHILE);}

define              {PP_KEYWORD_RETURN(DEFINE);}
defined             {PP_KEYWORD_RETURN(OPDEFINED);}
elif                {PP_KEYWORD_RETURN(ELIF);}
endif               {PP_KEYWORD_RETURN(ENDIF);}
error               {PP_KEYWORD_RETURN(ERROR);}
ifdef               {PP_KEYWORD_RETURN(IFDEF);}
ifndef              {PP_KEYWORD_RETURN(IFNDEF);}
include             {PP_KEYWORD_RETURN(INCLUDE); }
line                {PP_KEYWORD_RETURN(LINE);}
pragma              {PP_KEYWORD_RETURN(PRAGMA);}
undef               {PP_KEYWORD_RETURN(UNDEF);}


{identifier}        {IDENTIFIER_RETURN();}

{decimal_constant}  {NUMERICAL_RETURN(integer_literal);}
{octal_constant}    {NUMERICAL_RETURN(integer_literal);}
{hex_constant}      {NUMERICAL_RETURN(integer_literal);}
{binary_constant}   {NUMERICAL_RETURN(integer_literal);}

{floating_constant} {NUMERICAL_RETURN(floating_literal);}


"L"?[']{c_char}+[']     {
			NUMERICAL_RETURN(character_literal);
			}


"L"?["]{s_char}*["]     {
			LITERAL_RETURN(string_literal);}




"("                  {PPOP_RETURN(LP);}
")"                  {PPOP_RETURN(RP);}
","                  {PPOP_RETURN(COMMA);}
"#"                  {NAMED_PPOP_RETURN('#') ;}
"##"                 {NAMED_PPOP_RETURN(POUNDPOUND);}

"{"                  {ASCIIOP_RETURN(LC);}
"}"                  {ASCIIOP_RETURN(RC);}
"["                  {ASCIIOP_RETURN(LB);}
"]"                  {ASCIIOP_RETURN(RB);}
"."                  {ASCIIOP_RETURN(DOT);}
"&"                  {ASCIIOP_RETURN(AND);}
"*"                  {ASCIIOP_RETURN(STAR);}
"+"                  {ASCIIOP_RETURN(PLUS);}
"-"                  {ASCIIOP_RETURN(MINUS);}
"~"                  {ASCIIOP_RETURN(NEGATE);}
"!"                  {ASCIIOP_RETURN(NOT);}
"/"                  {ASCIIOP_RETURN(DIV);}
"%"                  {ASCIIOP_RETURN(MOD);}
"<"                  {ASCIIOP_RETURN(LT);}
">"                  {ASCIIOP_RETURN(GT);}
"^"                  {ASCIIOP_RETURN(XOR);}
"|"                  {ASCIIOP_RETURN(PIPE);}
"?"                  {ASCIIOP_RETURN(QUESTION);}
":"                  {ASCIIOP_RETURN(COLON);}
";"                  {ASCIIOP_RETURN(SEMICOLON);}
"="                  {ASCIIOP_RETURN(ASSIGN);}

".*"                 {NAMEDOP_RETURN(DOT_STAR);}
"::"                 {NAMEDOP_RETURN(CLCL);}
"->"                 {NAMEDOP_RETURN(ARROW);}
"->*"                {NAMEDOP_RETURN(ARROW_STAR);}
"++"                 {NAMEDOP_RETURN(INCR);}
"--"                 {NAMEDOP_RETURN(DECR);}
"<<"                 {NAMEDOP_RETURN(L_SHIFT);}
">>"                 {NAMEDOP_RETURN(R_SHIFT);}
"<="                 {NAMEDOP_RETURN(LE);}
">="                 {NAMEDOP_RETURN(GE);}
"=="                 {NAMEDOP_RETURN(EQ);}
"!="                 {NAMEDOP_RETURN(NE);}
"&&"                 {NAMEDOP_RETURN(ANDAND);}
"||"                 {NAMEDOP_RETURN(OROR);}
"*="                 {NAMEDOP_RETURN(MUL_ASSIGN);}
"/="                 {NAMEDOP_RETURN(DIV_ASSIGN);}
"%="                 {NAMEDOP_RETURN(MOD_ASSIGN);}
"+="                 {NAMEDOP_RETURN(PLUS_ASSIGN);}
"-="                 {NAMEDOP_RETURN(MINUS_ASSIGN);}
"<<="                {NAMEDOP_RETURN(LS_ASSIGN);}
">>="                {NAMEDOP_RETURN(RS_ASSIGN);}
"&="                 {NAMEDOP_RETURN(AND_ASSIGN);}
"^="                 {NAMEDOP_RETURN(ER_ASSIGN);}
"|="                 {NAMEDOP_RETURN(OR_ASSIGN);}
"..."                {NAMEDOP_RETURN(ELLIPSIS);}

\/\/.*\n             {}

\/\*(.|\n)*?\*\/     {}

%%
