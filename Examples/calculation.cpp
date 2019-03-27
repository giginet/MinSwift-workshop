#include <iostream>

extern "C" {
    double calc();
}

int main() {
    std::cout << calc() << std::endl;
}
