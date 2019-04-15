#include <stdio.h>
#include <stdlib.h>

int** add_int_matrix(int** m1, int** m2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    int** res = malloc(row * sizeof(int*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(int));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] + m2[i][j];
        }
    }
    return res;
}

int** subtract_int_matrix(int** m1, int** m2, int row, int col){
    int** res = malloc(row * sizeof(int*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(int));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] - m2[i][j];
        }
    }
    return res;
}


int main(){
    int a1[] = {1, 2};
    int a2[] = {3, 4};
    int* a[2];
    a[0] = a1;
    a[1] = a2;
    int b1[] = {5, 6};
    int b2[] = {7, 8};
    int* b[2];
    b[0] = b1;
    b[1] = b2;
    int** result = add_int_matrix(a, b, 2, 2);
    for(int i = 0; i < 2; i++){
        for(int j = 0; j < 2; j++){
            printf("%d\n", result[i][j]);
        }
    }
}
