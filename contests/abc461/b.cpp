import std;

int main() {
    int N;
    std::cin >> N;
    std::vector<int> A(N), B(N);
    for (int i=0; i<N; i++) std::cin >> A[i];
    for (int i=0; i<N; i++) std::cin >> B[i];
    for (int i=0; i<N; i++) {
        if (i+1 != B[A[i]-1]) {
            std::cout << "No" << '\n';
            return 0;
        }
    }
    std::cout << "Yes" << '\n';
    return 0;
}
