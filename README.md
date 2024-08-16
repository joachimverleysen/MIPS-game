# Installation Guide for MIPS Game

Welcome to the installation guide for my MIPS game! This guide will help you set up the environment and run your MIPS assembly files using MARS (MIPS Assembler and Runtime Simulator).

## Requirements

1. **Java Runtime Environment (JRE)**
   - MARS is a Java application and requires a JRE to run. You can install the latest version of JRE with the following steps:
     - **On Linux**:
       ```bash
       sudo apt-get update
       sudo apt-get install default-jre
       ```
     - **On Windows**: Download and install the latest JRE from the [official Oracle website](https://www.oracle.com/java/technologies/javase-downloads.html).

2. **MARS (MIPS Assembler and Runtime Simulator)**
   - Download the MARS JAR file from the [official website](http://courses.missouristate.edu/kenvollmar/mars/). Look for the latest version and download the file named `Mars_*.jar`.

## Installation

1. **Download and Install MARS**:
   - Download the MARS JAR file (`Mars_*.jar`) to a location on your computer.

2. **Start MARS**:
   - Open a terminal or command prompt.
   - Navigate to the directory where you downloaded the MARS JAR file. For example:
     ```bash
     cd /path/to/downloads
     ```
   - Start MARS with the following command:
     ```bash
     java -jar Mars_*.jar
     ```
     Replace `Mars_*.jar` with the exact name of the JAR file you downloaded.

## Usage

1. **Open Your MIPS Files**:
   - Once MARS is open, click `File` > `Open` and select your `.asm` files.

2. **Assemble**:
   - Click `Assemble` in the menu bar to compile your MIPS code. This will compile the code and report any syntax errors.

3. **Run the Code**:
   - Click `Run` > `Go` to execute your MIPS program. You can also step through your code using the `Step` and `Step Over` buttons.

4. **View Results**:
   - You can view the output and registers through the various tabs and windows in MARS.

## Troubleshooting

- **If MARS does not start**:
  - Ensure you have the latest version of Java installed.
  - Verify that the JAR file is not corrupted and that you are using the correct command to run it.
  - Check for any error messages in the terminal or command prompt and refer to the MARS documentation for additional support.

For any further questions or issues, please refer to the [MARS User Guide](http://courses.missouristate.edu/kenvollmar/mars/) or seek help from relevant forums and communities.
