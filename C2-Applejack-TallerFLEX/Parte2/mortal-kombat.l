%{
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

//modificar para que la probabilidad sea diferente. 1 = 100%, 0 = 0%
#define PROBABILIDAD 1
char mapas[4][10] = {"Arctika", "Metropolis", "Armory", "Hell"};
char mapa[10];
#define MAX_PERSONAJES 4
char personajes[MAX_PERSONAJES][11] = {"Johnny Cage","Kano","Liu Kang","Sub-Zero"};
#define MAX_COMBOS 2
#define MAX_ATAQUES_PREVIOS 5
char combosPersonajes[MAX_PERSONAJES][MAX_COMBOS][MAX_ATAQUES_PREVIOS][30]={
    {
        //combo 1 Johnny Cage
        {"2Y", "B", "B", "", ""},
        //combo 2 Johnny Cage
        {"X", "Y", "X", "", ""}
    },
    {
        //combo 1 Kano
        {"X", "X", "Y","", ""},
        //combo 2 Kano
        {"Y", "Y", "", "", ""}
    },
    {   //combo 1 Liu Kang
        {"X", "Y", "A", "", ""},
        //combo 2 Liu Kang
        {"Y", "X", "Y", "X", ""}
    },
    {
        //combo 1 Sub-Zero
        {"X", "Y", "B", "", ""},
        //combo 2 Sub-Zero
        {"Y", "X", "Y", "", ""}
    }
};

char nombreCombosPersonaje[MAX_PERSONAJES][MAX_COMBOS][30] = {
    {
        //combo 1 Johnny Cage
        "Comedy and Tragedy",
        //combo 2 Johnny Cage
        "Post Credits"
    },
    {
        //combo 1 Kano
        "Blood Worth Bottling",
        //combo 2 Kano
        "Come a Gutser"
    },
    {   //combo 1 Liu Kang
        "Twin Lotus",
        //combo 2 Liu Kang
        "Done Listening"
    },
    {
        //combo 1 Sub-Zero
        "Cold Encounter",
        //combo 2 Sub-Zero
        "New Threat"
    }
};

int damageComboPersonaje [MAX_PERSONAJES][MAX_COMBOS] = {
    {
        //combo 1 Johnny Cage
        10,
        //combo 2 Johnny Cage
        20
    },
    {
        //combo 1 Kano
        7,
        //combo 2 Kano
        20
    },
    {   //combo 1 Liu Kang
        10,
        //combo 2 Liu Kang
        20
    },
    {
        //combo 1 Sub-Zero
        10,
        //combo 2 Sub-Zero
        20
    }
};

char personaje[2][11] = {"", ""};
char personajePos[2] = {0, 0};
int vida[2] = {100, 100};

char nombreFatalitiesPersonaje[MAX_PERSONAJES][30] = {
    "Mr. Cage's Neighborhood",
    "Last Dance",
    "Burn Out",
    "Ice-Cutioner"
};

char fatalitiesPersonajes[MAX_PERSONAJES][MAX_ATAQUES_PREVIOS][30]={
    {
        //fatality Johnny Cage
        "RIGHT", "LEFT", "DOWN", "DOWN", "B"
    },
    {
        //fatality Kano
        "RIGHT", "DOWN", "DOWN", "X", ""
    },
    {   //fatality Liu Kang
        "DOWN", "LEFT", "DOWN", "RIGHT", "X"
    },
    {
        //fatality Sub-Zero
        "LEFT", "RIGHT", "LEFT", "Y", ""
    }
};

bool fueFatality = false;


char ataquesPrevios[2][MAX_ATAQUES_PREVIOS][30]={
    {"", "", "", "", ""},
    {"", "", "", "", ""}
};

char tambaleoMovimientos[10][30] = {"", "", "", "", "", "", "", "", "", ""};

bool tambaleo[2] = {false, false};
bool muerto[2] = {false, false};
int currentOption = 0;
int stage = 0;

int getOpponent(int a){
    if(a == 1)
        return 2;
    if(a == 2)
        return 1;
}

bool randomAttack(){
    
    return (rand()/(float)RAND_MAX) < PROBABILIDAD;
}

void printAttack(int player, int opponent, char* attackName, bool hit, int damage){
    printf("El personaje %s ha usado %s contra %s\n", personaje[player-1], attackName, personaje[opponent-1]);
    if(hit){
        printf("El ataque ha acertado\n");
        if(tambaleo[opponent-1]){
            printf("El personaje %s ha muerto\n", personaje[opponent-1]);
            muerto[opponent-1] = true;
            return;
        }
        vida[opponent-1] -= damage;
        if (vida[opponent-1] <= 0){
            vida[opponent-1] = 0;
            tambaleo[opponent-1] = true;
        }
        printf("El personaje %s ha recibido %d de daño\n", personaje[opponent-1], damage);
        printf("Vida restante de %s: %d\n", personaje[opponent-1], vida[opponent-1]);
        if(tambaleo[opponent-1]){
            for(int j=0;j<MAX_ATAQUES_PREVIOS; j++){
                strcpy(ataquesPrevios[player-1][j], "");
            }
            printf("El personaje %s está tambaleándose\n", personaje[opponent-1]);
        }
    }else{
        printf("El ataque ha fallado\n");
    }
}

bool checkVida(int player){
        if(vida[player-1] <= 0){
            printf("El personaje %s no puede atacar porque está muerto\n", personaje[player-1]);
            return false;
        }
        if(tambaleo[player-1]){
            printf("El personaje %s no puede atacar porque está tambaleándose\n", personaje[player-1]);
            return false;
        }
        return true;
}

int getLastValidIndex(char array[][30]){
    int i = 0;
    while(strcmp(array[i], "") != 0 && i<MAX_ATAQUES_PREVIOS){
        i++;
    }
    return i;
}

void registerAttack(int player, int opponent, char* key, bool hit) {
    if(hit){
        for(int i=0;i<MAX_ATAQUES_PREVIOS; i++){
            strcpy(ataquesPrevios[opponent-1][i], "");
        }
        if (getLastValidIndex(ataquesPrevios[player-1]) == MAX_ATAQUES_PREVIOS){
            for(int i=0;i<MAX_ATAQUES_PREVIOS-1; i++){
                strcpy(ataquesPrevios[player-1][i], ataquesPrevios[player-1][i+1]);
            }
            strcpy(ataquesPrevios[player-1][MAX_ATAQUES_PREVIOS-1], key);
        }else{
            strcpy(ataquesPrevios[player-1][getLastValidIndex(ataquesPrevios[player-1])], key);
        }
        
    }
}

void registerMovement(int player, char* movement){
    if(getLastValidIndex(ataquesPrevios[player-1]) == MAX_ATAQUES_PREVIOS){
        for(int i=0;i<MAX_ATAQUES_PREVIOS-1; i++){
            strcpy(ataquesPrevios[player-1][i], ataquesPrevios[player-1][i+1]);
        }
        strcpy(ataquesPrevios[player-1][MAX_ATAQUES_PREVIOS-1], movement);
    }else{
        strcpy(ataquesPrevios[player-1][getLastValidIndex(ataquesPrevios[player-1])], movement);
    }
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
                    printf("El personaje %s ha realizado el combo %s\n", personaje[player-1], nombreCombosPersonaje[personajePos[player-1]][i]);
                    vida[getOpponent(player)-1] -= damageComboPersonaje[personajePos[player-1]][i];
                    if (vida[getOpponent(player)-1] <= 0){
                        vida[getOpponent(player)-1] = 0;
                        tambaleo[getOpponent(player)-1] = true;
                    }
                    printf("El personaje %s ha recibido %d de daño adicionales\n", personaje[getOpponent(player)-1], damageComboPersonaje[personajePos[player-1]][i]);
                    printf("Vida restante de %s: %d\n", personaje[getOpponent(player)-1], vida[getOpponent(player)-1]);
                    if(tambaleo[getOpponent(player)-1]){
                        printf("El personaje %s está tambaleándose\n", personaje[getOpponent(player)-1]);
                    }

                    for(int j=0;j<MAX_ATAQUES_PREVIOS; j++){
                        strcpy(ataquesPrevios[player-1][j], "");
                    }
                    break;
                }
            }
        }    
}

bool checkFatality(int player){
    int totalMovimientosTambaleo = getLastValidIndex(tambaleoMovimientos);
    int totalMovimientosFatality = getLastValidIndex(fatalitiesPersonajes[personajePos[player-1]]);
    while(totalMovimientosFatality>=0 && totalMovimientosTambaleo>=0){
        if(strcmp(tambaleoMovimientos[totalMovimientosTambaleo], fatalitiesPersonajes[personajePos[player-1]][totalMovimientosFatality]) != 0){
            return false;
        }
        totalMovimientosTambaleo--;
        totalMovimientosFatality--;
        if(totalMovimientosFatality == 0){
            printf("El personaje %s ha realizado la fatality %s\n", personaje[player-1], nombreFatalitiesPersonaje[personajePos[player-1]]);
            printf("El personaje %s ha sido eliminado\n", personaje[getOpponent(player)-1]);
            fueFatality = true;
            return true;
        }
    }
}

void registrarMovimientoTambaleo( char* movimiento){
    int x = getLastValidIndex(tambaleoMovimientos);
    strcpy(tambaleoMovimientos[x], movimiento);
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
        bool oponenteTambaleando = false;
        if(tambaleo[getOpponent(player)-1]){
            oponenteTambaleando = true;
        }
        if(strcmp(direction, "UP") == 0){
            printf("El personaje %s se ha movido hacia arriba\n", personaje[player-1]);
            registerMovement(player, "UP");
            if(oponenteTambaleando){
                registrarMovimientoTambaleo("UP");
            }
        }else if(strcmp(direction, "DOWN") == 0){
            printf("El personaje %s se ha movido hacia abajo\n", personaje[player-1]);
            registerMovement(player, "DOWN");
            if(oponenteTambaleando){
                registrarMovimientoTambaleo("DOWN");
            }
        }else if(strcmp(direction, "LEFT") == 0){
            printf("El personaje %s se ha movido hacia la izquierda\n", personaje[player-1]);
            registerMovement(player, "LEFT");
            if(oponenteTambaleando){
                registrarMovimientoTambaleo("LEFT");
            }
        }else if(strcmp(direction, "RIGHT") == 0){
            printf("El personaje %s se ha movido hacia la derecha\n", personaje[player-1]);
            registerMovement(player, "RIGHT");
            if(oponenteTambaleando){
                registrarMovimientoTambaleo("RIGHT");
            }
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

        bool puedeMoverse = checkVida(player);
        if(!puedeMoverse){
            break;
        }

        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "First Take");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "Bloody Knuckles");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Power Punch");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Straight Chop");
        }
        if(muerto[opponent-1]){
            break;
        }
        if(tambaleo[opponent-1]){
            registrarMovimientoTambaleo("X");
            checkFatality(player);
        }
        if(fueFatality){
            break;
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, "X", hit);
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

        bool puedeMoverse = checkVida(player);
        if(!puedeMoverse){
            break;
        }
        
        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "Hollywood Haymaker");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "Scarred");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Chosen Strike");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Palm Strike");
        }
        if(muerto[opponent-1]){
            break;
        }
        if(tambaleo[opponent-1]){
            registrarMovimientoTambaleo("Y");
            checkFatality(player);
        }
        if(fueFatality){
            break;
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, "Y", hit);
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

        bool puedeMoverse = checkVida(player);
        if(!puedeMoverse){
            break;
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
        if(muerto[opponent-1]){
            break;
        }
        if(tambaleo[opponent-1]){
            registrarMovimientoTambaleo("A");
            checkFatality(player);
        }
        if(fueFatality){
            break;
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, "A", hit);
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
        
        bool puedeMoverse = checkVida(player);
        if(!puedeMoverse){
            break;
        }

        if(strcmp(personaje[player-1], "Johnny Cage") == 0){
            strcpy(attackName, "Fight Dirty");
        }else if(strcmp(personaje[player-1], "Kano") == 0){
            strcpy(attackName, "Face Breaker");
        }else if(strcmp(personaje[player-1], "Liu Kang") == 0){
            strcpy(attackName, "Shaolin Spin");
        }else if(strcmp(personaje[player-1], "Sub-Zero") == 0){
            strcpy(attackName, "Roundhouse");
        }
        if(muerto[opponent-1]){
            break;
        }
        if(tambaleo[opponent-1]){
            registrarMovimientoTambaleo("B");
            checkFatality(player);
        }
        if(fueFatality){
            break;
        }
        printAttack(player, opponent, attackName, hit, damage);
        registerAttack(player, opponent, "B", hit);
        checkCombo(player);
    }
}




.       { /* Ignorar cualquier otro caracter */}
\n      { /* Ignorar saltos de línea */ }
<<EOF>> {

            
            printf("---------------------------------------------------------\n");
            printf("Fin de la partida, gracias por jugar\n");
            printf("Estadísticas de la partida:\n");
            printf("Personaje 1: %s\n", personaje[0]);
            printf("Vida: %d\n", vida[0]);
            printf("Personaje 2: %s\n", personaje[1]);
            printf("Vida: %d\n", vida[1]);
            printf("---------------------------------------------------------\n");
            if (vida[0] > vida[1]){
                printf("El ganador es el personaje %s\n", personaje[0]);
            }else if(vida[0] < vida[1]){
                printf("El ganador es el personaje %s\n", personaje[1]);
            }else{
                printf("Hubo un empate\n");
            }
            if(fueFatality){
                printf("Hubo fatality\n");
            }
            printf("---------------------------------------------------------\n");
            yyterminate();
        }

%%

int main() {
    yylex();
    return 0;
}