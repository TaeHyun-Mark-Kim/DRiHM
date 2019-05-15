int power(int b, int p){
    int i;
    int result;
    result = 1;
    for(i = 0; i < p; i = i + 1)
    {
        result = result * b; 
    }
    return result; 
}

int main(){

    matrix a;
    matrix b;
    matrix c;
    matrix d;
    int determinant;
    int i;
    int j;
    int l;
    int h;
    int m;
    int k;
    a = [[1,2,3],[4,5,6],[7,8,10]];
    b = [[0,0,0],[0,0,0],[0,0,0]];
    c = [[0,0],[0,0]];

    prints("This is a sample program to calculate matrix inverse of: ");
    printm(a);

    determinant = det(a);

    prints("Determinant of the matrix is: ");
    print(determinant);

    if(determinant == 0){
        prints("Inverse of this matrix cannot be determined");
        return 0;
    }


    for(i = 0; i < 3; i = i + 1)
    {
        for(j = 0; j < 3; j = j + 1)
        {
            c = [[0,0],[0,0]];
            for(k = 0; k < 2; k = k + 1)
            {
                
                for(l = 0; l < 2; l = l + 1)
                {
                    if(i == k && j == l){
                        insert(c,k,l,select(a,i+1,j+1));
                    } else if(i == k && j < l){
                        insert(c,k,l,select(a,i+1,j+l+1));
                    } else if(i < k && j == l){
                        insert(c,k,l,select(a,i+k+1,j+1));
                    } else if(i < k && j < l){
                        insert(c,k,l,select(a,i+k+1,j+l+1));
                    } else if(i == k && l < j){
                        insert(c,k,l,select(a,i+1,l));
                    } else if(i < k && j > l){
                        insert(c,k,l,select(a,i+k+1,l));
                    } else if(k < i && j == l){
                        insert(c,k,l,select(a,k,j+1));
                    } else if(k < i && l > j){
                        insert(c,k,l,select(a,k,j+l+1));
                    } else if(k < i && l < j){
                        insert(c,k,l,select(a,k,l));
                    }
                }

            }
            insert(b,i,j,det(c) * power(-1,i+j));
        }
    }

    prints("Inverse of matrix not divided by determinant:");
    d = transpose(b);
    printm(d);

        
    d = (a*d);
    for(i = 0; i < 3; i = i + 1){
        insert(d,i,i,select(d,i,i) / det(a));
    }

    prints("Matrix multiplied by its inverse: ");
    printm(d);


    

    
}