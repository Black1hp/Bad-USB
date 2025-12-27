# Bad USB IoT Project

## Overview
This project demonstrates the functionality of a **Bad USB** using the **Digispark board**. The system is designed to simulate a USB device (keyboard or mouse) that, when plugged into a target machine, executes a reverse shell payload. The payload downloads a malware script from GitHub, which creates a backdoor on the system for remote access.

This project was developed as part of an educational initiative in the field of **IoT Security** and **Penetration Testing**. It serves as a demonstration of the security vulnerabilities inherent in USB devices and the importance of securing IoT devices.

## Team Members
- **Mohamed Saied** : [LinkedIn Profile](https://www.linkedin.com/in/black1hp/)
- **Fady Mahrous**: [LinkedIn Profile](https://www.linkedin.com/in/fady-mahrous/)
- **Mohamed Hesham**: [LinkedIn Profile](https://www.linkedin.com/in/mohamed-hesham-abbas-8228242b2/)

## Supervisors
- **Yara Ahmed** (Teaching Assistant): [LinkedIn Profile](https://www.linkedin.com/in/yara-ahmed-a542301bb/)
- **Alyaa A. Hamza** (Professor): [LinkedIn Profile](https://www.linkedin.com/in/alyaa-a-hamza-896196111/)
- **Nehal Anees Mansour** (Professor): [LinkedIn Profile](https://www.linkedin.com/in/nehal-anees-mansour-95784827a/)

## Project Description
This project leverages the **Digispark board** to create a **Bad USB device** that mimics a keyboard or mouse when plugged into a system. The **payload** executed by this USB device connects back to an attacker-controlled server, granting remote access to the target machine. 

### Components:
- **Digispark Board**: A small, inexpensive USB microcontroller used to simulate a keyboard or mouse.
- **Payload Script**: A PowerShell or Bash script downloaded from GitHub that performs actions like downloading and executing additional malware (reverse shell).
- **Listener Script**: A Python-based listener that waits for incoming reverse shell connections from compromised machines.

## How It Works
1. **Plugging in the Digispark**: When the Digispark USB device is connected to the target machine, it mimics a keyboard or mouse.
2. **Command Execution**: The Digispark runs a pre-programmed script that executes a command to download a malicious payload from a GitHub repository.
3. **Reverse Shell**: Once the payload is downloaded and executed, it establishes a reverse shell connection back to the attacker's listener script.
4. **Remote Control**: The attacker can then interact with the compromised system through the reverse shell.

## Installation
To set up the project on your local machine, follow these steps:

### 1. **Set up Digispark Board**
   - Download and install the [Arduino IDE](https://www.arduino.cc/en/software).
   - Install Digispark support in the Arduino IDE (follow [this guide](https://digistump.com/wiki/digispark/tutorials/arduino-ide)).
   - Upload the `digispark.ino` code to the board.

### 2. **Set up the Payload Script**
   - Clone this repository to your local machine:
     ```bash
     git clone https://github.com/your-username/bad-usb-project.git
     ```
   - Modify the PowerShell or Bash payload scripts if needed (located in the `payloads/` directory).
   
### 3. **Run the Listener**
   - Install Python and required libraries:
     ```bash
     pip install -r requirements.txt
     ```
   - Run the listener script to wait for incoming reverse shell connections:
     ```bash
     python listener.py
     ```

## Security Warning
This project is intended strictly for educational purposes and ethical hacking in controlled environments (such as penetration testing labs or red teaming exercises). Do **not** use this project on unauthorized systems or networks.

## Contributing
We welcome contributions to improve the project. Feel free to fork the repository and submit pull requests for new features or improvements.

### Guidelines for contributing:
- Fork the repository
- Create a new branch for your feature or bug fix
- Test your changes thoroughly
- Submit a pull request with a description of your changes

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### Contact
For any questions or feedback, feel free to reach out to the project team through their LinkedIn profiles listed above.

