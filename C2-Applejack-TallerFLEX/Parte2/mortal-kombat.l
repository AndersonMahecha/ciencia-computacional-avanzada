%{
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
char mapas[4][10] = {"Arctika", "Metropolis", "Armory", "Hell"};
char mapa[10];
char personajes[4][11] = {"Johnny Cage","Kano","Liu Kang","Sub-Zero"};
char personaje[2][11] = {"", ""};
int vida[2] = {100, 100};
bool tambaleo[2] = {false, false};
int currentOption = 0;
int stage = 0;

int getOpponent(int a){
    if(a == 1)
        return 2;
    if(a == 2)
        return 1;
}

bool randomAttack(){
    return rand() % 2;
}

void printAttack(int player, int opponent, char* attackName, bool hit, int damage){
    printf("El personaje %s ha usado %s contra %s\n", personaje[player-1], attackName, personaje[opponent-1]);
    if(hit){
        printf("El ataque ha acertado\n");
        vida[opponent-1] -= damage;
        printf("El personaje %s ha recibido %d de daño\n", personaje[opponent-1], damage);
        printf("Vida restante de %s: %d\n", personaje[opponent-1], vida[opponent-1]);
    }else{
        printf("El ataque ha fallado\n");
    }
}


/* 
    0 - Selección de mapa
    1 - Selección de personaje 1
    2 - Selección de personaje 2
    3 - Combate
    4 - Fin de combate
*/

%}
%array
/* Definitions of all possible buttons, triggers and directions. Joycon buttons are mapped to Xbox buttons. */
A     [aA]
B     [bB]
X     [xX]
Y     [yY]

LT    [ltLTLTRIGGER]
RT    [rtRTRTRIGGER]
LB    [lbLBLBUTTON]
RB    [rbRBRBUTTON]

UP    [uU][pP]
DOWN  [dD][oO][wW][nN]
LEFT  [lL][eE][fF][tT]
RIGHT [rR][iI][gG][hH][tT]

PLAYER [12]

MOVEMENT {UP}|{DOWN}|{LEFT}|{RIGHT}
ATTACK {A}|{B}|{X}|{Y}|{LT}|{RT}|{LB}|{RB}



%%

{LEFT} {
    if(stage == 0 || stage == 1 || stage == 2){
        currentOption--;
        if(currentOption < 0){
            currentOption = 3;
        }
    }
}
{RIGHT} {
    if(stage == 0 || stage == 1 || stage == 2){
        currentOption++;
        if(currentOption > 3){
            currentOption = 0;
        }
    }
}

{A} {
    switch(stage){
        case 0:
            strcpy(mapa, mapas[currentOption]);
            currentOption = 0;
            printf("Mapa seleccionado: %s\n", mapa);
            stage = 1;
            break;
        case 1:
            strcpy(personaje[0], personajes[currentOption]);
            currentOption = 0;
            printf("Personaje 1 seleccionado: %s\n", personaje[0]);
            stage = 2;
            break;
        case 2:
            // los personajes no pueden ser el mismo
            if(strcmp(personajes[currentOption], personaje[0]) == 0){
                printf("No puedes seleccionar el mismo personaje\n");
                break;
            }
            strcpy(personaje[1], personajes[currentOption]);
            currentOption = 0;
            printf("Personaje 2 seleccionado: %s\n", personaje[1]);
            stage = 3;
            break;
    }
}

{PLAYER}{MOVEMENT} {
    //El jugador x se ha movido a la dirección
    if(stage==3){
        int player = yytext[0]-'0';
        char direction[10];
        strcpy(direction, yytext+1);
        if (tambaleo[player-1]){
            printf("El personaje %s no puede moverse porque está tambaleándose\n", personaje[player-1]);
            return;
        }
        if(vida[player-1] <= 0){
            printf("El personaje %s no puede moverse porque está muerto\n", personaje[player-1]);
            return;
        }
        if(strcmp(direction, "UP") == 0){
            printf("El personaje %s se ha movido hacia arriba\n", personaje[player-1]);
        }else if(strcmp(direction, "DOWN") == 0){
            printf("El personaje %s se ha movido hacia abajo\n", personaje[player-1]);
        }else if(strcmp(direction, "LEFT") == 0){
            printf("El personaje %s se ha movido hacia la izquierda\n", personaje[player-1]);
        }else if(strcmp(direction, "RIGHT") == 0){
            printf("El personaje %s se ha movido hacia la derecha\n", personaje[player-1]);
        }
    }
}

{PLAYER}{A} {
    if (stage == 3){
        int player =  yytext[0]-'0';
        int opponent = getOpponent(player);
        bool hit = randomAttack();
        int damage = 5;
        char attackName[30];
        if(vida[player-1] <= 0){
            printf("El personaje %s no puede atacar porque está muerto\n", personaje[player-1]);
            return;
        }
        if(tambaleo[player-1]){
            printf("El personaje %s no puede atacar porque está tambaleándose\n", personaje[player-1]);
            return;
        }
        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "Sudden Violence");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "High Boot");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Dragon Kick");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Lin Kuei Kick");
        }
        printAttack(player, opponent, attackName, hit, damage);
    }
}






.       { /* Ignorar cualquier otro caracter */}
\n      { /* Ignorar saltos de línea */ }
%%

int main() {
    yylex();
    return 0;
}