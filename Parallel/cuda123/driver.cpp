
#include "driver.h"
#include <conio.h>

using std::cout;
using std::endl;


int main(int argc, char const *argv[]) {
  // Parse args
	if (argc < 3) {
    cout << "Invalid arguments" << endl;
	std::cin.get();
		exit(1);
	}

  // Load a bitmap image.
  Image image(argv[3]);


  // Clock start time.
  int num_seams = atoi(argv[2]);
  cout << "  drawing " << num_seams << " seams ..." << endl;
  clock_t begin = clock();

  // Remove seams.
  Seamcarver seamcarver(&image);
  seamcarver.removeSeams(num_seams);

  // Clock end time.
  clock_t end = clock();
  clock_t exec_time = end - begin;
  cout << ">> Execution time ..." << endl;
  cout << "   cycles: " << exec_time << endl;
  cout << "   time: " << ((double)exec_time /  CLOCKS_PER_SEC) << "s" << endl;

  // Clean up and return normally.
  image.save(argv[4]);
    cout<<"Press Any key to continue...";
  _getch();
  return 0;
}
