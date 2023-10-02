%{
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
char mapas[4][10] = {"Arctika", "Metropolis", "Armory", "Hell"};
char mapa[10];
char personajes[4][11] = {"Johnny Cage","Kano","Liu Kang","Sub-Zero"};
#define MAX_COMBOS 2
char combosPersonajes[4][MAX_COMBOS][5][30]={
    {
        //combo 1 Johnny Cage
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"},
        //combo 2 Johnny Cage
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"}
    },
    {
        //combo 1 Kano
        {"Bloody Knuckles", "Bloody Knuckles", "Scarred","", ""},
        //combo 2 Kano
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"}
    },
    {   //combo 1 Liu Kang
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"},
        //combo 2 Liu Kang
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"}
    },
    {
        //combo 1 Sub-Zero
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"},
        //combo 2 Sub-Zero
        {"Combo 1", "Combo 2", "Combo 3", "Combo 4", "Combo 5"}
    }
};

char personaje[2][11] = {"", ""};
char personajePos[2] = {0, 0};
int vida[2] = {100, 100};

#define MAX_ATAQUES_PREVIOS 5
char ataquesPrevios[2][MAX_ATAQUES_PREVIOS][30]={
    {"", "", "", "", ""},
    {"", "", "", "", ""}
};

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
    //return rand() % 2;
    return 1;
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

void checkVida(int player){
        if(vida[player-1] <= 0){
            printf("El personaje %s no puede atacar porque está muerto\n", personaje[player-1]);
            return;
        }
        if(tambaleo[player-1]){
            printf("El personaje %s no puede atacar porque está tambaleándose\n", personaje[player-1]);
            return;
        }
}

void registerAttack(int player, int opponent, char* attackName, bool hit) {
    if(hit){
        for(int i=0;i<MAX_ATAQUES_PREVIOS; i++){
            strcpy(ataquesPrevios[opponent-1][i], "");
        }
        for(int i=0;i<MAX_ATAQUES_PREVIOS; i++){
            if(strcmp(ataquesPrevios[player-1][i], "") == 0){
                strcpy(ataquesPrevios[player-1][i], attackName);
                break;
            }
        }
    }
}

int getLastValidIndex(char array[][30]){
    int i = 0;
    while(strcmp(array[i], "") != 0 && i<MAX_ATAQUES_PREVIOS){
        i++;
    }
    return i;
}


void checkCombo(int player){
        for(int i=0;i<MAX_COMBOS;i++){
            int totalAtaquesPrevios = getLastValidIndex(ataquesPrevios[player-1]);
            int totalAtaquesCombo = getLastValidIndex(combosPersonajes[personajePos[player-1]][i]);
            while(totalAtaquesCombo>=0 && totalAtaquesPrevios>=0){
                if(strcmp(ataquesPrevios[player-1][totalAtaquesPrevios], combosPersonajes[personajePos[player-1]][i][totalAtaquesCombo]) != 0){
                    break;
                }
                totalAtaquesPrevios--;
                totalAtaquesCombo--;
                if(totalAtaquesCombo == 0){
                    printf("combo para el personaje %s\n", personaje[player-1]);
                }
            }
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

PLAYER_1 1
PLAYER_2 2
PLAYER [PLAYER_1|PLAYER_2]

MOVEMENT {UP}|{DOWN}|{LEFT}|{RIGHT}

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
            personajePos[0] = currentOption;
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
            personajePos[1] = currentOption;
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

{PLAYER}{X} {
    if (stage == 3){
        int player =  yytext[0]-'0';
        int opponent = getOpponent(player);
        bool hit = randomAttack();
        int damage = 5;
        char attackName[30];

        checkVida(player);

        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "Sudden Violence");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "Bloody Knuckles");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Dragon Kick");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Lin Kuei Kick");
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, attackName, hit);
        checkCombo(player);
    }
}

{PLAYER}{Y} {
    if (stage == 3){
        int player =  yytext[0]-'0';
        int opponent = getOpponent(player);
        bool hit = randomAttack();
        int damage = 5;
        char attackName[30];

        checkVida(player);
        
        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "Sudden Violence");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "Scarred");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Dragon Kick");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Lin Kuei Kick");
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, attackName, hit);
        checkCombo(player);
    }
}

{PLAYER}{A} {
    if (stage == 3){
        int player =  yytext[0]-'0';
        int opponent = getOpponent(player);
        bool hit = randomAttack();
        int damage = 5;
        char attackName[30];

        checkVida(player);

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
        registerAttack(player, opponent, attackName, hit);
        checkCombo(player);
    }
}

{PLAYER}{B} {
    if (stage == 3){
        int player =  yytext[0]-'0';
        int opponent = getOpponent(player);
        bool hit = randomAttack();
        int damage = 5;
        char attackName[30];
        
        checkVida(player);

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
        registerAttack(player, opponent, attackName, hit);
        checkCombo(player);
    }
}




.       { /* Ignorar cualquier otro caracter */}
\n      { /* Ignorar saltos de línea */ }
%%

int main() {
    yylex();
    return 0;
}