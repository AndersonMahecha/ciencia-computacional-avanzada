%{
int numChars = 0, numWords = 0, numLines = 0;
%}
%%
\n {numLines++; numChars++;} ## Busca saltos de linea. Cada salto de linea lo cuneta como una linea, y lo cuenta como un caracter.
[^ \t\n]+ {numWords++; numChars += yyleng;} ## Busca caracteres agrupados, que no sean tabs o saltos de linea. Cada grupo lo cuenta como 1, y suma el tamano a la cantidad de caracteres.
. {numChars++;} ## Cuenta cada caracter suelto.
%%
int main() {
yylex();
 printf("%d\t%d\t%d\n", numChars, numWords, numLines);
}
