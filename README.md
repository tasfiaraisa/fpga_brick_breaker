
# FPGA Brick Breaker

A classic Brick Breaker game developed in **Verilog HDL** and deployed on the **DE1-SoC FPGA Development Board**.

The project demonstrates digital hardware design through **finite-state machines (FSMs)**, datapath and control logic, collision detection, PS/2 keyboard interfacing, and VGA graphics rendering.

## Features

- **FSM-Based Game Control:** Manages initialization, gameplay, winning, and losing states.
- **Paddle Movement:** Uses PS/2 keyboard input to control the paddle.
- **Ball Movement:** Updates ball position and velocity based on collisions.
- **Brick Collision Detection:** Tracks and removes bricks when hit.
- **VGA Graphics:** Renders the ball, paddle, bricks, and game states on a VGA display.
- **FPGA Deployment:** Deployed on the DE1-SoC FPGA development board.

## System Architecture

The design consists of five interconnected hardware components:

### 1. FSM Controller
Coordinates game states and transitions between initialization, active gameplay, winning, and losing conditions.

### 2. Datapath
Maintains ball coordinates, velocity, paddle position, and brick status using sequential and combinational logic.

### 3. Collision Detection
Detects interactions between the ball, paddle, bricks, and screen boundaries to update game behaviour.

### 4. PS/2 Keyboard Interface
Processes keyboard input to control horizontal paddle movement.

### 5. VGA Adapter
Generates pixel data, RGB colour signals, and synchronization signals for real-time graphics output.

## Hardware & Technologies

| Category | Technologies |
|---|---|
| **Hardware** | DE1-SoC FPGA Development Board |
| **Language** | Verilog HDL |
| **Design Concepts** | FSM, Datapath & Control Logic, Sequential & Combinational Circuits |
| **Interfaces** | VGA, PS/2 Keyboard |
| **Development Tools** | Intel Quartus Prime, ModelSim |

## Project Highlights

- Designed a **hardware-based Brick Breaker game** using Verilog HDL.
- Implemented FSM and datapath logic to coordinate gameplay.
- Developed collision detection for ball movement, paddle interactions, and brick removal.
- Integrated PS/2 keyboard input for interactive controls.
- Implemented VGA rendering for real-time visual output.
- Deployed the game on the **DE1-SoC FPGA Development Board**.
