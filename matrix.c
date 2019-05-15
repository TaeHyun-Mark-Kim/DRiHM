#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

struct int_matrix {
    void** matrix_pointer;
    int count;
};

typedef struct int_matrix int_matrix;
typedef struct float_matrix float_matrix;

void** init_empty_matrix(){
    void** res;
    return res;
}

int_matrix* init_int_matrix(int row, int col){
    void** res = malloc(row * sizeof(void*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(double));
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = res;
    result->count = 0;
    return result;
}



int_matrix* fill_int_matrix(int_matrix* dest, int row_size, int col_size, int element){
    int offset = dest->count;
    int row = offset / col_size;
    int col = offset % col_size;
    int** mat = (int**) dest->matrix_pointer;
    mat[row][col] = element;
    //dest->matrix_pointer[row][col] = element;
    dest->count++;
    return dest;
}

int_matrix* fill_float_matrix(int_matrix* dest, int row_size, int col_size, double element){
    int offset = dest->count;
    int row = offset / col_size;
    int col = offset % col_size;
    double** mat = (double**) dest->matrix_pointer;
    mat[row][col] = element;
    dest->count++;
    return dest;
}

char** init_char_matrix(char* source, int row, int col){
    char** res = malloc(row * sizeof(char*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(char));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = *source;
            source++;
        }
    }
    return res;
}

int_matrix* add_int_matrix(int_matrix* matrix1, int_matrix* matrix2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    int** m1 = (int**) matrix1->matrix_pointer;
    int** m2 = (int**) matrix2->matrix_pointer;
    int** res = malloc(row * sizeof(int*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(int));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] + m2[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

int_matrix* add_float_matrix(int_matrix* matrix1, int_matrix* matrix2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    double** m1 = (double**) matrix1->matrix_pointer;
    double** m2 = (double**) matrix2->matrix_pointer;
    double** res = malloc(row * sizeof(double*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(double));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] + m2[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

char** add_char_matrix(char** m1, char** m2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    char** res = malloc(row * sizeof(char*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(char));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] + m2[i][j];
        }
    }
    return res;
}

int_matrix* subtract_int_matrix(int_matrix* matrix1, int_matrix* matrix2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    int** m1 = (int**) matrix1->matrix_pointer;
    int** m2 = (int**) matrix2->matrix_pointer;
    int** res = malloc(row * sizeof(int*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(int));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] - m2[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

int_matrix* subtract_float_matrix(int_matrix* matrix1, int_matrix* matrix2, int row, int col){
    //Define 2-D array as an array of pointers to pointers
    //where each points to an array of integers
    double** m1 = (double**) matrix1->matrix_pointer;
    double** m2 = (double**) matrix2->matrix_pointer;
    double** res = malloc(row * sizeof(double*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(double));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] - m2[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

char** subtract_char_matrix(char** m1, char** m2, int row, int col){
    char** res = malloc(row * sizeof(char*));
    for(int i = 0; i < row; i++){
        res[i] = malloc(col * sizeof(char));
    }
    for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[i][j] = m1[i][j] - m2[i][j];
        }
    }
    return res;
}

int_matrix* multiply_int_matrix(int_matrix* matrix1, int_matrix* matrix2, int m1_row, int m1_col, int m2_col){
    int** m1 = (int**) matrix1->matrix_pointer;
    int** m2 = (int**) matrix2->matrix_pointer;
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
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

int_matrix* multiply_float_matrix(int_matrix* matrix1, int_matrix* matrix2, int m1_row, int m1_col, int m2_col){
    double** m1 = (double**) matrix1->matrix_pointer;
    double** m2 = (double**) matrix2->matrix_pointer;
    double** res = malloc(m1_row * sizeof(double*));
    for(int i = 0; i < m1_row; i++){
      res[i] = malloc(m2_col * sizeof(double));
    }
    for(int i = 0; i < m1_row; i++){
      for(int j = 0; j < m2_col; j++){
        double val = 0.0;
        for(int k = 0; k < m1_col; k++){
          val += m1[i][k] * m2[k][j];
        }
        res[i][j] = val;
      }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    return result;
}

char** multiply_char_matrix(char** m1, char** m2, int m1_row, int m1_col, int m2_col){
    char** res = malloc(m1_row * sizeof(char*));
    for(int i = 0; i < m1_row; i++){
      res[i] = malloc(m2_col * sizeof(char));
    }
    for(int i = 0; i < m1_row; i++){
      for(int j = 0; j < m2_col; j++){
        char val = 0;
        for(int k = 0; k < m1_col; k++){
          val += m1[i][k] * m2[k][j];
        }
        res[i][j] = val;
      }
    }
    return res;
}

void print_int_matrix(int_matrix* mat_ptr, int row, int col){
    int** mat = (int**) mat_ptr->matrix_pointer;
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

void print_float_matrix(int_matrix* mat_ptr, int row, int col){
    double** mat = (double**) mat_ptr->matrix_pointer;
    printf("%c", '[');
    for(int i = 0; i < row; i++){
      for(int j = 0; j < col; j++){
        if(i == (row - 1) && j == (col - 1)) printf("%f]\n", mat[i][j]);
        else if(i == 0 && j == 0) printf("%f, ", mat[i][j]);
        else if(j == (col - 1)) printf("%f\n", mat[i][j]);
        else if(j == 0) printf(" %f, ", mat[i][j]);
        else printf("%f, ", mat[i][j]);
      }
    }
}
void print_char_matrix(char** mat, int row, int col){
    printf("%c", '[');
    for(int i = 0; i < row; i++){
      for(int j = 0; j < col; j++){
        if(i == (row - 1) && j == (col - 1)) printf("%c]\n", mat[i][j]);
        else if(i == 0 && j == 0) printf("%c, ", mat[i][j]);
        else if(j == (col - 1)) printf("%c\n", mat[i][j]);
        else if(j == 0) printf(" %c, ", mat[i][j]);
        else printf("%c, ", mat[i][j]);
      }
    }
}

int** int_cofactorM(int** m, int dim, int r, int c){
  int d = dim - 1;
	int** res = malloc(d * sizeof(int*));
	for(int i = 0; i < d; i++){
		res[i] = malloc(d * sizeof(int));
	}
	for(int i = 1; i < dim; i++){
		for(int j = 0; j < dim; j++){
      if(j < c){
        res[i - 1][j] = m[i][j];
      }
      else if (j > c){
        res[i - 1][j - 1] = m[i][j];
      }
    }
  }
  return res;
}

int int_det_helper(int** m, int dim){
	int d = 0;
  if (dim == 0){
    return 1;
  }
  if (dim == 1){
    return m[0][0];
  }
	if (dim == 2){
		return ( (m[0][0] * m[1][1]) - (m[1][0] * m[0][1]));
	}
	for(int i = 0; i < dim; i++){
    d+= ((int) pow(-1.0, (double) i)) * m[0][i] * int_det_helper(int_cofactorM(m, dim, 0, i), dim - 1);
	}
	return d;
}

int int_det(int_matrix* matrix, int dim){
  int** m = (int**) matrix->matrix_pointer;
  return int_det_helper(m, dim);
}

double** float_cofactorM(double** m, int dim, int r, int c){
  int d = dim - 1;
	double** res = malloc(d * sizeof(double*));
	for(int i = 0; i < d; i++){
		res[i] = malloc(d * sizeof(double));
	}
	for(int i = 1; i < dim; i++){
		for(int j = 0; j < dim; j++){
      if(j < c){
        res[i - 1][j] = m[i][j];
      }
      else if (j > c){
        res[i - 1][j - 1] = m[i][j];
      }
    }
  }
  return res;
}

double float_det_helper(double** m, int dim){
	int d = 0;
  if (dim == 0){
    return 1;
  }
  if (dim == 1){
    return m[0][0];
  }
	if (dim == 2){
		return ( (m[0][0] * m[1][1]) - (m[1][0] * m[0][1]));
	}
	for(int i = 0; i < dim; i++){
    d+= ((int) pow(-1.0, (double) i)) * m[0][i] * float_det_helper(float_cofactorM(m, dim, 0, i), dim - 1);
	}
	return d;
}

double float_det(int_matrix* matrix, int dim){
  double** m = (double**) matrix->matrix_pointer;
  return float_det_helper(m, dim);
}

int_matrix* int_transpose(int_matrix* matrix, int row, int col){
  int** m1 = (int**) matrix->matrix_pointer;
  int** res = malloc(col * sizeof(int*));

  for(int i = 0; i < col; i++){
        res[i] = malloc(row * sizeof(int));
    }

  for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[j][i] = m1[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    
    return result;
}

int_matrix* float_transpose(int_matrix* matrix, int row, int col){
  double** m1 = (double**) matrix->matrix_pointer;
  double** res = malloc(col * sizeof(double*));

  for(int i = 0; i < col; i++){
        res[i] = malloc(row * sizeof(double));
    }

  for(int i = 0; i < row; i++){
        for(int j = 0; j < col; j++){
            res[j][i] = m1[i][j];
        }
    }
    int_matrix* result = malloc(sizeof(int_matrix));
    result->matrix_pointer = (void**) res;
    
    return result;
}

int_matrix* int_inverse(int_matrix* matrix, int dim){
  
  int** m = (int**) matrix->matrix_pointer;
  double** res1 = malloc(dim * sizeof(double*));
  double** res2 = malloc(dim * sizeof(double*));

  for(int i = 0; i < dim; i++){
        res1[i] = malloc(dim * sizeof(double));
        res2[i] = malloc(dim * sizeof(double));
    }

  int det = int_det_helper(m, dim);

  if (det == 0){
    return NULL;
  }
  if (dim == 1){
    return((int_matrix*) 1); //not sure if works
  }


  for (int h = 0; h < dim; h++)
		for (int l=0; l<dim; l++){
			int n=0;
			int k=0;
			for (int i=0; i < dim; i++)
				for (int j=0; j < dim; j++)
					if (i != h && j != l){
						res1[n][k] = m[i][j];
						if (k<(n-2))
							k++;
						else{
							k=0;
							m++;
						}
					}
			res2[h][l] = pow(-1,(h+l))*float_det_helper(res1,(dim-1));	// res2 = cofactor Matrix
    }

  for(int i = 0; i < dim; i++){
    for(int j = 0; j < dim; j++){
        res1[j][i] = res2[i][j]/det;
    }
  }

  int_matrix* result = malloc(sizeof(int_matrix));
  result->matrix_pointer = (void**) res1;

	return result;
}



#ifdef BUILD_TEST
int main(){

    int a1[] = {1, 2, 3,4,5,6,7,2,9};
    //int* a[1];
    //a[0] = a1;
    int_matrix* res = init_int_matrix(3, 3);
    int_matrix* res2 = init_int_matrix(3, 3);
    int a1_length = sizeof(a1) / sizeof(int);
    // printf("The length is %d", a1_length);
    for(int i = 0; i < a1_length; i++){
      fill_int_matrix(res, 3, 3, a1[i]);
    }

    res2 = int_inverse(res, 3);

    print_int_matrix(res2, 3, 3);
    /*
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
    int c[] = {1, 2, 3, 4, 5, 6};
    int** res1 = init_int_matrix(c, 2, 3);
    print_int_matrix(res1, 2, 3);
    float d[] = {1.3, 2.4, 3.52, 4.3, 5.56, 6.72};
    float** res2 = init_float_matrix(d, 2, 3);
    print_float_matrix(res2, 2, 3);
    char e[] = {'a', 'b', 'c', 'd', 'e', 'f'};
    char** res3 = init_char_matrix(e, 3, 2);
    print_char_matrix(res3, 3, 2);
    float f1[] = {1.2, 2.56, 3};
    float f2[] = {3.4, 6.66, 4.33};
    float** res4 = init_float_matrix(f1, 1, 3);
    float** res5 = init_float_matrix(f2, 1, 3);
    float** res6 = add_float_matrix(res4, res5, 1, 3);
    print_float_matrix(res6, 1, 3);

    int g2[] = {1, 2, 3, 4};
    int** res8 = init_int_matrix(g2, 2, 2);
    print_int_matrix(res8, 2, 2);
    printf("%d\n", int_det(res8, 2));
    int g1[] = {1, 2, 3, 4, 2, 1, 3, 4, 1, 2, 4, 3, 3, 1, 2, 4};
    int** res7 = init_int_matrix(g1, 4, 4);
    print_int_matrix(res7, 4, 4);
    printf("%d\n", int_det(res7, 4));
    int g3[] = {1, 3, 4, 7, 6, 4, 7, 3, 4, 1, 4, 8, 9, 1, 0, 3, 8, 2, 7, 6, 2, 4, 7, 0, 8};
    int** res9 = init_int_matrix(g3, 5, 5);
    print_int_matrix(res9, 5, 5);
    printf("%d\n", int_det(res9, 5));
    */
}
#endif
