import std;

#ifdef LOCAL
#define debug(x) std::cerr << #x << " = " << (x) << '\n'
#else
#define debug(x)
#endif

struct Person {
    int k;
    std::vector<int> who;
};

int main() {
    int N;
    std::cin >> N;
    std::vector<Person> persons(N);
    for (int i=0; i<N; i++) {
        std::cin >> persons[i].k;
        persons[i].who.resize(persons[i].k);
        for (int j = 0; j < persons[i].k; j++) {
            std::cin >> persons[i].who[j];
        }
    }
    int count, index;
    std::vector<int> giver(N);
    for (int i=0; i<N; i++) {
        count = 0;
        index = 0;
        for (int j=0; j<N; j++) {
            if (std::ranges::contains(persons[j].who, i+1)) {
                giver[index] = j+1;
                index++;
                count++;
            }
        }
        giver[index] = -1;
        std::cout << count;
        for (int j=0; j<N; j++) {
            if (giver[j] > 0) std::cout << " " << giver[j];
            else break;
        }
        std::cout << '\n';
    }
}
