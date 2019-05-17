int main(){
    matrix a;
    a = transpose([[1,2,3],[4,5,6]]);
    insert(a,1,1,8);
    print(select(a,1,1));    
}