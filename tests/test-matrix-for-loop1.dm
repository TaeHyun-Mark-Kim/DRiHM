int main(){
    matrix a;
    int i;
    a = transpose([[1,2,3],[4,5,6]]);
    for(i = 0; i < 2; i = i + 1){
        print(select(a,i,i));
    }
}