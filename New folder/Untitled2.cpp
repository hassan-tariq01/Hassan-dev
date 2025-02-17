#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <ctime>
#include <algorithm>
using namespace std;

// Member Structure
struct Member {
    int id;
    string name;
};

// Committee Class
class Committee {
private:
    vector<Member> members;       // List of active members for draw
    vector<Member> winners;       // List of winners
    int monthlyContribution;      // Monthly contribution amount
    int totalAmount = 0;         // Total monthly collection

public:
    // Constructor
    Committee(int contribution) : monthlyContribution(contribution) {}

    // Add a new member
    void addMember(int id, const string& name) {
        members.push_back({id, name});
        cout << "✅ Member added: " << name << " (ID: " << id << ")\n";
    }

    // Display all current members
    void displayMembers() {
        if (members.empty()) {
            cout << "No members available for lucky draw.\n";
            return;
        }
        cout << "\n--- Active Members ---\n";
        for (const auto& member : members) {
            cout << "ID: " << member.id << " | Name: " << member.name << "\n";
        }
    }

    // Conduct Monthly Lucky Draw
    void monthlyLuckyDraw() {
        if (members.empty()) {
            cout << "\nAll members have won! No more draws.\n";
            return;
        }

        // Calculate Monthly Collection
        totalAmount = monthlyContribution * (members.size() + winners.size());

        // Randomly select a winner
        srand(time(0));
        int winnerIndex = rand() % members.size();
        Member winner = members[winnerIndex];

        // Display the winner
        cout << "\n🎉 Monthly Lucky Draw Result 🎉\n";
        cout << "Winner: " << winner.name 
             << " (ID: " << winner.id << ")\n"
             << "Prize Amount: Rs." << totalAmount << "\n";

        // Store the winner and remove them from future draws
        winners.push_back(winner);
        members.erase(members.begin() + winnerIndex);
    }

    // Display Lucky Draw Winners
    void displayWinners() {
        if (winners.empty()) {
            cout << "No winners recorded yet.\n";
            return;
        }
        cout << "\n--- Winners List ---\n";
        for (const auto& winner : winners) {
            cout << "Winner: " << winner.name 
                 << " (ID: " << winner.id << ")\n";
        }
    }
};

// Main Function
int main() {
    int monthlyContribution;
    cout << "Enter monthly contribution amount: ";
    cin >> monthlyContribution;

    Committee committee(monthlyContribution);

    int choice;
    do {
        cout << "\n--- Committee Management System ---\n";
        cout << "1. Add Member\n";
        cout << "2. Display Members\n";
        cout << "3. Conduct Lucky Draw\n";
        cout << "4. Display Winners\n";
        cout << "5. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch (choice) {
            case 1: {
                int id;
                string name;
                cout << "Enter Member ID: ";
                cin >> id;
                cout << "Enter Member Name: ";
                cin.ignore();
                getline(cin, name);
                committee.addMember(id, name);
                break;
            }
            case 2:
                committee.displayMembers();
                break;
            case 3:
                committee.monthlyLuckyDraw();
                break;
            case 4:
                committee.displayWinners();
                break;
            case 5:
                cout << "Exiting... Thank you!\n";
                break;
            default:
                cout << "Invalid choice. Please try again.\n";
        }
    } while (choice != 5);

    return 0;
}
