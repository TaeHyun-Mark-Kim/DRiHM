int main(){
  int i;
  int j;
  int k;
  matrix a;
  matrix b;
  int max;
  string s;
  max = 0;
  k = 0;
  a = [[3, 2, 4], [2, 0, 2], [4, 2, 3]];
  i = 0;
  j = 0;
  for(i; i < row(a); i = i + 1){
    for(j; j < col(a); j = j + 1){
      if (select(a, i, j) > max) max = select(a, i, j);
    }
  }
  max = max * 3;
  i = -1 * (max * 3);
  s = "The eigenvalues of matrix : ";
  prints(s);
  printm(a);
  s = "are the following : ";
  prints(s);
  for(i; i < max; i = i + 1){
     set(a, 0, 0, select(a, 0, 0) - i);
     set(a, 1, 1, select(a, 1, 1) - i);
     set(a, 2, 2, select(a, 2, 2) - i);
     if (det(a) == 0) print(i);
     set(a, 0, 0, select(a, 0, 0) + i);
     set(a, 1, 1, select(a, 1, 1) + i);
     set(a, 2, 2, select(a, 2, 2) + i);
  }
}
