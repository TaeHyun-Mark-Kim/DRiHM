/* int_matrix* int_inverse(int_matrix* matrix, int dim){
  
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
     return((int_matrix*) 1); not sure if works
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
 			res2[h][l] = pow(-1,(h+l))*float_det_helper(res1,(dim-1));	 res2 = cofactor Matrix
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
*/

int main(){

    matrix a;
    matrix b;
    int determinant;
    int i;
    int j;
    int l;
    int h;
    int m;
    int k;
    a = [[1,2,3],[4,5,6],[7,2,9]];
    b = [[0,0,0],[0,0,0],[0,0,0]];

    prints("This is a sample program to calculate matrix inverse of: ");
    printm(a);

    determinant = det(a);

    prints("Determinant of the matrix is: ");
    print(determinant);

    if(determinant == 0){
        prints("Determinant of this matrix cannot be determined");
        return 0;
    }
    
    for(i = 0; i < 3; i = i + 1)
    {
        for(j = 0; j < 3; j = j + 1)
        {
            m=0;
            k=0;
            for(l = 0; l < 3; l = l + 1)
            {
                for(h = 0; h < 3; h = h + 1)
                {
                    if(l != i && h != j)
                    {
                        insert(b,m,k,select(a,h,l));
                        if(k < 3 - 2)
                        {
                            k = k + 1;
                        }
                        else
                        {
                            k=0;
                            m = m + 1;
                        }
                    }
                }
            }
        }
    }
    
}