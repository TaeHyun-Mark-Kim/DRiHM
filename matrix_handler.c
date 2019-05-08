#include <stdlib.h>
#include <stdio.h>
#include <string.h>

static void die(const char *message)
{
    perror(message);
    exit(1);
}

struct matrix {
  int num_rows;
  int num_cols;
  int** matrixAddr; // accessed [row][col]
//  int buildPosition;
};

typedef struct matrix matrix;


matrix* initMatrix(int* listOfValues, int num_cols, int num_rows) {
  int** matrixValues = malloc(num_rows * sizeof(int*));


  //set all values in matrix to NULL if list of values is NULL
  if (listOfValues == NULL) {
    for(int i = 0; i < num_rows; i++) {
      int* matrix_row = malloc(num_cols * sizeof(int));
      *(matrixValues + i) = matrix_row;
      for(int j = 0; j < num_cols; j++) {
        matrix_row[j] = 0;
      }
    }
  }

  //load values from a list of values
  else {
    for(int i = 0; i < num_cols; i++) {
      int* matrix_col = malloc(num_rows * sizeof(int));
      *(matrixValues + i) = matrix_col;
      for(int j = 0; j < num_rows; j++) {
        matrix_col[j] = listOfValues[i*num_rows + j];
      }
    }
  }

  //return a pointer to matrix struct
  matrix* result = malloc(sizeof(struct matrix));
  result->num_cols = num_cols;
  result->num_rows = num_rows;
  result->matrixAddr = matrixValues;
  //result->buildPosition = 0;
  return result;
}

matrix* initMatrix_CG( int num_cols, int num_rows) {
    return initMatrix(NULL, num_cols, num_rows);
}



void print_int_matrix(int** mat, int row, int col){
    printf("%c", '[ ');
    if (row == 0 && col == 0){
        printf("%c", ' ]');
    }
    for(int i = 0; i < row; i++){
      for(int j = 0; j < col; j++){
        if(i == (row - 1) && j == (col - 1)) printf("%d]\n", mat[i][j]);
        else if(i == 0 && j == 0) printf("%d, ", mat[i][j]);
        else if(j == (col - 1)) printf("%d\n", mat[i][j]);
        else if(j == 0) printf(" %d, ", mat[i][j]);
        else printf("%d, ", mat[i][j]);
      }
    }
    // printf("%c", ']');
}

void display(matrix* input) {
    int row = input->num_rows;
    int col = input->num_cols;
    for(int i = 0; i<row; i++) {
        for(int j=0; j<col; j++) {
            printf(" %d", input->matrixAddr[i][j]);
        }
        printf("\n");
    }
}

#ifdef BUILD_TEST
int main(int argc,char** argv) {
  //run tests of each function
  //initMatrix and display of empty matrix
  // matrix *null_matrix=initMatrix(NULL, 2, 2);
  // printf("NULL MATRIX: \n");
  // display(null_matrix);
}
#endif
