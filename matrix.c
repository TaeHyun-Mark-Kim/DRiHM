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

int** multiply_int_matrix(int** m1, int** m2, int m1_row, int m1_col, int m2_col){
    int** res = malloc(m1_row * sizeof(int*));
    for(int i = 0; i < m1_row; i++){
      res[i] = malloc(m2_col * sizeof(int));
    }
    for(int i = 0; i < m1_row; i++){
      for(int j = 0; j < m2_col; j++){
        int val = 0;
        for(int k = 0; k < m1_col; k++){
          val += m1[i][k] * m2[k][j];
        }
        res[i][j] = val;
      }
    }
    return res;
}

void print_int_matrix(int** mat, int row, int col){
    printf("%c", '[');
    for(int i = 0; i < row; i++){
      for(int j = 0; j < col; j++){
        if(i == (row - 1) && j == (col - 1)) printf("%d]\n", mat[i][j]);
        else if(i == 0 && j == 0) printf("%d, ", mat[i][j]);
        else if(j == (col - 1)) printf("%d\n", mat[i][j]);
        else if(j == 0) printf(" %d, ", mat[i][j]);
        else printf("%d, ", mat[i][j]);
      }
    }
}


int main(){
    int a1[] = {1, 2, 3};
    int* a[1];
    a[0] = a1;
    int b1[] = {1, 4, 7};
    int b2[] = {2, 5, 8};
    int b3[] = {3, 6, 9};
    int* b[3];
    b[0] = b1;
    b[1] = b2;
    b[2] = b3;
    int** result = multiply_int_matrix(a, b, 1, 3, 3);
    print_int_matrix(a, 1, 3);
    print_int_matrix(b, 3, 3);
    print_int_matrix(result, 1, 3);
}
