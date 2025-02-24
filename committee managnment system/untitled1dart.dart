import 'dart:io';
import 'dart:math';


class Member {
  int id;
  String name;

  Member(this.id, this.name);
}

void main() {
  // Lists to store members and winners
  List<Member> members = [];
  List<Member> winners = [];


  int monthlyContribution = 0;
  int totalAmount = 0;


  stdout.write("Enter monthly contribution amount: ");
  monthlyContribution = int.parse(stdin.readLineSync()!);

  int choice;
  do {

    print("\n1. Add Member");
    print("2. Display Members");
    print("3. Conduct Lucky Draw");
    print("4. Display Winners");
    print("5. Exit");
    stdout.write("Enter your choice: ");
    choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:

        stdout.write("Enter Member ID: ");
        int id = int.parse(stdin.readLineSync()!);
        stdout.write("Enter Member Name: ");
        String name = stdin.readLineSync()!;
        members.add(Member(id, name));
        print(" Member added: $name (ID: $id)");
        break;

      case 2:

        if (members.isEmpty) {
          print("No members available for lucky draw.");
        } else {
          print("\n--- Active Members ---");
          for (var member in members) {
            print("ID: ${member.id} | Name: ${member.name}");
          }
        }
        break;

      case 3:

        if (members.isEmpty) {
          print("\nAll members have won! No more draws.");
        } else {
          totalAmount = monthlyContribution * (members.length + winners.length);

          Random random = Random();
          int winnerIndex = random.nextInt(members.length);
          Member winner = members[winnerIndex];

          print("\n Monthly Lucky Draw Result ");
          print("Winner: ${winner.name} (ID: ${winner.id})");
          print("Prize Amount: Rs.$totalAmount");


          winners.add(winner);
          members.removeAt(winnerIndex);
        }
        break;

      case 4:
        if (winners.isEmpty) {
          print("No winners recorded yet.");
        } else {
          print("\n--- Winners List ---");
          for (var winner in winners) {
            print("Winner: ${winner.name} (ID: ${winner.id})");
          }
        }
        break;

      case 5:
        print("Exiting... Thank you!");
        break;

      default:
        print("Invalid choice. Please try again.");
    }
  } while (choice != 5);
}
